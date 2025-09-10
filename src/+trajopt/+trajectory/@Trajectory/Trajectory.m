classdef Trajectory
    properties (GetAccess = public, SetAccess = protected)
        Time;
        States;
        Controls;
        Parameters;
        StateNames;
        ControlNames;
        StateQuantities;
        ControlQuantities;
        StateUnits;
        ControlUnits;
        Plant;
    end
    methods (Access = public)
        function obj = Trajectory(prog,plant,state_table,control_table)
            arguments
                prog (1,1) trajopt.collocation.Program;
                plant (1,1) function_handle;
                state_table table;
                control_table table;
            end
            obj.Time = prog.Time';
            obj.States = prog.Solution.value(prog.States)';
            obj.Controls = prog.Solution.value(prog.Controls)';
            obj.Parameters = prog.Solution.value(prog.Parameters)';
            obj.StateNames = state_table.Name';
            obj.StateQuantities = state_table.Quantity';
            obj.StateUnits = state_table.Units';
            obj.ControlNames = control_table.Name';
            obj.ControlQuantities = control_table.Quantity';
            obj.ControlUnits = control_table.Units';
            obj.Plant = plant;
        end
        fig = plot(obj);
    end
    methods (Access = public)
        [t,x,u] = interpolate(obj);
    end
    methods (Access = protected)
        idx = getInterval(obj,t);
    end
    methods (Access = protected, Abstract)
        x = interpolateStates(obj,t);
        u = interpolateControls(obj,t);
    end
end