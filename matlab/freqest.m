function out = freqest( x , calc_len , Q)
% function out = freeqest( x , calc_len )
% Continuous frequency estimation of x with window calc_len
% length(out) = length(x) - calc_len

if nargin < 3
    Q = 3;
end

out = zeros( length(x)-calc_len-1 , 1 );

n=1;
while n <= length(out)
    tmp = yeest( x( n : n + calc_len ) , Q );
    out(n) = tmp(2);
    n = n + 1;
end