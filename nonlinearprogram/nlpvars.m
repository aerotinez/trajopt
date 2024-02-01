classdef nlpvars < handle
    properties (GetAccess = public, SetAccess = private)
        InitialTime;
        IsInitialTimeFree;
        FinalTime;
        IsFinalTimeFree;
        State;
        Control; 
        NumPoints;
        NumStates;
        NumControls;
    end
    methods (Access = public)
        function obj = nlpvars(state,control,initial_time,is_initial_time_free,final_time,is_final_time_free)
            arguments
                state double;
                control double;
                initial_time double {mustBeScalarOrEmpty};
                is_initial_time_free logical;
                final_time double {mustBeScalarOrEmpty};
                is_final_time_free logical;
            end
            obj.State = state;
            obj.Control = control;
            obj.InitialTime = initial_time;
            obj.IsInitialTimeFree = is_initial_time_free;
            obj.FinalTime = final_time;
            obj.IsFinalTimeFree = is_final_time_free;
            obj.NumStates = size(state,1);
            obj.NumControls = size(control,1);
            obj.NumPoints = size(state,2);
            obj.validate();
        end 
    end
    methods (Access = private)
        function validate(obj)
            msg = "State and control must have same number of points.";
            if ~isequal(size(obj.State,2),size(obj.Control,2))
                error(msg);
            end
        end
    end
end