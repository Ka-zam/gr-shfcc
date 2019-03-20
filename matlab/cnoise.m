function out = cnoise( var , N )
% function out = cnoise( var , N )
% Generate complex noise of variance var and length N

out = sqrt(var*.5)*( randn(N,1) + 1j*randn(N,1) );
