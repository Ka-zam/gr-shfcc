function c = spiralqamconst( R , M )

m = [1:M]';
tm = sqrt( (4*pi*m).^2*R/2 + sqrt( (4*pi*m).^2*R^2/4 + (4*pi*m).^2 ) );

c = tm.*exp(1j*tm);
n = sqrt( sum(c.*conj(c))/length(c) );
c = c/n;
%c = c/max(abs(c));