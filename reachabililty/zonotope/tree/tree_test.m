close("all"); clear; clc;

n = 3;
m = 3;

G = [
    1,sqrt(3),0;
    1,-sqrt(3),0;
    2,0,0;
    0,0,2
    ];

e0 = zeros(1,3);
tic;
V0 = Node(e0,G);
toc;
v = V0.vertices();

fig = figure();
axe = axes(fig);
hold(axe,"on");
scatter3(axe,v(:,1),v(:,2),v(:,3),"filled",'r');
hold(axe,"off");
axis(axe,"equal");
box(axe,"on");
view(axe,3);
camproj(axe,"perspective");