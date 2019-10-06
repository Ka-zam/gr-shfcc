function [err,symbols_hat] = pilot_err_metric( vars , in , method )

% vars = [ epsilon tau amp phi ]

% input = 
% 
%   struct with fields:
% 
%                fc: 2500
%               sps: 24
%              beta: 0.2000
%     constellation: [1×16 double]
%      pilotsymbols: 1.5000
%       pilotperiod: 4
%                fs: 96000
%                rf: [ measured data ]
%     

if nargin < 3
    method = 'all';
end

%Vars
eps = vars(1);
tau = vars(2);
amp = vars(3);
phi = vars(4);

fc_hat  = in.fc*(1+eps/1000.);
sps_hat = in.sps/(1+eps/1000); 

t = linspace(0,(length(in.rf)-1)/in.fs,length(in.rf))';
carrier = exp(-1j*(2*pi*fc_hat*t));

if ~in.filtered
    %Prepare and downconvert passband signal
    rf = hilbert( in.rf(:) );
    bb = rf.*carrier;
    bb = bb*amp*exp(1j*phi*pi/180);
    
    %Filter
    bb = filter( in.rrc , 1 , bb );
    bb = bb( floor(length(in.rrc)*.5) : end );
else
    %bb = filter( in.rrc2 , .5 , in.rf );
    bb = in.rf(:).*carrier;
    bb = bb*amp*exp(1j*phi*pi/180);
    %bb = bb( floor(length(in.rrc2)*.5) : end );
end
    
    

%Get symbols
symbols_hat = interp1( bb , [1+tau : sps_hat : length(bb) ] );

%Signal power
err(1) = sum(symbols_hat.*conj(symbols_hat))/length(symbols_hat);

%Compute EVM
evm = zeros( size(symbols_hat) );

all_symbols =  [in.constellation in.pilotsymbol ];
for k=1:length(symbols_hat)
    % ML decode
    tmp = all_symbols - symbols_hat(k);
    tmp = tmp.*conj(tmp);
    [~,idx] = min( tmp );
    evm(k) = abs( symbols_hat(k) - all_symbols(idx)  );
end

const_mean_pwr = mean(abs(in.constellation));

err(2) = mean(evm)/const_mean_pwr*100;

%Pilot EVM
pdist = abs(symbols_hat - in.pilotsymbol);
[~,idx] = sort(pdist);
idx = mod( idx , in.pilotperiod );
idx_start = idx(1);
if idx_start == 0
    idx_start = idx_start + in.pilotperiod;
end
pilot_symbols_hat = symbols_hat( idx_start : in.pilotperiod : end );

pevm = mean(abs( pilot_symbols_hat - in.pilotsymbol ));

err(3) = pevm/const_mean_pwr*100;

if strcmp(method,'pevm')
    err = err(3);
elseif strcmp(method,'evm')
    err = err(2);
elseif strcmp(method,'pwr')
    err = err(1);
end
