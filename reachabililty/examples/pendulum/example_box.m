close("all"); clear; clc;

n = 2;
m = 20;
rng(22);
N = 1;
G = -N + 2*N.*rand(n,m);
c = ones(n,1);

ma = 10;
z = zonotope(c,G);
zb = box(z);
zoa = reduce(z,'girard',ma/n);
zua = reduceUnderApprox(z,'linProg',ma/n);

vz = vertices(z);
vb = vertices(zb);
voa = vertices(zoa);
vua = vertices(zua);

lw = 1.5;

fig = figure();
axe = axes(fig);
hold(axe,"on");
plot(polyshape(vb.'),"LineWidth",lw,"FaceAlpha",1);
plot(polyshape(voa.'),"LineWidth",lw,"FaceAlpha",1);
plot(polyshape(vz.'),"LineWidth",lw,"FaceAlpha",1);
plot(polyshape(vua.'),"LineWidth",lw,"FaceAlpha",1);
hold(axe,"off");
axis(axe,"equal");
box(axe,"on");
title("Zonotope approximations","FontSize",20)
str = [
    "box (m = n)";
    sprintf("over (m = %d)",ma);
    sprintf("none (m = %d)",m);
    sprintf("under (m = %d)",ma)
    ];
lg = legend(cellstr(str),"FontSize",16);
lg.ItemTokenSize = [15,15];
lg.Location = "northwest";
lg.Orientation = "vertical";
fig.Position = [640,240,640,480];
xlim([-26,12.5])
ylim([-12.5,12.5])

saveas(fig,"zono_approx",'epsc');
