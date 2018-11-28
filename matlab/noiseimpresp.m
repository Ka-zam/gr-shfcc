function out = noiseimpresp(alpha,fs,fcutoff)

N = ceil( fs/fcutoff );
out = zeros(N,1);

out(1) = 1;

for k=2:N
    out(k) = (alpha*.5-1+k-1)*out(k-1)/(k-1);
end

