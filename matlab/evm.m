function e = evm( measured , reference )
%function e = evm( measured , reference )
% Calculate Error Vector Magnitude
% e [%] = sqrt( sum( I_err^2 + Q_err^2 ) )/N/REF x 100%
% Where REF is the nomalization reference == max(abs(reference))

N = length(measured);
REF = max( abs( reference ) );
e = zeros(N,1);
% ML estimator
for n=1:N
    [~,idx] = min(norm( measured - reference) );
    e(n) = measured(n) - reference(idx);
    e(n) =  e(n)*conj(e(n)) ;
end

e = sqrt( sum(e) )/N/REF*100;
