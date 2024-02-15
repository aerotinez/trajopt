classdef FixedTime < Time
    methods (Access = public)
        function time = get(obj)
            time = obj.Value;
        end 
    end
end