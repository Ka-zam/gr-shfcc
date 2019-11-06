function [p,f] = fftspec(x,flag)

if nargin < 2
    flag = 'half';
end

%p = db(abs( fftshift( fft ( x ) ) ));
if strcmp(flag,'whole')
    p = abs(  fft ( x )  )/length(x);
    p = db(p);
    p = fftshift(p);
    f = linspace(-.5 , .5 , length(p) );
else
    p = fft(x);
    p = p(1:ceil(length(x)/2));
    p = abs(p)/length(p);
    p = db(p);
    f = linspace(0 , .5 , length(p) );
end