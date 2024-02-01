classdef optparam
    properties (GetAccess = public, SetAccess = private)
        Name;
        Symbol;
        Units;
        Value;
        IsVarying;
    end
    methods (Access = public)
        function obj = optparam(name,symbol,units,value,isvarying)
            arguments
                name (1,1) string;
                symbol (1,1) string;
                units (1,1) string;
                value double {mustBeScalarOrEmpty} = double.empty(0,1);
                isvarying (1,1) logical = false;
            end
            obj.Name = name;
            obj.Symbol = symbol;
            obj.Units = units;
            obj.Value = value;
            obj.IsVarying = isvarying;
        end
        function optparam_sym = sym(obj)
            optparam_sym = sym(obj.Symbol);
        end
    end
end