function out = symdecpilot( sig )

%Pilot in 2:nd col

sym = sig(:,1);
pil = sig(:,2);

[~,idx] = crossing( pil );

%Construct the downconversion signal


out = interp1( 1:length(sym) , sym , idx );