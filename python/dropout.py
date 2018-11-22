#!/usr/bin/python
from scipy.interpolate import interp1d
import matplotlib as mpl
from matplotlib.pyplot import plot,show,hold,grid
from scipy.io import wavfile
import numpy as np
import sys


fname = sys.argv[1]

fs,s = wavfile.read(fname)
s = s[:2**18,0]

#Some windowing
win = np.linspace(0,1,100,dtype='float32')

q_u = np.zeros(s.shape)
q_l = np.zeros(s.shape)

#Prepend the first value of (s) to the interpolating values. This forces the model to use the same starting point for 
#both the upper and lower envelope models.

u_x = np.array(0.,'float32')
u_y = np.array(s[0],'float32')

l_x = np.array(0.,'float32')
l_y = np.array(s[0],'float32')

pos_cross = np.array((),dtype='float32')

def pos_zero_cross(k,neg,pos):
	return k - neg/(pos-neg)

#Detect peaks and troughs and mark their location in u_x,u_y,l_x,l_y respectively.

for k in xrange(1,len(s)-1):
    if (np.sign(s[k]-s[k-1])==1) and (np.sign(s[k]-s[k+1])==1):
        u_x = np.append(u_x,k)
        u_y = np.append(u_y,s[k])

    if (np.sign(s[k]-s[k-1])==-1) and ((np.sign(s[k]-s[k+1]))==-1):
        l_x = np.append(l_x,k)
        l_y = np.append(l_y,s[k])

    if ( np.sign(s[k])==-1) and (np.sign(s[k+1])==1):
    	pos_cross = np.append(pos_cross , pos_zero_cross(k,s[k],s[k+1]) )


#Append the last value of (s) to the interpolating values. This forces the model to use the same ending point 
#for both the upper and lower envelope models.

u_x = np.append(u_x,len(s)-1)
u_y = np.append(u_y,s[-1])

l_x = np.append(l_x,len(s)-1)
l_y = np.append(l_y,s[-1])

#Calculate period time
period = np.diff(pos_cross)
period /= fs
freq = 1./period

#Fit suitable models to the data. 

u_p = interp1d(u_x,u_y, kind = 'quadratic',bounds_error = False, fill_value=0.0)
l_p = interp1d(l_x,l_y,kind = 'quadratic',bounds_error = False, fill_value=0.0)

#Evaluate each model over the domain of (s)
for k in xrange(0,len(s)):
    q_u[k] = u_p(k)
    q_l[k] = l_p(k)

#Plot everything
mpl.pyplot.figure(1)
grid(True)
plot(s)
plot(q_u,'r')
plot(q_l,'g')
print("Mean period    %8.3f us" % np.mean(period*1.e6))
print("Std  period    %8.3f us" % np.std(period*1.e6))

print("Mean frequency %8.3f Hz" % np.mean(freq))
print("Std  frequency %8.3f Hz" % np.std(freq))

print("Have %d periods from %d samples, %8.3f ms" % (len(freq), len(s), len(s)/(fs*1.e-3) ))

mpl.pyplot.figure(2)
plot(freq)
grid(True)



if len(freq)%2 != 0:
	freq = freq[:-1]

bins = np.fft.fftfreq(len(freq),np.mean(period))
spec = 20.*np.log10( np.abs( np.fft.fft(freq - np.mean(freq) ) ))
spec[0] = np.mean(spec)

bins = np.fft.fftshift(bins)
bins = bins[len(freq)/2:]

spec = np.fft.fftshift(spec)
spec = spec[len(freq)/2:]

mpl.pyplot.figure(3)

plot(bins,spec)
grid(True)

mpl.pyplot.figure(4)

mpl.pyplot.psd(s,NFFT=2048,Fs=fs,scale_by_freq=True,noverlap=1024)



show()