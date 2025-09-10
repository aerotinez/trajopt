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
            setFormula(obj);
            initData(obj);
            recenter(obj);
            toNED(obj);
            setFrenetSerretFormulae(obj);  
            setHeading(obj);
            setCurvature(obj);
            setDirection(obj,dir);
        end
    end
    methods (Access = protected)
        initData(obj);
        setFormula(obj);
        setHeading(obj);
        setCurvature(obj);
    end
    methods (Access = private)
        s = arcLength(obj);
        recenter(obj);
        toNED(obj);
    end
end