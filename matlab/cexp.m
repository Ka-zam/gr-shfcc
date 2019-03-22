function [out,t] = cexp(fc,fs, N)
% function [out,t] = cexp(fc,fs, N)
% Complex exponential
if nargin < 3
    N = 10;
end

if nargin < 2
    fs = 96e3;
end

t = linspace(0,(N-1)/fs,N)';
out = exp( 1j*2*pi*fc*t );