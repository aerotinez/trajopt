classdef CurveSegment < RoadSegment
    properties (Access = protected)
        Formula;
        FS;
        fRotationMatrix;
        fCurvature;
    end
    methods (Access = protected)
        setFrenetSerretFormulae(obj);
        setHeading(obj);
        setCurvature(obj);
    end
    methods (Access = protected, Abstract)
        initData(obj);
        setFormula(obj);
    end
end