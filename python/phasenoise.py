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


fname = sys.argv[1]

fs,s = wavfile.read(fname)

if s.ndim == 2:
	#Do left channel
	s = s[:,0]


cross = np.array((),dtype='float32')

for k in xrange(1,len(s)-1):
    if ( np.sign(s[k])==-1) and (np.sign(s[k+1])==1):
    	cross = np.append(cross , zero_cross(k,s[k],s[k+1]) )
    elif ( np.sign(s[k])==1) and (np.sign(s[k+1])==-1):
    	cross = np.append(cross , zero_cross(k,s[k],s[k+1]) )
    elif np.abs(s[k]) < 1.0e-20:
    	cross = np.append( cross , k ) 


#Calculate period time
period = np.diff(cross)
period /= fs
period *= 2.0 #Detect half periods
freq = 1./period

#Plot everything
print("Have %d periods from %d samples (%8.3f ms)" % (len(freq), len(s), len(s)/(fs*1.e-3) ))

print("Mean period   : %8.3f us" % np.mean(period*1.e6))
print("Std  period   : %8.3f us" % np.std(period*1.e6))

print("Mean frequency: %8.3f Hz" % np.mean(freq))
print("Std  frequency: %8.3f Hz" % np.std(freq))


mpl.pyplot.figure(1)
plot(freq-np.mean(freq))
grid(True)


if len(freq)%2 != 0:
	freq = freq[:-1]

bins = np.fft.fftfreq(len(freq),np.mean(period))
spec = db20( np.abs( np.fft.fft(freq - np.mean(freq) ) ))
#spec[0] = np.mean(spec)

bins = np.fft.fftshift(bins)
bins = bins[len(freq)/2:]

spec = np.fft.fftshift(spec)
spec = spec[len(freq)/2:]

mpl.pyplot.figure(2)

plot(bins[1:],spec[1:])
grid(True)

mpl.pyplot.figure(3)

pbins , Pxx = sig.welch(s, fs=fs, nperseg=16384, noverlap=None)  
fbin = pbins[1]-pbins[0]

#plot(pbins,db10(Pxx))
mpl.pyplot.semilogx(pbins,db10(Pxx))
grid(True)

idx = np.argmax(Pxx)
pwr_w = 5
sigpwr = np.sqrt(np.sum(Pxx[idx-pwr_w:idx+pwr_w+1])*fbin)

idx_3 = idx*3
h3pwr = np.sqrt(np.sum(Pxx[idx_3-pwr_w:idx_3+pwr_w+1])*fbin)

idx_5 = idx*5
if idx_5+pwr_w < len(Pxx):
	h5pwr = np.sqrt(np.sum(Pxx[idx_5-pwr_w:idx_5+pwr_w+1])*fbin)
else:
	h5pwr = 1.e-20


print("Signal power  : %8.3f dB"  % db10(sigpwr))
print("3rd harmonic  : %8.3f dBc" % db20(h3pwr/sigpwr))
print("5th harmonic  : %8.3f dBc" % db20(h5pwr/sigpwr))

#Allan variance
mpl.pyplot.figure(4)
t = np.logspace(0,3,50)
(t2,ad,ade,adn) = allantools.oadev(freq/3000.-1, data_type='freq', rate=3000)
mpl.pyplot.loglog(t2,ad)
grid(True)


PLOT = True
#PLOT = False
if PLOT:
	show()
