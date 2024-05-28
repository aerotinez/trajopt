close("all"); clear; clc;

G = [
    1,1,0;
    1,-1,0;
    1,0,1;
    1,0,-1;
    0,1,1;
    0,1,-1
    ].';

R = ReverseSearchEnumeration(G);
X = R.X;
p = G*X';

X = [zeros(1,size(G,2));(dec2bin(1:2^size(G,2) - 1) - '0')];
X(X == 0) = -1;
p0 = G*X.';

f = @(p)scatter3(p(1,:),p(2,:),p(3,:),"filled");
fig = sphereFigure();
hold on
% f(p0)
f(p)
hold off