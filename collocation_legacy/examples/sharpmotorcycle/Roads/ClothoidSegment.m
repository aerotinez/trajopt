classdef ClothoidSegment < CurveSegment
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
        function obj = ClothoidSegment(arclength,r0,rf,dir)
            arguments
                arclength double {mustBePositive};
                r0 double {mustBePositive};
                rf double {mustBePositive};
                dir (1,1) string {mustBeMember(dir,["left","right"])};
            end
            obj@CurveSegment(arclength);
            obj.StartRadius = r0;
            obj.EndRadius = rf;
            obj.setFormula();
            obj.initData();
            obj.setFrenetSerretFormulae();  
            obj.setHeading();
            obj.setCurvature();
            obj.setDirection(dir);
        end
    end
    methods (Access = protected) 
        function dC = clothoidRate(obj,t)
            k0 = 1/obj.StartRadius;
            kf = 1/obj.EndRadius;
            L = obj.Length;
            theta = [k0,(kf - k0)/(2*L)]*[t;t.^2];
            dC = [cos(theta);sin(theta);0.*theta];
        end
        function initData(obj)
            s = obj.Parameter; 
            [~,y] = ode45(@(t,y)obj.clothoidRate(t),s,zeros(3,1));
            obj.Data = y.';
        end
        function setFormula(obj) 
            obj.Formula = @(t)int(obj.clothoidRate(t),t);
        end
        function setHeading(obj)
            setHeading@CurveSegment(obj,obj.Parameter);
        end
        function setCurvature(obj)
            setCurvature@CurveSegment(obj,obj.Parameter);
        end
    end 
end