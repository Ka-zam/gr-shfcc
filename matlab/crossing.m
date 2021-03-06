function out = crossing(x,level)

if nargin == 2
    x = x - level;
end

%Pre-allocate for speed
out = zeros( ceil(length(x)*.5) , 1 );
idx = 1;

for ii=1:length(x)-1
    if abs(x(ii)) < 1e-15
        out(idx) = ii;
        idx = idx + 1;
    elseif abs( sign(x(ii)) - sign(x(ii+1)) ) == 2 %Only trigger on sign change
        % Zero crossing
        out(idx) = ii - x(ii)/( x(ii+1) - x(ii) );
        idx = idx + 1;
    end
end

if idx > 1
    out = out(1:idx-1);
else
    out = [];
end