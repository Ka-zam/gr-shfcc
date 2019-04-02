function [f,ac] = amest(X,Alg,Q)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This is an implemenation of Aboutanios and Mulgrew (A&M) Estimators from the 
% following reference:
%
% [1]. E. Aboutanios and B. Mulgrew, "Iterative Frequency Estimation by 
%      Interpolation on Fourier Coefficients", IEEE Transactions on Signal
%      Processing, vol. 53, no. 4, pp. 1237-1242, April 2005.
%
%
% Input: 
%   X       Complex input signal vector (row or column). If X is a matrix, the estimator is
%   applied down the columns.
%   Alg    Algorithm to use: If Alg=1, the first algorithm is used (that is
%   the default), if Alg=2, the second is used.
%   Q       The number of iterations to run (default = 2).
% Output:
%   f       Normalised frequency estimate (-0.5<=f<0.5)
%   m     Index of the maximum bin (-N/2:N/2-1)
%   d      Matrix of residuals (-0.5<=d<0.5).
%
% Copyright by Dr. E. Aboutanios, 03/2011.
%
% Email: elias@ieee.org
%
% Version: v1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Error checking for the input parameters to the A&M estimator
if nargin < 1
     error('Function must have at least one input. Type help amest for instructions.');
elseif nargin==1
    Alg = 1;
    Q = 2;
elseif nargin == 2
    Q = 2;
end

[N,M] = size(X);

if (N==1) && (M>1)
    X = X(:);
    N = M;
    M = 1;
end

nv = (0:N-1).';

%---------------------------------------------------
%Iterative A&M Algorithm - Q iterations
%---------------------------------------------------

Y = fft(X); %Obtain the DFT

[~,m] = max(abs(Y)); %Find maximum bin


mh = m-1;  %adjust from MATLAB notation to actual index

d = zeros(Q,M);
ac = zeros(Q,M);

Xn = exp(-1i*2*pi*nv*(mh-0.5)/N).*X;
Xp = exp(-1i*2*pi*nv*(mh+0.5)/N).*X;
 
 for niter = 1:Q
    
    D = exp(-1i*2*pi*nv*sum(d)/N);
    Yn = sum(D.*Xn);
    Yp = sum(D.*Xp);

    if Alg == 1
        d(niter,:) =  0.5*real((Yp+Yn)./(Yp-Yn));
    elseif Alg == 2
        d(niter,:) =  0.5*(abs(Yp)-abs(Yn))./(abs(Yp)+abs(Yn));
    end
    % Amplitude estimate
    alpha = 1j*pi/N./( 1 + exp(1j*2*pi*d(niter,:)) );
    %ac( niter , : ) = mean( Yp.*( d(niter,:) + .5 ) + Yn.*( d(niter,:) - .5 ) ).*alpha;
    acp( niter , : ) =  Yp.*( d(niter,:) + .5 ) ;
    acn( niter , : ) =  Yn.*( d(niter,:) - .5 ) ;
    ac( niter , : )  = ( acp(niter,:) + acn(niter,:) ).*alpha;

 end

m = (mh>=N/2).*(mh-N)+(mh<N/2).*mh; %Calculate the index between -N/2 and N/2-1

f = (m+sum(d))/N;
ac = ac( Q , : );