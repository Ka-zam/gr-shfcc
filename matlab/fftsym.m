function [out,period_est] = fftsym( f_p , f_s , x )
% Generate a corrected symbol clock from a 
% pilot tone. samples in x

pha_adv_ratio = f_s/f_p;
pha_inst = 1.;

period_est(1) = 96/f_p; %fs = 96e3;
period_start = 0;
lag=2*ceil(period_est(end));
out  = zeros( length(x)+lag,1 );

%Per sample phase advance
pha_adv = 2*pi/period_est(end)*pha_adv_ratio;

for ii=1:length(x)-1
    if sign(x(ii)) ~= sign(x(ii+1))
        % Zero crossing
        tmp = zerocross( ii , x(ii) , x(ii+1) );
        period_est(end+1) = 2*(tmp - period_start);
        period_start = tmp;
        pha_adv = 2*pi/period_est(end)*pha_adv_ratio;
    end
    out(ii+1*lag-1) = cos( pha_inst );
    pha_inst = pha_inst + pha_adv;
end
out( length(x) ) = cos( pha_inst );
%period_est = avg2(period_est);


function alpha = zerocross( idx , xn , xnp1 )
alpha = idx - xn/(xnp1-xn);

function out = avg2(x)
out = movsum(x,2);
out = .5*out(2:2:end);

    
