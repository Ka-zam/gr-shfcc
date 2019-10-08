function out = phasediff(x1,x2, ALG)
% function pha_diff = phasediff(x1,x2,N)
% Compute phase difference between the periodic signals
if nargin < 3
    ALG = 1;
end

if ALG == 1
    xc = xcorr(x1,x2);
    idx = length(x1);
    out = angle(xc(idx));
elseif ALG == 2
    break;
elseif ALG == 3
    break;
end