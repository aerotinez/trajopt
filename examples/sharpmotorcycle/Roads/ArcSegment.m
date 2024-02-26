classdef ArcSegment < RoadSegment
properties (GetAccess = public, SetAccess = protected)
    Radius;
    Angle;
end
methods (Access = public)
function obj = ArcSegment(Length,Radius,Direction)
    obj.Parameter = linspace(0,Length,Length + 1);
    obj.Direction = Direction;
    circ = @(t)Radius.*[cos(t);sin(t);0.*t];
    obj.Radius = Radius;
    ang = Length/Radius;
    obj.Angle = rad2deg(ang);
    parameter_vector = linspace(pi/2 - ang,pi/2,numel(obj.Parameter));
    obj.Data = fliplr(circ(parameter_vector) - [0;Radius;0]);
    obj.Length = Length;
    FS = FrenetSerret(circ(sym('t')),sym('t'));
    rotation_matrix = matlabFunction(FS.RotationMatrix);
    obj.ComputeHeading(rotation_matrix,linspace(0,ang,numel(obj.Parameter)));
    obj.Heading = -obj.Heading + 90;
    curvature = matlabFunction(FS.Curvature);
    obj.Curvature = curvature().*ones(1,numel(obj.Parameter));
    obj.SetDirection();
end
end 
end