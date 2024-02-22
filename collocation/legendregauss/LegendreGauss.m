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
        function solve(obj,solver)
            arguments
                obj (1,1) LegendreGauss;
                solver (1,1) string = "ipopt";
            end
            sol = solve@DirectCollocation(obj,solver);
            for i = 1:obj.Degree
                obj.MidStates(i).Values = sol.value(obj.MidStates(i).Variable);
            end
        end
    end 
    methods (Access = protected)
        function defect(obj)
            x0 = obj.Plant.States.Variable(:,1:end - 1);
            xf = obj.Plant.States.Variable(:,2:end);
            u0 = obj.Plant.Controls.Variable(:,1:end - 1);
            p0 = obj.Plant.Parameters(:,1:end - 1);
            nx = obj.Plant.NumStates;
            nu = obj.Plant.NumControls;
            np = obj.Plant.NumParameters;
            N = obj.Problem.NumNodes;
            d = obj.Degree;
            fxc = @(r)obj.MidStates(r).Variable(:);
            xm = arrayfun(fxc,1:d,"uniform",0);
            z = [x0(:),xm{:}];
            zc = mat2cell(z,repelem(nx,N - 1),d + 1);
            Z = blkdiag(zc{:});
            C = repmat(obj.CollocationCoeffs,N - 1,1);
            f = @(x,u,p)obj.Plant.Dynamics(x,u,p);
            xk = mat2cell([xm{:}],repelem(nx,N - 1),d);
            uk = mat2cell(repmat(u0.',1,d),repelem(nu,N - 1,1),d);
            pk = mat2cell(repmat(p0(:),1,d),repelem(np,N - 1,1),d);
            fk = cellfun(f,xk,uk,pk,"uniform",0);
            Fk = vertcat(fk{:});
            [t0,tf] = obj.getTimes();
            h = diff(obj.Problem.Mesh(1:2))*(tf - t0);
            obj.Problem.Problem.subject_to(h.*Fk - Z*C == 0);
            D = repmat(obj.EndCoeffs,N - 1,1);
            obj.Problem.Problem.subject_to(xf(:) - Z*D == 0);
        end
        function interpolateState(obj)
        end
        function interpolateControl(obj)
        end
    end
    methods (Access = private) 
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
        function Xc = initializeMidStates(obj)
            Xc = arrayfun(@(k)obj.initializeMidState,1:obj.Degree);
        end
        function J = cost(obj)
            J = 0;
            nx = obj.Plant.NumStates;
            nu = obj.Plant.NumControls;
            N = obj.Problem.NumNodes;
            d = obj.Degree;
            u0 = obj.Plant.Controls.Variable(:,1:end - 1);
            fxc = @(r)obj.MidStates(r).Variable(:);
            xm = arrayfun(fxc,1:d,"uniform",0);
            xk = mat2cell([xm{:}],repelem(nx,N - 1),d);
            uk = mat2cell(repmat(u0.',1,d),repelem(nu,N - 1,1),d);
            L = @(x,u)obj.Objective.Lagrange(x,u).';
            fk = cellfun(L,xk,uk,"uniform",0);
            Fk = reshape([fk{:}],d,N - 1);
            B = repmat(obj.QuadCoeffs(2:end).',1,N - 1);
            [t0,tf] = obj.getTimes();
            h = repelem(diff(obj.Problem.Mesh).*(tf - t0),1,d);
            J = J + (h.*B)*Fk(:);
            x = obj.Plant.States.Variable;
            M = obj.Objective.Mayer(x(:,1),t0,x(:,end),tf);
            J = J + M;
        end 
    end
end