function [f,A,snr] = yeest(x, Q)
%Estimate f, A and phi for a real sinusoid
% x = abs(A)*cos( 2*pi*f*t + angle(A) ) + w
% where w is Gaussian with variance sigma^2 and
% SNR = abs(A)^2/(2*sigma^2)

if nargin < 2
    Q = 3;
end

x = x(:);

N = length(x);
X = fft(x);
Y = X.*conj(X);

[~,m] = max(Y(1:ceil(N/2)));
m = m - 1; %Matlab indexing starts at 1

n_all = [0:N-1]';

delta = 0;
A = 0;

for i=1:Q

    Xp05 = 1/N*sum( x.*exp(-1j*2*pi/N*(m+delta+0.5)*n_all) );%According to corrections
    Xn05 = 1/N*sum( x.*exp(-1j*2*pi/N*(m+delta-0.5)*n_all) );%According to corrections
    
    Lp05 = conj(A)/N*( 1+exp(-1j*4*pi*delta) )/( 1 - exp(-1j*2*pi/N*(2*m+2*delta+.5)) );
    Ln05 = conj(A)/N*( 1+exp(-1j*4*pi*delta) )/( 1 - exp(-1j*2*pi/N*(2*m+2*delta-.5)) );
    
    Sp05 = Xp05 - Lp05;
    Sn05 = Xn05 - Ln05;
    
    delta = delta + .5*real( (Sp05 + Sn05)/(Sp05 - Sn05) );
    
    A = 1/N*( sum( x.*exp( -1j*2*pi/N*(m+delta)*n_all ) ) -...
        conj(A)*(1-exp(-1j*4*pi*delta))/(1-exp(-1j*4*pi/N*(m+delta))) );
end
%Now that we have sine paramters we can calculate SNR
% Note - this assumes no higher spectral components
% SNR = P_sig/(P_tot - P_sig)

P_tot = var(x);
P_sig = 2*A*conj(A);

if P_tot > P_sig
    snr   = P_sig/(P_tot-P_sig);
else
    snr = NaN;
end

f = (m+delta)/N;

%out = [ 2*abs(A) (m+delta)/N angle(A) 10*log10(snr) ];
