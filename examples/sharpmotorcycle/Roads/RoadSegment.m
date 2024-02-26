classdef RoadSegment < handle
properties (GetAccess = public, SetAccess = protected)
    Parameter = [];
    Data;
    Length;
    Heading;
    Curvature;
    Direction; 
end
methods (Access = public)
function Translate(obj,distance)
    obj.Data = obj.Data + distance;
end
function Rotate(obj,angle)
    obj.Data = rotz(angle)*obj.Data;
    obj.Heading = obj.Heading + angle;
end
function Plot(obj)
    plot(obj.Data(1,:),obj.Data(2,:));
    view([90,-90]);
    set(gca,'Ydir','reverse');
    title('Road segment');
    xlabel('x(m)');
    ylabel('y(m)');
    axis('equal'); 
end
function SetDirection(obj)
    str = string(obj.Direction);
    if str ~= "Left" && str ~= "Right"
        error("Invalid direction entered for road segment.");
    end
    if str == "Left"
        obj.Data = [1;-1;1].*obj.Data;
        obj.Heading = -obj.Heading;
        obj.Curvature = -obj.Curvature;
    end
end
function ComputeHeading(obj,RotationMatrix,ParameterVector)
    s = num2cell(reshape(ParameterVector,1,1,[]));
    R = cellfun(RotationMatrix,s,'uniform',0);
    heading = cellfun(@(R)atan2d(R(2,1),R(1,1)),R,'uniform',0);
    obj.Heading = reshape(cell2mat(heading),1,[]);
end
end
end