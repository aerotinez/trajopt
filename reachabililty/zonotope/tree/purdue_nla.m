close("all"); clear; clc;

n = 3;
m = 4;

c = zeros(n,1);

G = [0.1,0.2,3;
    1,2,1;
    -1,2,-1;
    -0.5,-0.4,1
    ].';

v = minkowskiVertices(G);
P = cellfun(@(g)pnplane(c,g),num2cell(G,1));
Pc = P(nchoosek(1:size(G,2),2));
I = arrayfun(@intersection,Pc(:,1),Pc(:,2),"uniform",0);
fl = @(f)[f(-2),f(2)]./vecnorm([f(-2),f(2)],2,1);
l = cellfun(fl,I,"uniform",0);
lplot = @(l)plot3(l(1,:),l(2,:),l(3,:),'k',"LineWidth",2);

fig = myFigure();
plotGenerators(G./vecnorm(G,2,1));
f = @(g,c)plotPlane(pnplane(zeros(n,1),g),mcolor(c));
cellfun(f,num2cell(G,1),cellstr('boyp'.').')
hold on;
cellfun(lplot,l);
hold off;
view(3);

function P = pnplane(c,g)
    arguments
        c (:,1) double;
        g (:,1) double;
    end
    n = g./norm(g);
    P = struct('n',n.','r0',c.');
end

function l = intersection(Pa,Pb)
    d = cross(Pa.n,Pb.n);

    fA = @(k)[
        Pa.n(k);
        Pb.n(k)
        ];

    b = [
        dot(Pa.n,Pa.r0);
        dot(Pb.n,Pb.r0);
        ];

    n = numel(Pa.n);
    fk = @(k)ismember(1:n,k);
    k = cell2mat(cellfun(fk,num2cell(nchoosek(1:n,n - 1),2),"uniform",0));

    r0 = zeros(size(Pa.r0));
    for i = 1:size(k,1)
        A = fA(k(i,:));
        if det(A) ~= 0
            r0(k(i,:)) = A\b;
            break;
        end
    end
    l = @(t)r0(:) + t.*d(:);
end

function plotPlane(P,c)
    a = linspace(-pi,pi,360);
    x = cos(a);
    y = sin(a);
    r = [x;y];
    d = dot(P.n,P.r0);
    z = (d - P.n(1:end - 1)*r)./P.n(end);
    v = [r;z];
    v = v./vecnorm(v,2,1);
    px = v(1,:);
    py = v(2,:);
    pz = v(3,:);
    axe = gca;
    hold(axe,"on");
    fill3(axe,px,py,pz,'k',"FaceColor",c,"FaceAlpha",1,"LineWidth",2);
    hold(axe,"off");
end

function fig = myFigure()
    fig = figure();
    axe = axes(fig);
    axis(axe,"equal");
    box(axe,"on");
    xlabel(axe,"x (m)");
    ylabel(axe,"y (m)");
    zlabel(axe,"z (m)");
end

function plotGenerators(G)
    axe = gca;
    ca = 'boypgcr';
    c = cellstr(arrayfun(@mcolor,ca(1:size(G,2))));
    switch size(G,1)
        case 2
            f = @(g,c)quiver(0,0,g(1),g(2), ...
                "Color",c, ...
                "AutoScale","off", ...
                "MaxHeadSize",1, ...
                "LineWidth",2);
        case 3
            f = @(g,c)quiver3(0,0,0,g(1),g(2),g(3), ...
                "Color",c, ...
                "AutoScale","off", ...
                "MaxHeadSize",1, ...
                "LineWidth",2);
            view(axe,3);
    end
    hold(axe,"on");
    cellfun(f,num2cell(G,1),c);
    hold(axe,"off");
end

function plotVertices(v)
    axe = gca;
    hold(axe,"on");
    switch size(v,1)
        case 2
            scatter(axe,v(1,:),v(2,:),"filled");
        case 3
            scatter3(axe,v(1,:),v(2,:),v(3,:),"filled");
            view(axe,3);
            camproj(axe,"perspective");
    end
    hold(axe,"off");
end