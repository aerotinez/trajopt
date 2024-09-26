function res = getResult(obj,s,x)
    arguments
        obj (1,1) SharpMotorcycleExtendedExperiment;
        s (:,1) double;
        x double;
    end
    % compute time from progress rate
    xk = [
        s;
        x(1:2,:)
        ];

    uk = x([6,7,5],:);

    scen = obj.Scenario;
    curvature = interp1(scen.Parameter,scen.Curvature,s);
    s_dot = [1,0,0]*roadRelativeKinematics(xk,uk,curvature);
    t = s./s_dot;

    % convert radian states and names to degrees
    idx = contains(obj.Program.Plant.States.getUnits(),"rad");
    x(idx,:) = rad2deg(x(idx,:));
    names = obj.Program.Plant.States.getNames();
    units = strrep(obj.Program.Plant.States.getUnits(),"rad","{\circ}");

    % package results
    res = struct("Time",t, ...
        "Progress",s, ...
        "States",x, ...
        "Names",names, ...
        "Units",units ...
        );
end