"""Copy a da4ml qec_d5 gen dir and insert a pure broadcast register between stage<k>_inp and stage k.

Each layer's output register fans out (~80-190) to an all-to-all next layer, and at 6.206 ns on the VU9P
that net alone takes 5-10 ns (PLAN.md D-S4-SEL, 2026-10-28). The extra register stage carries no logic,
so the placer can put it beside its consumers. Latency + len(stages) cycles, II = 1, arithmetic unchanged
(Verilator bit-exact against the golden set). metadata.json gets the new latency and the stage list.
  add_bcast.py <src> <dst> <maxfo|0> k [k ...]   explicit stages
  add_bcast.py <src> <dst> <maxfo|0> auto        every stage whose output is > BC_RATIO (env, default 5) x its input
maxfo > 0 adds (* max_fanout = maxfo *) to the broadcast registers."""
import re, shutil, sys, json
from pathlib import Path
src, dst, mf = Path(sys.argv[1]), Path(sys.argv[2]), int(sys.argv[3])
if dst.exists(): shutil.rmtree(dst)
shutil.copytree(src, dst)
f = dst / 'src/qec_d5.v'; s = f.read_text()
if sys.argv[4:] == ['auto']:
    inw = {int(k): int(w) + 1 for w, k in re.findall(r'reg \[(\d+):0\] stage(\d+)_inp;', s)}
    outw = {int(k): int(w) + 1 for w, k in re.findall(r'wire \[(\d+):0\] stage(\d+)_out;', s)}
    ks = [k for k in sorted(inw) if k in outw and outw[k] > float(__import__('os').environ.get('BC_RATIO', 5)) * inw[k]]
else:
    ks = [int(x) for x in sys.argv[4:]]
attr = f'(* max_fanout = {mf} *) ' if mf else ''
for k in ks:
    w = re.search(rf'reg \[(\d+):0\] stage{k}_inp;', s).group(1)
    s = s.replace(f'    reg [{w}:0] stage{k}_inp;', f'    reg [{w}:0] stage{k}_inp;\n    {attr}reg [{w}:0] stage{k}_bc;', 1)
    old = f'qec_d5_stage{k} stage{k} (.model_inp(stage{k}_inp),'
    assert old in s; s = s.replace(old, f'qec_d5_stage{k} stage{k} (.model_inp(stage{k}_bc),')
    s = s.replace('    always @(posedge clk) begin\n', f'    always @(posedge clk) begin\n        stage{k}_bc <= stage{k}_inp;\n', 1)
f.write_text(s)
m = json.loads((dst / 'metadata.json').read_text()); m['latency'] += len(ks); m['broadcast_stages'] = ks; m['broadcast_max_fanout'] = mf
(dst / 'metadata.json').write_text(json.dumps(m))
print(dst, 'broadcast stages', ks, 'latency', m['latency'])
