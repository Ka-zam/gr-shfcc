function pha_diff = phasediff(x1,x2, N)
% function pha_diff = phasediff(x1,x2,N)
% Compute pahse difference between the periodic signals
if nargin < 3
    N = -1;
end


xc = xcorr(x1,x2);
if N < 0
    [~,idx] = max(abs(xc));
else
    idx = N;
end

pha_diff= angle(xc(idx));