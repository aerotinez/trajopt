function fig = plotScenario(scen,results)
    arguments
        scen (1,1) Road;
        results (:,1) struct;
    end
    scen.Show();
    fig = gcf;
    arrayfun(@(r,c)helper(fig,scen,r,c),results,'krb'.');
    axe = gca;
    view(axe,-90,1.5); 
    box(axe,"on");
    camproj(axe,"perspective");
    xlim(axe,[-7,scen.Data(1,end) + 7]);
    y = [scen.Data(2,1),scen.Data(2,end)];
    ylim(axe,[min(y) - 7,max(y) + 7]);
    zlim(axe,[0,3]);
    set(fig,"Position",[960,360,640,480]);
    
    names = {
        '';
        '';
        '';
        '';
        '';
        'big sports';
        '';
        '';
        'cruiser';
        '';
        '';
        'touring'
        };
    
    legend(names{:}, ...
        "NumColumns",3, ...
        "FontSize",12, ...
        "Location","SouthOutside", ...
        "Box","on");
end

function fig = helper(fig,scen,result,color)
    r = result.Trajectory;
    n2c = @(x)num2cell(x,1);
    s = r.Progress;
    yaw_road = interp1(scen.Parameter,scen.Heading,s);
    offset = r.States(1,:);
    f = @(i)interp1(scen.Parameter,scen.Data(i,:),s);
    pr = cell2mat(arrayfun(f,(1:3).',"uniform",0));
    hold(fig.Children,"on");
    f = @(p,a,d)rotz(a)*[0;d;0] + p;
    p0 =  cell2mat(cellfun(f,n2c(pr),n2c(yaw_road),n2c(offset),"uniform",0));
    plot3(p0(1,:),p0(2,:),p0(3,:),color,"LineWidth",2);
    yaw = r.States(2,:) + yaw_road;
    lean = -r.States(3,:);
    pitch = 0.*yaw;
    angles = deg2rad([yaw;lean;pitch]);
    f = @(p,a)p + angle2dcm(a(1),a(2),a(3),'ZXY')*[0;0;3];
    p = cell2mat(cellfun(f,num2cell(p0,1),num2cell(angles,1),"uniform",0));
    plot3(p(1,:),p(2,:),p(3,:),color,"LineWidth",2);
    X = [p0(1,:);p(1,:)];
    Y = [p0(2,:);p(2,:)];
    Z = [p0(3,:);p(3,:)];
    surf(X,Y,Z,"FaceColor",color,"EdgeColor","none","FaceAlpha",0.25);
    hold(fig.Children,"off");
end