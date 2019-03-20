function [out,t,pha] = cexppn(fc,fs, var0 , var3 , N)
%DRM800-A typical values:
% var0 = 0.015
% var3 = 0.0045

t = linspace(0,(N-1)/fs,N)';

var0_vec = var0*randn(N,1);
var3_vec = cumsum(var3*randn(N,1));

pha = var3_vec + var0_vec;

out = exp( 1j*(2*pi*fc*t + pha) );