function [out,t] = cexp(fc,fs, N)
% function [out,t,pha] = cexp(fc,fs, N)
% Complex exponential

t = linspace(0,(N-1)/fs,N)';
out = exp( 1j*2*pi*fc*t );