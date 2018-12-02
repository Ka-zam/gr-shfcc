#!/usr/bin/python
from scipy.interpolate import interp1d
import matplotlib as mpl
from matplotlib.pyplot import plot,show,hold,grid
from scipy.io import wavfile
import numpy as np
import scipy as sp
import scipy.signal as sig
import allantools
import sys


def db20(x):
	return 20.*np.log10(x)

def db10(x):
	return 10.*np.log10(x)

def zero_cross(k,neg,pos):
	return k - neg/(pos-neg)

def downconvert(x,fc=3.e3,fs=96.e3):
	t = np.linspace(0,(len(x)-1)/fs,len(x))
	x = sig.hilbert(x)

	x_mix = np.exp(-1j*2.*np.pi*fc*t)
	return x*x_mix


fname = sys.argv[1]
try:
	fc = float(sys.argv[2])
except:
	fc = 3.0e3



fs,s = wavfile.read(fname)
print("fc: %8.3f  fs: %8.3f" % (fc,fs) )

if s.ndim == 2:
	#Do left channel
	s = s[:,0]

### Calculate phase

# Downconvert
s = downconvert(s,fc=fc,fs=fs)
#>> sineda=detrend(unwrap(angle(filter(rrc,1,sined)))*180/pi);
pha = sp.unwrap( np.angle( s ))
inst_freq = np.diff(pha)/(2.*np.pi)*fs

t = np.linspace(0,(len(s)-1)/fs,len(s))

mpl.pyplot.figure(1)
plot(t,pha*180./np.pi)
grid(True)


mpl.pyplot.figure(2)
plot(t[1:],inst_freq)
grid(True)
#Allan variance
mpl.pyplot.figure(3)

(t,ad,ade,adn) = allantools.oadev(pha - np.mean(pha), data_type='phase', rate=fs)
(t,ad,ade,adn) = allantools.oadev(inst_freq - np.mean(inst_freq), data_type='freq', rate=fs)
mpl.pyplot.loglog(t,ad)
grid(True)


PLOT = True
#PLOT = False
if PLOT:
	show()
