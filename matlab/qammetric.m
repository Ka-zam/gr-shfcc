function [err,symbols_hat] = qammetric( rf , eps , tau , input )

rf=rf(:);
fc_hat  = input.fc*(1+eps);
sps_hat = input.sps/(1+eps); 
%input.beta 
%input.tau
%input.amp 
%input.phi
%input.constellation

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
bb = bb( floor(length(Brrc)) : end );

%Get symbols
symbols_hat = interp1( bb , [1+tau : sps_hat : length(bb) ] );

err = sum(symbols_hat.*conj(symbols_hat))/length(symbols_hat);

%Compute EVM
evm = zeros( size(symbols_hat) );

for k=1:length(symbols_hat)
    % ML decode
    tmp = input.constellation - symbols_hat(k);
    tmp = tmp.*conj(tmp);
    [~,idx] = min( tmp );
    evm(k) = abs( symbols_hat(k) - input.constellation(idx)  );
end

const_mean_pwr = mean(abs(input.constellation));

err = err + 1j*mean(evm)/const_mean_pwr*100;