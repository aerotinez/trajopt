classdef LegendreGauss < DirectCollocation
    properties (Access = public)
        Degree;
        LegendrePoints;
        LagrangeCoeffs;
        CollocationCoeffs;
        EndCoeffs;
        QuadCoeffs;
        MidStates;
    end
    methods (Access = public)
        function obj = LegendreGauss(prob,objfun,plant,t0,tf,n)
            arguments
                prob (1,1) CollocationProblem;
                objfun (1,1) Objective;
                plant (1,1) Plant;
                t0 (1,1) Time;
                tf (1,1) Time;
                n (1,1) double {mustBeInteger,mustBePositive} = 3;
            end
            obj = obj@DirectCollocation(prob,objfun,plant,t0,tf);
            obj.Degree = n;
            obj.LegendrePoints = [0,0.5.*sort(roots(legpol(n))).' + 0.5];
            obj.LagrangeCoeffs = lagpol(obj.LegendrePoints);
            ft = @(t)(0:n).'.*[0;t.^(0:n - 1).'];
            t = cell2mat(arrayfun(ft,obj.LegendrePoints(2:end),"uniform",0));
            obj.CollocationCoeffs = obj.LagrangeCoeffs*t;
            obj.EndCoeffs = obj.LagrangeCoeffs*1.^(0:n).';
            obj.QuadCoeffs = obj.LagrangeCoeffs*(1./(1:n + 1)).';
            obj.MidStates = obj.initializeMidStates(); 
        end
    end 
    methods (Access = protected)
        function defect(obj)
        end
        function interpolateState(obj)
        end
        function interpolateControl(obj)
        end
    end
    methods (Access = private)
        function Xc = initializeMidStates(obj)
            Xc = arrayfun(@(k)obj.initializeMidState,1:obj.Degree);
        end
        function xc = initializeMidState(obj)
            x = obj.Plant.States.getValues();
            x0 = x(:,1:end - 1);
            x1 = x(:,2:end);
            values = (x0 + x1)./2;
            initial = nan(obj.Plant.NumStates,1);
            final = nan(obj.Plant.NumStates,1);
            lower = [obj.Plant.States.States.LowerBound].';
            upper = [obj.Plant.States.States.UpperBound].';
            f = @CollocationVariableFactory;
            B = f(obj.Problem.Problem,values,initial,final,lower,upper);
            xc = struct("Values",values,"Variable",B.create());
        end
    end
end