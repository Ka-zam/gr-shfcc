function out = yeest(x, Q)
%Estimate f, A and phi for a real sinusoid
% x = A*sin(2*pi*f*t + phi)

if nargin < 2
    Q = 3;
end

x = x(:);

N = length(x);
X = fft(x);
Y = abs(X).^2;

[~,m] = max(Y);
m = m - 1; %Matlab indexing starts at 1

if m >= N/2
    m = N - m;
end

n_all = [0:N-1]';

delta = 0;
A = 0;

for i=1:Q
    Xp = sum(x.*exp(-1j*2*pi/N*(m+0.5)*n_all));
    Xn = sum(x.*exp(-1j*2*pi/N*(m-0.5)*n_all));
    
    Stp = A*(1+exp(1j*4*pi*delta))/( 1- exp(-1j*2*pi/N*(2*m+2*delta+.5)) );
    Stn = A*(1+exp(1j*4*pi*delta))/( 1- exp(-1j*2*pi/N*(2*m+2*delta-.5)) );
    
    Sp = Xp - Stp;
    Sn = Xn - Stn;
    
    delta = delta + .5*real( (Sp + Sn)/(Sp - Sn) );
    A = ( sum(x.*exp(1j*2*pi/N*(m+delta)*n_all)) -...
        A*(1-exp(-1j*4*pi*delta))/(1-exp(-1j*4*pi/N*(m+delta))) )/N;
end

out = [ (m+delta)/N 2*abs(A) angle(A) ];
    
