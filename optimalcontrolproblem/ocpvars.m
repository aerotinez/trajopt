classdef ocpvars < handle
    properties (GetAccess = public, SetAccess = private)
        Variable;
        State;
        Control;
        NumStates;
        NumControls;
    end
    methods
        function obj = ocpvars(variable,state,control)
            arguments
                variable (1,1) optvar;
                state (:,1) optvar;
                control (:,1) optvar;
            end
            obj.Variable = variable;
            obj.State = state;
            obj.Control = control;
            obj.NumStates = numel(state);
            obj.NumControls = numel(control);
            t = obj.Variable.Symbol;
            f = @(z)z.setSymbol(sprintf("%s(%s)",z.Symbol,t));
            arrayfun(f,obj.State);
            arrayfun(f,obj.Control);
        end
        function [t,x,u] = sym(obj)
            t = obj.Variable.sym();
            f = @(z)z.sym();
            x = arrayfun(f,obj.State);
            u = arrayfun(f,obj.Control);
        end
    end
end