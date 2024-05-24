close("all"); clear; clc;

G = [
    1,1,0;
    1,-1,0;
    1,0,1;
    1,0,-1;     
    0,1,1;
    0,1,-1
    ].';

[n,m] = size(G);

x = [zeros(m,1),(dec2bin(1:2^m - 1) - '0').'];
x(x == 0) = -1;
v = G*x;

vh = v(:,unique(reshape(convhull(v.'),1,[])));
[vk,k] = setdiff(v.',vh.',"rows","stable");
idx = ismember(1:size(v,2),k.');

fig = sphereFigure();
hold on
scatter3(v(1,:),v(2,:),v(3,:),'r',"filled");
scatter3(vh(1,:),vh(2,:),vh(3,:),'k',"filled");
hold off
