classdef ArcSegment < CurveSegment
    properties (GetAccess = public, SetAccess = protected)
        Radius;
        Angle;
    end
    methods (Access = public)
        function obj = ArcSegment(arclength,radius,dir)
            arguments
                arclength (1,1) double {mustBeNumeric}
                radius (1,1) double {mustBeNumeric}
                dir (1,1) string {mustBeMember(dir,["left","right"])}
            end
            obj@CurveSegment(arclength);
            obj.Radius = radius;
            obj.Length = arclength;
            obj.Angle = arclength/radius;
            obj.setFormula();
            obj.initData();
            obj.recenter();
            obj.toNED();
            obj.setFrenetSerretFormulae();  
            obj.setHeading();
            obj.setCurvature();
            obj.setDirection(dir);
        end
    end
    methods (Access = private)
        function s = arcLength(obj)
            s = linspace(0,obj.Angle,obj.Length + 1);
        end 
        function recenter(obj)
            tform = rigidtform3d(eye(3),obj.Data(:,1));
            obj.Data = transformPointsInverse(tform,obj.Data.').';
        end
        function toNED(obj)
            tform = rigidtform3d(rotz(90),zeros(3,1));
            obj.Data = transformPointsInverse(tform,obj.Data.').';
        end 
    end
    methods (Access = protected)
        function initData(obj)
            obj.Data = obj.Formula(obj.arcLength());
        end
        function setFormula(obj)
            obj.Formula = @(s)obj.Radius.*[cos(s);sin(s);0.*s];
        end
        function setHeading(obj)
            setHeading@CurveSegment(obj,obj.arcLength());
            obj.Heading = obj.Heading - 90;
        end
        function setCurvature(obj)
            setCurvature@CurveSegment(obj,obj.arcLength());
        end
    end
end