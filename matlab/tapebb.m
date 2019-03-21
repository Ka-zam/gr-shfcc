function [bb,rf_out] = tapebb( input )
% Generate a sampled baseband
% input.fs    : sample frequency [Hz]
%      .fup   : upconversion     [Hz]
%      .fdw   : downconversion   [Hz]
%      .bb    : baseband          [V,jV]
%      .rrc   : RRC taps         []
%      .snr   : SNR              [dB]
%      .sps   : Samples per symbol
%      .tau   : Timing Error

if nargin == 0
    input.fs = 96e3;
    input.fup = 6e3;
    input.fdw = 6e3;
    Order = 4;
    Nsym = 64;
    symbols = randi( Order, Nsym , 1) - 1;
    
    input.bb = qammod( symbols , Order , 'UnitAveragePower', true );
    input.snr = 40;
    input.sps = 8;
    input.var0 = 0*0.015;
    input.var3 = 0*0.0045;
    input.rrcspan = 10;
    input.beta = .2;
    input.tau = .002345;
    input.phi = -22.5;
end


% Upsample
bb = upsample( input.bb , input.sps );

% Pad with zeroes to get filter output
bb = [bb; zeros((input.sps+1)*input.rrcspan,1) ];

% Pulse shaping
Brrc = rcosdesign( input.beta , input.rrcspan , input.sps , 'sqrt');
bb = filter( Brrc , 1 , bb );

% Upconvert
carrier = cexppn( input.fup , input.fs , input.var0 , input.var3 , length(bb) );
rf = real(bb.*carrier);

% Add noise
%noise = cnoise( 10^( -input.snr*.1 ) , length(rf) );
noise = 10^( -input.snr*.1 )*randn(  length(rf) , 1 );
rf = rf + noise;

%Save for output
rf_out = rf;

% Downconvert
t = linspace(0,(length(rf)-1)/input.fs,length(rf))';
rf = hilbert( rf );
carrier = exp(-1j*(2*pi*input.fdw*t + input.phi/180*pi));
bb = rf.*carrier;

%Filter
bb = filter( Brrc , 1 , bb );

if input.tau > 0.0
    %bb = [0 ;bb];
    bb = interp1( bb , [input.tau : 1 : length(bb) ] );
    bb = [bb(2:end)'; 0];
end