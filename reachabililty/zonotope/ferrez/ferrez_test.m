close("all"); clear; clc;

rng(10);
G = rand(3,4);

fig = myFigure();

function fig = myFigure()
    fig = figure();
    axe = axes(fig);
    axis(axe,"equal");
    view(axe,3);
    box(axe,"on");
    camproj(axe,"perspective");
    xlabel(axe,"x (m)");
    ylabel(axe,"y (m)");
    zlabel(axe,"z (m)");
end

function c = center(G)
    arguments
        G (3,:) double;
    end
    c = sum(G,2)./2;
end

function P = plane3d(n,r0)
    arguments
        n (3,1) double;
        r0 (3,1) double;
    end
    if norm(n) ~= 1
        n = n./norm(n);
    end
    P = struct('n',n,'r0',r0);
end

function P = intersection(Pa,Pb)
    ha = dot(Pa.n,Pa.r0);
    hb = dot(Pb.n,Pb.r0);
    n = dot(Pa.n,Pb.n);
    ca = (ha - hb.*n)./(1 - n.^2);
    cb = (hb - hb.*n)./(1 - n.^2);
    P = struct('r0',ca.*Pa.n + cb.*Pb.n,'d',cross(Pa.n,Pb.n));
end