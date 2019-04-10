function d=loadbin(fname,vec_len,format)
% function d=loadbin(fname,vec_len,format)
% Load binary data
if nargin < 3
    format = 'float32';
end
if nargin < 2
    vec_len = 1;
end

f = fopen(fname,'r');
d = fread(f,format);
fclose(f);
d = reshape(d,vec_len,[])';

