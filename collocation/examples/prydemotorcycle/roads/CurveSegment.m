classdef CurveSegment < RoadSegment
    properties (Access = protected)
        Formula;
        FS;
        fRotationMatrix;
        fCurvature;
    end
    methods (Access = protected)
        function setFrenetSerretFormulae(obj) 
            obj.FS = FrenetSerret(obj.Formula);
            t = obj.FS.Parameter;
            R = obj.FS.RotationMatrix;
            k = obj.FS.Curvature;
            obj.fRotationMatrix = matlabFunction(R,'Vars',{t});
            obj.fCurvature = matlabFunction(k,'Vars',{t});
        end
        function setHeading(obj,s)
            arguments
                obj (1,1) CurveSegment;
                s (1,:) double;
            end
            fz = @(x)x(1);
            f = @(s)rad2deg(fz(rotm2eul(obj.fRotationMatrix(s))));
            obj.Heading = arrayfun(f,s);
        end
        function setCurvature(obj,s)
            arguments
                obj (1,1) CurveSegment;
                s (1,:) double;
            end
            obj.Curvature = arrayfun(obj.fCurvature,s);
        end
    end
    methods (Access = protected, Abstract)
        initData(obj);
        setFormula(obj);
    end
end