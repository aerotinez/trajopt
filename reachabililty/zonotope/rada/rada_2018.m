close("all"); clear; clc;

rng(2)
n = rand(3,1);
n = n./norm(n);
r0 = zeros(3,1);

d = n.'*r0;

a = linspace(-pi,pi,1000);
P0 = [
    cos(a);
    sin(a)
    ] + r0(1:2);

z = (d - n(1:end - 1).'*P0)./n(end);

P = [P0;z];
P = P./vecnorm(P,2,1);
c = sum(P,2)./size(P,2);

fig = figure();
axe = axes(fig);
hold(axe,"on");
fill3(axe,P(1,:),P(2,:),P(3,:),'k', ...
    "FaceColor",mcolor('b'), ...
    "FaceAlpha",0.5, ...
    "LineWidth",2);
quiver3(axe,c(1),c(2),c(3),n(1),n(2),n(3), ...
    "AutoScale","off", ...
    "MaxHeadSize",10, ...
    "LineWidth",2, ...
    "Color",mcolor('b'));
scatter3(axe,c(1),c(2),c(3),100,"filled","MarkerFaceColor",mcolor('b'));
hold(axe,"off");
view(axe,3);
axis(axe,"equal");
box(axe,"on");
xlabel(axe,"x (m)");
ylabel(axe,"y (m)");
zlabel(axe,"z (m)");
