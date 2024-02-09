classdef Unit
    properties (GetAccess = public, SetAccess = private)
        Name;
        Symbol; 
    end
    methods (Access = public)
        function obj = Unit(name,symbol)
            arguments
                name (1,1) string;
                symbol (1,1) string;
            end
            obj.Name = name;
            obj.Symbol = symbol;
        end
    end
end