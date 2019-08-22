function [epsilon,tau,err] = fillqamerr( x, E , T , input )

if nargin == 0
    input.fc = 6000.;
    input.sps = 8;
    input.beta = .2;
    input.tau = 0;
    input.amp = 1;
    input.phi = 0;
    input.constellation = [ [1+1j -1+1j -1-1j 1-1j]/sqrt(2) 1.5j 1.5 ];
    input.fs = 96000.;
    epsilon = input;
    return
end

E = linspace( E(1) , E(2) , E(3) );
T = linspace( T(1) , T(2) , T(3) );

[epsilon,tau]= meshgrid(E,T);

err = zeros(size(epsilon));

for m = 1:length(E)
    for k = 1:length(T)
        err(k,m) = qammetric( x , epsilon(k,m) , tau(k,m) , input );
    end
end