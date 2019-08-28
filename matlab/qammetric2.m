function [err,symbols_hat] = qammetric( vars , in )

% input = 
% 
%   struct with fields:
% 
%                fc: 2500
%               sps: 24
%              beta: 0.2000
%               tau: 0
%               eps: 0
%               rot: 0.2723 - 0.4193i
%     constellation: [1×16 double]
%      pilotsymbols: 1.5000
%       pilotperiod: 4
%                fs: 96000
%



rf=rf(:);
fc_hat  = in.fc*(1+in.eps/1000.);
sps_hat = in.sps/(1+eps/1000); 


%Prepare and downconvert passband signal
t = linspace(0,(length(rf)-1)/input.fs,length(rf))';
rf = hilbert( rf );
carrier = exp(-1j*(2*pi*fc_hat*t));
bb = rf.*carrier;
%bb = bb*input.amp*exp(1j*input.phi);
bb = bb*input.rot;

%Filter
Brrc = rcosdesign( input.beta , rrcspan(input.beta) , input.sps , 'sqrt');
bb = filter( Brrc , 1/sum(Brrc) , bb );
bb = bb( floor(length(Brrc)*.5) : end );

%Get symbols
symbols_hat = interp1( bb , [1+tau : sps_hat : length(bb) ] );

err = sum(symbols_hat.*conj(symbols_hat))/length(symbols_hat);

%Compute EVM
evm = zeros( size(symbols_hat) );

all_symbols =  [input.constellation input.pilotsymbols ];
for k=1:length(symbols_hat)
    % ML decode
    tmp = all_symbols - symbols_hat(k);
    tmp = tmp.*conj(tmp);
    [~,idx] = min( tmp );
    evm(k) = abs( symbols_hat(k) - all_symbols(idx)  );
end

const_mean_pwr = mean(abs(input.constellation));

err = err + 1j*mean(evm)/const_mean_pwr*100;