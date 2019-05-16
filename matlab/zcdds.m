function out = zcdds( x , f_ref , f_out )

% function out = zcdds(x , f_ref , f_out )
% Generate frequency with DDS from a given reference and ratio


%Pre-allocate for speed
out = zeros( length(x) , 1 );

start_pha = 0;
out_pha_inc = 2*pi*f_out;
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