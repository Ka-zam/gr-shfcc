function [err,beta] = nsinest(x,fap,eps)
% [f,a,p] = nsinest(Nsin,Npts,f0,fap)
% Estimate Nsin sinusoids in noise with fixed 
% frequency relation
% fap = [ f0 a0 p0
%         f1 a1 p1 
%          .  .  . ]

%freq = fap(:,1);

%myfun = @(x)

x=x(:);
f=fap(:)';
%w = 2*pi*f;
% 
% Nx = length(x);
% Nf = length(f);
% b = repmat( (1:Nx)' , 1 , Nf );
% b = 1j*b.*w;
% b = exp(b);

% err = zeros(length(eps),1);
% for i=1:length(eps)
%     err(i) = freqerr(x,f*(1+eps(i)));
% end

f1 = f(1);
r = zeros(length(f)-1,1);
for k=1:length(f)-1
    r(k) = f(k+1)/f1;
end

err = zeros(length(eps),1);
for i=1:length(eps)
    err(i) = freqerr2(x,f1*(1+eps(i)) , r);
end

[~,i]=max(err);
[~,beta_hat]=freqerr2(x,f1*(1+eps(i)) , r);

for k=1:length(beta_hat)
    fprintf("Amp: %9.3f  Phase: %9.3f\n",abs(beta_hat(k)),angle(beta_hat(k))*180/pi )
end
beta=beta_hat;


function e = amperr(fap,x,eps)
x=x(:);
a=a(:)';
f=f(:)';
p=p(:)';

t = (0:numel(x)-1)';
p = p/180*pi;

s = sum(a.*cos(eps*freq.*(2*pi*t+p)),2);
e = sum((x-s).^2);

function e = freqerr0(x,f)
w = 2*pi*f;

Nx = length(x);
Nf = length(f);
B = repmat( (1:Nx)' , 1 , Nf );
%B = repmat( (0:Nx-1)' , 1 , Nf );
B = 1j*B.*w;
B = exp(B);
e = x'*B*inv(B'*B)*B'*x;

function e = freqerr1(x,f)
w = 2*pi*f;
w=upsample(w,2);

Nx = length(x);
Nf = length(f);
B = repmat( (1:Nx)' , 1 , 2*Nf );
B(:,2) = -B(:,2);
B(:,4) = -B(:,4);
B = 1j*B.*w;
B = exp(B);
e = x'*B*inv(B'*B)*B'*x;

function [e,beta] = freqerr2(x,f1,r)
% For known relations between frequencies 
% fr = [ f1 r2 r3 ... ]
Nf = length(r)+1;
Nx = length(x);

w = zeros(1,Nf);
w(1) = 2*pi*f1;
for k=1:length(r)
    w(k+1) = 2*pi*f1*r(k);
end

B = repmat( (0:Nx-1)' , 1 , Nf );
B = 1j*B.*w;
B = exp(B);
e = x'*B*( (B'*B)\(B'*x) );
if nargout == 2
    beta = (B'*B)\(B'*x);
end

