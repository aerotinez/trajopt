classdef ClothoidSegment < RoadSegment
properties (GetAccess = public, SetAccess = protected)
    StartRadius;
    EndRadius;
end
properties (Access = private) 
    Theta;
    Circ;
    ClothoidRate;
end
methods (Access = public)
function obj = ClothoidSegment(Length,start_radius,end_radius,Direction)
    if ~any(start_radius) || ~any(end_radius)
        str_a = "Start/end radius entered cannot be zero. ";
        str_b = "If a segment has zero curvature, ";
        str_c = "enter it's radius as inf.";
        error(strcat(str_a,str_b,str_c));
    end
    obj.Parameter = linspace(0,Length,Length + 1);
    obj.Direction = Direction;
    obj.Length = Length;
    obj.StartRadius = start_radius;
    obj.EndRadius = end_radius;

    BigCurvature = @(ka,kb)sum([ka > kb,kb > ka].*[ka,kb]);
    SmallCuravture = @(ka,kb)sum([ka < kb,kb < ka].*[ka,kb]);

    L = obj.Length;
    kf = BigCurvature(1/start_radius,1/end_radius);
    k0 = SmallCuravture(1/start_radius,1/end_radius); 
    obj.Theta = @(t)-[k0,(kf - k0)/(2*L)]*[t;t.^2];
    obj.Circ = @(t)[cos(t);sin(t);0.*t];
    obj.ClothoidRate = @(t,y)obj.Circ(obj.Theta(t));
    parameter_vector = linspace(0,L,numel(obj.Parameter));
    obj.Data = obj.ComputeClothoid(parameter_vector);

    var = sym('t');
    FS = FrenetSerret(int(obj.ClothoidRate(var),var),var);
    rotation_matrix = matlabFunction(FS.RotationMatrix); 
    curvature = matlabFunction(FS.Curvature);
            
    obj.Curvature = curvature(parameter_vector); 
    obj.ComputeHeading(rotation_matrix,parameter_vector);
    obj.Heading = rad2deg(wrapToPi(deg2rad(obj.Heading)));

    if end_radius > start_radius
        obj.Data = rotz(obj.Heading(end))*([-1;1;1].*obj.Data);
        obj.Data = fliplr(obj.Data - obj.Data(:,end));
        obj.Curvature = fliplr(obj.Curvature);
        % obj.Heading = fliplr(180 - obj.Heading);
    end
    obj.SetDirection(); 
end
end
methods (Access = private) 
function clothoid = ComputeClothoid(obj,parameter_vector) 
    [~,y] = ode45(obj.ClothoidRate,parameter_vector,zeros(3,1));
    clothoid = y.';
end 
end 
end