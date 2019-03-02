function [out,t,pha] = sinepn(fc,fs, var0 , var3 , N)

t = linspace(0,(N-1)/fs,N)';

var0_vec = var0*randn(N,1);
var3_vec = var3*randn(N,1);

pha = zeros(size(var0_vec));
pha(1) = var3_vec(1);

for k=2:length(pha)
    pha(k) = pha(k-1) + var3_vec(k);
end

pha = pha + var0_vec;

out = sin(2*pi*fc*t + pha);