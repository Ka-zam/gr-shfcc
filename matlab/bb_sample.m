function [bb,sym_idx] = bb_sample(Nsps,Nsym,symbols,snr,M,beta,cfo,cpo,cpn,tau) 

%Nsym = 100*M;
%Nsps =  8;
%beta = .15;
%M = 16;
%Nspan = 10;
P_pt = -20;
f_pt = .10987654;

Nspan = rrcspan( beta );

B = rcosdesign(beta , Nspan , Nsps , 'sqrt');
delay = Nspan*Nsps/2;

%symbols = randi( M , Nsym , 1) - 1;
%Just make sure to start a I=-1 Q=1
%symbols(1:5) = 0;
%symbols(6:10) = 1;
bb = qammod( symbols , M , 'UnitAveragePower', true );
bb = upsample( bb , Nsps );
%Add the delay as zeros at the end to get all the symbols
bb = [ bb; zeros(4*delay,1) ];
bb = filter( B , 1 , bb );
%Add some noise
nse_pwr = 10^(-snr*.05);
nse = nse_pwr/sqrt(2)*( randn( size(bb) ) + 1j*randn( size(bb) ) );
if snr < 95
    bb = bb + nse;
end
%Filter it again on the receive side
bb = filter( B , 1 , bb );

%Carrier Frequency Offset
t = [0:length(bb)-1]';
pha = 2*pi*cfo*t;
%Carrier Phase Offset
pha = pha + cpo*pi/180;

%Carrier phase noise
%pha_pn = zeros(size(pha));
%for k=2:length(pha)
%    pha_pn(k) = pha_pn(k-1) + cpn/180*pi*randn(1);
%end
pha_pn = cumsum( cpn*pi/180*randn( size(pha) ) );
pha = pha + pha_pn;

carrier = exp(1j*pha);
bb = bb.*carrier;

%Pilot tone
pt_amp = 10^(P_pt/20);
pt = pt_amp*exp(1j*2*pi*f_pt*t);
bb = bb + pt;


%Timing Error resampling
bb = interp1( bb , [1:length(bb)]'+tau );

sym_idx = [1+2*delay:Nsps:2*delay+Nsym*Nsps]';

function s = rrcspan( beta )
if beta < 0.2
    s = 30;
elseif beta < 0.65
    s = -floor( beta*44 ) + 33;
    if mod(s,2) == 1
        s = s + 1;
    end
else
    s =  4;   
end
     




