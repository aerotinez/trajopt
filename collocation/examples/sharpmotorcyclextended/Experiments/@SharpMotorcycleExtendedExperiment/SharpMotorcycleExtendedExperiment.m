classdef SharpMotorcycleExtendedExperiment < handle
    properties (GetAccess = public, SetAccess = private)
        Problem;
        Scenario;
        Program;
    end
    methods (Access = public)
        function obj = SharpMotorcycleExtendedExperiment(prob,method,model,cost,scen,x,u)
            arguments
                prob (1,1) CollocationProblem;
                method (1,1) function_handle;
                model (1,1) function_handle;
                cost (1,1) function_handle;
                scen (1,1) Road;
                x table;
                u table;
            end
            obj.Problem = prob;
            obj.Scenario = scen;
            s_units = Unit("arclength","m");
            s0 = FixedTime("s0",s_units,0);
            sf = FixedTime("sf",s_units,scen.Parameter(end));
            X = obj.toStateVector(x);
            U = obj.toStateVector(u);
            curvature = obj.setCurvature();
            plant = Plant(obj.Problem,X,U,curvature,model);
            costfun = Objective(plant,cost,@(x0,t0,xf,tf)0*tf);
            obj.Program = method(obj.Problem,costfun,plant,s0,sf); 
        end
    end
end