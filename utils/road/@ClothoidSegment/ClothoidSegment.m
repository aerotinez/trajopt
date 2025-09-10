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
            setFormula(obj);
            initData(obj);
            setFrenetSerretFormulae(obj);  
            setHeading(obj);
            setCurvature(obj);
            setDirection(obj,dir);
        end
    end
    methods (Access = protected) 
        clothoidRate(obj);
        initData(obj);
        setFormula(obj);
        setHeading(obj);
        setCurvature(obj);
    end 
end