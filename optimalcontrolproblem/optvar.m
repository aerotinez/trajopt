classdef optvar < handle
    properties (GetAccess = public, SetAccess = private)
        Name;
        Symbol;
        UnitName;
        Units;
        Initial;
        Final;
        LowerBound;
        UpperBound;
    end
    methods (Access = public)
        function obj = optvar(name,symbol,unit_name,units,initial,final,lower_bound,upper_bound)
            arguments
                name (1,1) string;
                symbol (1,1) string;
                unit_name (1,1) string = "";
                units (1,1) string = "";
                initial double {mustBeScalarOrEmpty} = double.empty(0,1);
                final double {mustBeScalarOrEmpty} = double.empty(0,1);
                lower_bound (1,1) double = -inf;
                upper_bound (1,1) double = inf;
            end
            obj.Name = name;
            obj.Symbol = symbol;
            obj.UnitName = unit_name;
            obj.Units = units;
            obj.Initial = initial;
            obj.Final = final; 
            obj.LowerBound = lower_bound;
            obj.UpperBound = upper_bound;
        end 
        function setSymbol(obj,symbol)
            arguments
                obj (1,1) optvar;
                symbol (1,1) string;
            end
            obj.Symbol = symbol;
        end
        function optvar_symbol = sym(obj)
            optvar_symbol = str2sym(obj.Symbol);
        end
    end
end
