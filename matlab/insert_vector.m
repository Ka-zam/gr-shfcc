function out = insert_vector( x , v , p , TRUNCATE )
% function out = insert_vector( x , v , p , TRUNCATE )
% Insert v into x with periodicity p
% if TRUNCATE length(out) == length(x), default

if nargin < 4
    TRUNCATE = true;
end

%There will always be at least 1 insertion
x = x(:);
v = v(:);

N_insertions = ceil( length(x)/p );

out = zeros( length(x) + N_insertions*length(v) , 1 );
seglen = p + length(v);

for seg = 0:N_insertions-1
    if (seg+1)*seglen > length(out)
        out( seg*seglen+1 : end ) = [v ; x( seg*p+1 : end )];
        break;
    end
    out( seg*seglen+1 : (seg+1)*seglen ) = [ v ; x( seg*p+1 : (seg+1)* p )];
end

if TRUNCATE
    out = out(1:length(x));
end


