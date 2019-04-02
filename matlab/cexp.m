function [out,t] = cexp(fc,fs, N , SNR_db )
% function [out,t] = cexp(fc,fs, N , SNR_db)
% Complex exponential with noise if SNR_dB supplied
if nargin < 4
    add_noise = false;
else
    add_noise = true;
end
if nargin < 3
    N = 10;
end
if nargin < 2
    fs = 96e3;
end

t = linspace(0,(N-1)/fs,N)';

if ~add_noise
    out = exp( 1j*2*pi*fc*t );
elseif SNR_db >= 0.0
    P_noise = 10^(-SNR_db*.1);
    out = exp( 1j*2*pi*fc*t );
    out = out + sqrt(P_noise*.5)*(randn(N,1) + 1j*randn(N,1) );
else
    P_sig = 10^(SNR_db*.1);
    out = sqrt(P_sig)*exp( 1j*2*pi*fc*t );
    out = out + sqrt(.5)*(randn(N,1) + 1j*randn(N,1) );
end