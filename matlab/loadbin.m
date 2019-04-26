function d=loadbin(fname,vec_len,format)
% function d=loadbin(fname,vec_len,format)
% Load binary data

if nargin < 3
    format = 'float32';
end
    
if strcmp(format,'fc32')
    ISCOMPLEX = true;
    format = 'float32';    
else
    ISCOMPLEX = false;
end
    
if nargin < 2
    vec_len = 1;
end

f = fopen(fname,'r');
d = fread(f,format);
fclose(f);
d = reshape(d,vec_len,[])';
if ISCOMPLEX
    d = d(1:2:end,:) + 1j*d(2:2:end,:);
end