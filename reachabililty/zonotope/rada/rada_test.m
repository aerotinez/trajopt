close("all"); clear; clc;

s = (1 + sqrt(5))/2;

rng(20)
N = 1;
G = -N + 2*N.*rand(3,9);

tic;
I = IncrementalEnumeration(G);
toc;

pa = G*I.X';
pa = pa(:,unique(reshape(convhull(pa.'),[],1)));

f = @(p)scatter3(p(1,:),p(2,:),p(3,:),'r',"filled");
fig = sphereFigure();
hold on
plot(zonotope(zeros(3,1),G),1:3);
f(pa);
hold off
light("Position",[-100,0,100]);
camproj("perspective");