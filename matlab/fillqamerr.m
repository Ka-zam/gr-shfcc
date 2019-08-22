function [epsilon,tau,err] = fillqamerr( x, E , T , input )

[epsilon,tau]= meshgrid(E,T);

err = zeros(size(epsilon));

for m = 1:length(E)
    for k = 1:length(T)
        err(k,m) = qammetric( x , epsilon(k,m) , tau(k,m) , input );
    end
end