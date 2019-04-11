function out = qamsync( rf , est )
% function out = qamsync( rf , est )
% Estimate:    Carrier frequency, fc
%              Carrier phase    , phac
%              Timing Offset    , tau
%
% Given: rf    An upconverted sample vector
%        est   Best estimate of parameters
%        est.fc      : Carrier frequency
%        est.phac    : - ''  - phase
%        est.locked  : Locked state
%        est.tau     : Timing offset
%        est.sps     : Samples per symbol
%        est.psym    : Pilot symbol
%        est.pper    : Pilot periodicity

