function [kh,kv,H,K,E] = curvatures(geogrid,resolution)
%
[r,t,s,p,q] = partials(geogrid,resolution);

p2q2 = p.^2  + q.^2;
p2r  = p.^2 .* r;
p2t  = p.^2 .* t;
q2t  = q.^2 .* t;
q2r  = q.^2 .* r;
pqs  = p .* q .* s;
rt   = r .* t;
s2   = s.^2;

kh = -(q2r - 2.*pqs + p2t)./ (p2q2 .* (1 + p2q2).^(1/2));
kv = -(p2r + 2.*pqs + q2t)./ (p2q2 .* (1 + p2q2).^(3/2));
K  = (rt - s2) ./ (1 + p2q2).^2;
H  = 1/2 .* (kv + kh);
E  = 1/2 .* (kv - kh);