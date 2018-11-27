function [out,t] = sinepn(fc,fs, deltavar, N)

t = linspace(0,(N-1)/fs,N)';

del = deltavar*randn(N,1);

pha = zeros(size(del));

for k=2:length(pha)
    pha(k) = pha(k-1) + del(k);
end

out = sin(2*pi*fc*t + pha);