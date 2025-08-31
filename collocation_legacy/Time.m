classdef Time < handle
    properties (GetAccess = public, SetAccess = protected)
        Name;
        Unit;
        Value; 
    end 
    methods (Access = public)
        function obj = Time(name,unit,value)
            arguments
                name (1,1) string;
                unit (1,1) Unit;
                value (1,1) double; 
            end
            obj.Name = name;
            obj.Unit = unit;
            obj.Value = value;
        end 
    end
    methods (Access = public, Abstract)
        time = get(obj);
    end 
end