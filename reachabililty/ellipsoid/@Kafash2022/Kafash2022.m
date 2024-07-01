classdef Kafash2022
    properties (GetAccess = public, SetAccess = private)
        Sys;
        Initial;
        Input;
    end
    properties (Access = private)
        NumSteps = 1;
        Epsilon = 1E-03;
    end
    methods (Access = public)
        function obj = Kafash2022(sys,initial_set,input_set)
            arguments
                sys ss;
                initial_set (1,1) ellipsoid;
                input_set (1,1) ellipsoid;
            end
            obj.Sys = sys;
            obj.Initial = initial_set;
            obj.Input = input_set;
        end
    end
end