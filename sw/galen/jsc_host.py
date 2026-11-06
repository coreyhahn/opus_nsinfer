#!/usr/bin/env python3
"""galen (ZCU102) host tool for the Stage 1 harness. Runs on galen as root.

  jsc_host.py load <bitstream.bin>            PL load through the Linux FPGA manager (volatile; no flash)
  jsc_host.py info                            ID / PARAMS / CFG, F_net check against wall time
  jsc_host.py stream VEC.npz [--seeds 0 1 2 3] [--runs 2]
                                              bit-exact pass: every vector, each seed's order, each run;
                                              same xorshift32 Fisher-Yates permutation as tb/tb_harness.sv
  jsc_host.py timed VEC.npz [--periods 1.25] [--stride 1] [--trials 4]
                                              phase sweep; prints TRIAL lines for sw/analysis/timed_solve.py

Register map: docs/ARCHITECTURE.md §3. Only /dev/mem at 0xA000_0000 (2 MiB,
the PL window on HPM0_FPD) is touched. Every poll has a timeout.
"""

import argparse
import json
import mmap
import os
import shutil
import sys
import time

import numpy as np

BASE, SPAN = 0xA000_0000, 0x20_0000
R = dict(ID=0x000, PARAMS=0x004, CFG=0x008, SCRATCH=0x00C, CTRL=0x010, STREAM_N=0x014, STREAM_GO=0x018,
         STATUS=0x01C, STREAM_CYC=0x020, T_VEC=0x024, STAGE_GO=0x028, ARM=0x02C, K_H=0x030, K_B=0x034,
         K_C=0x038, T_CLASS=0x03C, T_LOGIT=0x040, P_G=0x050, P_D=0x054, PS_CMD=0x060, PS_POS=0x064, CNT=0x070)
VEC, RES = 0x80000, 0x100000
FPGA_MGR = '/sys/class/fpga_manager/fpga0'


class Harness:
    def __init__(self):
        self.fd = os.open('/dev/mem', os.O_RDWR | os.O_SYNC)
        self.mm = mmap.mmap(self.fd, SPAN, mmap.MAP_SHARED, mmap.PROT_READ | mmap.PROT_WRITE, offset=BASE)
        self.w = np.frombuffer(self.mm, dtype=np.uint32)

    def rd(self, name):
        return int(self.w[R[name] >> 2])

    def wr(self, name, val):
        self.w[R[name] >> 2] = np.uint32(val & 0xFFFF_FFFF)

    def poll(self, cond, what, timeout=2.0):
        t0 = time.monotonic()
        while True:
            st = self.rd('STATUS')
            if cond(st):
                return st
            if time.monotonic() - t0 > timeout:
                raise SystemExit(f'TIMEOUT waiting for {what}: STATUS=0x{st:08x}')

    def params(self):
        p, c = self.rd('PARAMS'), self.rd('CFG')
        return dict(lat_net=p & 0xFF, arg_lat=(p >> 8) & 0xF, depth_log2=(p >> 12) & 0xF, n_core=(p >> 16) & 0xFF,
                    lc=p >> 24, f_net_mhz=c & 0xFFFF, axi_div=(c >> 16) & 0xF, ps_steps=c >> 20)


def xs32_perm(n, seed):
    perm = np.arange(n, dtype=np.int64)
    if seed == 0:
        return perm
    r = seed & 0xFFFF_FFFF
    for i in range(n - 1, 0, -1):
        r ^= (r << 13) & 0xFFFF_FFFF
        r ^= r >> 17
        r ^= (r << 5) & 0xFFFF_FFFF
        j = r % (i + 1)
        perm[i], perm[j] = perm[j], perm[i]
    return perm


def cmd_load(a):
    name = os.path.basename(a.bin)
    os.makedirs('/lib/firmware', exist_ok=True)  # galen's rootfs is RAM; nothing persists
    shutil.copy(a.bin, f'/lib/firmware/{name}')
    with open(f'{FPGA_MGR}/flags', 'w') as f:
        f.write('0')
    with open(f'{FPGA_MGR}/firmware', 'w') as f:
        f.write(name)
    state = open(f'{FPGA_MGR}/state').read().strip()
    print(f'LOAD {name} state={state}')
    if state != 'operating':
        sys.exit(1)


def cmd_info(a):
    h = Harness()
    idv = h.rd('ID')
    p = h.params()
    c0, t0 = h.rd('CNT'), time.monotonic()
    time.sleep(1.0)
    c1, t1 = h.rd('CNT'), time.monotonic()
    f = ((c1 - c0) & 0xFFFF_FFFF) / (t1 - t0) / 1e6
    st = h.rd('STATUS')
    print(json.dumps(dict(id=f'0x{idv:08x}', **p, status=f'0x{st:08x}', mmcm_locked=bool(st & 8),
                          f_net_measured_mhz=round(f, 3))))
    if idv != 0x4A53_4331:
        sys.exit(1)


def load_chunk(h, vin, idx):
    n = len(idx)
    off = (VEC >> 2) + (np.arange(n)[:, None] * 8 + np.arange(5)[None, :])
    h.w[off.ravel()] = vin[idx].ravel()
    # read back the first and last vector through port A
    for i in (0, n - 1):
        got = h.w[(VEC >> 2) + i * 8 + np.arange(5)]
        if not np.array_equal(got, vin[idx[i]]):
            raise SystemExit(f'VEC readback mismatch at {i}: {got} vs {vin[idx[i]]}')


def cmd_stream(a):
    h = Harness()
    d = np.load(a.vectors)
    vin, vout = d['vin'], d['vout']
    n_all = len(vin) if a.nvec is None else a.nvec
    p = h.params()
    depth = 1 << p['depth_log2']
    h.wr('ARM', 0)
    h.wr('CTRL', 0)
    print(f'# STREAM params={json.dumps(p)} hashes={d["hashes"]}')
    total_bad = 0
    for seed in a.seeds:
        perm = xs32_perm(len(vin), seed)[:n_all]
        for run in a.runs:
            t0 = time.monotonic()
            bad = bad_cls = 0
            cyc_off = None
            seq = (h.rd('STATUS') >> 16) & 0xFF
            for base in range(0, n_all, depth):
                idx = perm[base:base + depth]
                n = len(idx)
                load_chunk(h, vin, idx)
                h.wr('STREAM_N', n)
                h.wr('STREAM_GO', 1)
                st = h.poll(lambda s: not (s & 1) and ((s >> 16) & 0xFF) == ((seq + 1) & 0xFF), 'stream')
                seq = (st >> 16) & 0xFF
                cyc = h.rd('STREAM_CYC')
                if cyc_off is None:
                    cyc_off = cyc - (n - 1)
                elif cyc != n - 1 + cyc_off:
                    raise SystemExit(f'STREAM_CYC {cyc} for n={n}, expected {n - 1 + cyc_off}')
                off = (RES >> 2) + (np.arange(n)[:, None] * 4 + np.arange(3)[None, :])
                got = h.w[off.ravel()].reshape(n, 3)
                exp = vout[idx]
                bad += int(np.sum(np.any(got[:, :2] != exp[:, :2], axis=1) | ((got[:, 2] & 0xFFFF) != (exp[:, 2] & 0xFFFF))))
                bad_cls += int(np.sum((got[:, 2] >> 16) != (exp[:, 2] >> 16)))
                if bad or bad_cls:
                    w = np.nonzero(np.any(got != exp, axis=1))[0][:5]
                    for i in w:
                        print(f'MISMATCH vec={idx[i]} got={got[i]} exp={exp[i]}')
            dt = time.monotonic() - t0
            total_bad += bad + bad_cls
            print(f'RESULT stream seed={seed} run={run} vectors={n_all} logit_mismatches={bad} '
                  f'class_mismatches={bad_cls} stream_cyc_offset={cyc_off} seconds={dt:.1f}', flush=True)
    sys.exit(1 if total_bad else 0)


def cmd_timed(a):
    h = Harness()
    d = np.load(a.vectors)
    vin, vout = d['vin'], d['vout']
    p = h.params()
    depth = 1 << p['depth_log2']
    S, T = p['ps_steps'], 1000.0 / p['f_net_mhz']
    h.wr('ARM', 0)
    h.wr('CTRL', 1)
    idx = np.arange(min(depth, len(vin)))
    load_chunk(h, vin, idx)
    n_pos = int(round(a.periods * S / a.stride))
    pos0 = h.rd('PS_POS') - (1 << 32 if h.rd('PS_POS') & 0x8000_0000 else 0)
    print(f'# SWEEP T_NS={T:.6f} PS_STEPS={S} n_core={p["n_core"]} stride={a.stride} trials={a.trials} '
          f'positions={n_pos} pos0={pos0} params={json.dumps(p)} hashes={d["hashes"]}', flush=True)
    rng = np.random.default_rng(a.vec_seed)
    bad = missing = 0
    for k in range(n_pos):
        pos = h.rd('PS_POS')
        pos = pos - (1 << 32) if pos & 0x8000_0000 else pos
        for _ in range(a.trials):
            v = int(rng.integers(len(idx)))
            h.wr('T_VEC', v)
            h.wr('STAGE_GO', 1)
            h.poll(lambda s: not (s & 2), 'stage')
            h.wr('ARM', 1)
            st = h.poll(lambda s: (s & 0x700) == 0x700, 'DEC_VALID', timeout=0.5)
            t1 = time.monotonic()
            while (st & 0x1800) != 0x1800 and time.monotonic() - t1 < 0.05:
                st = h.rd('STATUS')
            r = {n: h.rd(n) for n in ('K_H', 'K_B', 'K_C', 'P_G', 'P_D', 'T_CLASS')}
            lg = [h.rd('T_LOGIT'), int(h.w[(R['T_LOGIT'] >> 2) + 1]), int(h.w[(R['T_LOGIT'] >> 2) + 2])]
            exp = vout[v]
            ok = lg[0] == exp[0] and lg[1] == exp[1] and (lg[2] & 0xFFFF) == (exp[2] & 0xFFFF) and r['T_CLASS'] == exp[2] >> 16
            bad += not ok
            if (st & 0x1800) != 0x1800:
                missing += 1
                r['P_G'] = r['P_D'] = -1
            print(f'TRIAL pos={pos} vec={v} kh={r["K_H"]} kb={r["K_B"]} kc={r["K_C"]} pg={r["P_G"]} pd={r["P_D"]} '
                  f'cls={r["T_CLASS"]} ok={int(ok)}', flush=True)
            h.wr('ARM', 0)
        h.wr('PS_CMD', a.stride)
        h.poll(lambda s: not (s & 4), 'phase step')
    print(f'RESULT timed trials={n_pos * a.trials} positions={n_pos} stride={a.stride} mismatches={bad} '
          f'missing_pc={missing} n_core={p["n_core"]}', flush=True)
    sys.exit(1 if bad or missing else 0)


def main():
    ap = argparse.ArgumentParser()
    sp = ap.add_subparsers(dest='cmd', required=True)
    s = sp.add_parser('load'); s.add_argument('bin')
    sp.add_parser('info')
    s = sp.add_parser('stream'); s.add_argument('vectors'); s.add_argument('--seeds', type=int, nargs='+', default=[0, 1, 2, 3])
    s.add_argument('--runs', type=int, nargs='+', default=[1, 2]); s.add_argument('--nvec', type=int)
    s = sp.add_parser('timed'); s.add_argument('vectors'); s.add_argument('--periods', type=float, default=1.25)
    s.add_argument('--stride', type=int, default=1); s.add_argument('--trials', type=int, default=4)
    s.add_argument('--vec-seed', type=int, default=1)
    a = ap.parse_args()
    dict(load=cmd_load, info=cmd_info, stream=cmd_stream, timed=cmd_timed)[a.cmd](a)


if __name__ == '__main__':
    main()
