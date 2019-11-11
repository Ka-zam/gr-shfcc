function s = cosn(fc,fs,N,snr,pha)
% Generate cos(x) in AWGN channel
% s = cosn(fc,fs,N,snr,pha)

if nargin < 5
  pha = 0.;
else
    pha= pha*pi/180;
end

if nargin < 4
    ADD_NOISE = false;
else
    ADD_NOISE = true;
end

rate = 1/fs;
t = [0:rate:(N-1)*rate]';

x = cos(2*pi*fc*t + pha);

if ADD_NOISE
    n = 10^(-snr/20)/sqrt(2)*randn(size(x));
    s = x + n;
else
    s = x;
end

%fprintf(1," var s: %12.10f \n var n: %12.10f\n snr  : %5.3f dB\n", var(x) , var(n), 10*log10(var(x)/var(n)) );
