"""(Stage 5 BPSK fix) |H(f)| of the measured loop response vs the Butterworth model, and the noise PSD of noise_s0 vs the model noise. Needs .scratch/bpsk_diag/h_sigL_s0.npz (bpsk_diag.py). Run from the repo root."""
import os, sys, numpy as np
os.environ['X310_CHANNEL'] = 'lpf'  # model noise = the first channel model
sys.path.insert(0, 'sw/x310'); sys.path.insert(0, 'ref/x310')
import nsclf_analyze as A, x310_data as xd
from scipy.signal import welch, sosfilt, freqz
z = np.load('.scratch/bpsk_diag/h_sigL_s0.npz'); h, lags = z['h'], z['lags']
f = np.linspace(-100e6, 100e6, 801)
H = np.array([np.sum(h * np.exp(-2j*np.pi*ff*lags/200e6)) for ff in f])
imp = np.zeros(400); imp[0] = 1; hb = sosfilt(xd.SOS, imp)
HB = np.array([np.sum(hb * np.exp(-2j*np.pi*ff*np.arange(400)/200e6)) for ff in f])
_, yn = A.load_capture('noise_s0'); yn = yn - yn.mean()
fw, P = welch(yn, fs=200e6, nperseg=1024, return_onesided=False); o = np.argsort(fw); fw, P = fw[o], P[o]
rng = np.random.default_rng(0); nm = xd.receiver_noise(rng, (1, 1 << 20))[0]
_, Pm = welch(nm, fs=200e6, nperseg=1024, return_onesided=False); Pm = Pm[o]
Hn = np.abs(H) / np.abs(H[400]); HBn = np.abs(HB)
P0 = P[np.argmin(np.abs(fw))]; Pm0 = Pm[np.argmin(np.abs(fw))]
print('f MHz | |H| meas dB | Butter dB | noise PSD real dB | model dB | grpdelay meas')
ph = np.unwrap(np.angle(H)); gd = -np.gradient(ph, f) / (2*np.pi) * 200e6
for ff in [-90,-80,-70,-60,-50,-40,-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35,40,50,60,70,80,90]:
    k = np.argmin(np.abs(f - ff*1e6)); kk = np.argmin(np.abs(fw - ff*1e6))
    print(f'{ff:5d} | {20*np.log10(Hn[k]):7.1f} | {20*np.log10(HBn[k]):7.1f} | {10*np.log10(P[kk]/P0):7.1f} | {10*np.log10(Pm[kk]/Pm0):7.1f} | {gd[k]:6.2f}')
print('h taps |h| dB rel peak:', [(int(l), round(float(20*np.log10(abs(v)/abs(h).max())),1)) for l, v in zip(lags, h) if abs(v) > 0.01*abs(h).max()])
