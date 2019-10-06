function [epsilon,tau,err] = fillqamerr( x, E , T , input )

if nargin == 0
    x = 16;
    FLAG = 1;
end

if nargin == 1 || exist('FLAG','var')
    input.fc = 6000.;
    input.sps = 8;
    input.beta = .2;
    input.filtered = false;
    %GNU Radio style constellation points
    % np.sum(np.abs(c))/len(c) == 1.0
    M = x;
    c = qammod([0:M-1],M,'UnitAveragePower',false);
    c = c/( sum(abs(c))/length(c) );
    input.constellation = c;
    input.pilotsymbol = sqrt(2);
    input.pilotperiod = 8;
    input.fs = 96000.;
    
    %Filters
    input.rrc = rcosdesign( input.beta , rrcspan(input.beta) , input.sps , 'sqrt');
    input.rrc = input.rrc/sum(input.rrc);
    input.rrc_rf = input.rrc.*exp(1j*[0:length(input.rrc)-1]*2*pi*(input.fc/input.fc));
    
    %Data    
    input.rf = [];
    input.rf_filt = [];
    
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