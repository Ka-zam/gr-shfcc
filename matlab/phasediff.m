function pha_diff = phasediff(x1,x2)
% function pha_diff = phasediff(x1,x2)
% Compute pahse difference between the periodic signals

xc = xcorr(x1,x2);
[~,idx] = max(abs(xc));
pha_diff= angle(xc(idx));

