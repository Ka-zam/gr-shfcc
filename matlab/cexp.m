function [out,t] = cexp(fc, fs, N, SNR_db, pha)
% function [out,t] = cexp(fc,fs, N , SNR_db, pha)
% Complex exponential with noise if SNR_dB supplied
% Initial phase is pha
if nargin < 5
    pha = 0.;
else
    pha = pha*pi/180;
end

if nargin < 4
    add_noise = false;
else
    add_noise = true;
end

if nargin < 3
    N = 10;
end

if N == 0
    %Periodic length
    [g,c,d] = gcd( fs , fc );
    N = round( fs/g * fc/g );
    disp(N)
end

if nargin < 2
    fs = 1;
end

t = linspace(0,(N-1)/fs,N)';

if ~add_noise
    out = exp( 1j*(2*pi*fc*t+pha) );
else
    P_noise = 10^(-SNR_db*.1);
    out = exp( 1j*(2*pi*fc*t+pha) );
    out = out + sqrt(P_noise*.5)*(randn(N,1) + 1j*randn(N,1) );
% No need for this    
% else
%     P_sig = 10^(SNR_db*.1);
%     out = sqrt(P_sig)*exp( 1j*(2*pi*fc*t+pha) );
%     out = out + sqrt(.5)*(randn(N,1) + 1j*randn(N,1) );
end