function out = fftsym( f_p , f_s , x )
% Generate a corrected symbol clock from a 
% pilot tone. samples in x

pha_adv_ratio = f_s/f_p;
pha_inst = 0.;
out  = zeros( size(x) );

period_est = 6; %16kHz sampled at 96e3;
period_start = 0;
%Per sample phase advance
pha_adv = 2*pi/period_est*pha_adv_ratio;

for ii=1:length(x)
    if x(ii) < 0. && x(ii+1) > 0.
        %Positive zero crossing
        tmp = zerocross( ii , x(ii) , x(ii+1) );
        period_est = tmp - period_start;
        period_start = tmp;
        pha_adv = 2*pi/period_est*pha_adv_ratio;
    end
    out(ii) = cos( pha_inst );
    pha_inst = pha_inst + pha_adv;
end

function alpha = zerocross( idx , xn , xnp1 )
alpha = idx - xn/(xnp1-xn);
    
