classdef LegendreGauss < DirectCollocation
    properties (Access = public)
        Degree;
        LegendrePoints;
        LagrangeCoeffs;
        CollocationCoeffs;
        EndCoeffs;
        QuadCoeffs;
        MidStates;
        MidControls;
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
            obj.LegendrePoints = [-1,sort(roots(legpol(n))).'];
            obj.LagrangeCoeffs = lagpol(obj.LegendrePoints);
            dt = @(t)(0:n).'.*[0;t.^(0:n - 1).'];
            t = cell2mat(arrayfun(dt,obj.LegendrePoints(2:end),"uniform",0));
            obj.CollocationCoeffs = obj.LagrangeCoeffs*t;
            obj.EndCoeffs = obj.LagrangeCoeffs*1.^(0:n).';
            obj.QuadCoeffs = obj.LagrangeCoeffs*(1./(1:n + 1)).';
            obj.MidStates = obj.initializeMidStates();
            obj.MidControls = obj.initializeMidControls();
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
        function cost(obj)
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
            Fk = vertcat(fk{:});
            B = repmat(obj.QuadCoeffs(2:end).',1,N - 1);
            [t0,tf] = obj.getTimes();
            h = repelem(diff(obj.Problem.Mesh).*(tf - t0),1,d);
            J = J + (h.*B)*Fk;
            x = obj.Plant.States.Variable;
            M = obj.Objective.Mayer(x(:,1),t0,x(:,end),tf);
            J = J + M;
            obj.Problem.Problem.minimize(J);
        end
        function defect(obj)
            % Get dimensions
            nx = obj.Plant.NumStates;
            nu = obj.Plant.NumControls;
            np = obj.Plant.NumParameters;
            N = obj.Problem.NumNodes;
            d = obj.Degree;

            % Get initial and final states
            x0 = obj.Plant.States.Variable(:,1:end - 1);
            xf = obj.Plant.States.Variable(:,2:end);

            % Get controls up to N - 1
            u0 = obj.Plant.Controls.Variable(:,1:end - 1);

            % Get parameters up to N - 1
            p0 = obj.Plant.Parameters(:,1:end - 1); 

            % Get collocation states
            fxc = @(r)obj.MidStates(r).Variable(:);
            xm = arrayfun(fxc,1:d,"uniform",0);

            % Form matrix of collocation states:
            %   X = [x1,x2 ... xnx]^T
            %   Z = [X0 | X1 ... Xd] 
            %   MZ = block_diagonal([Z1,Z2 ... ZN - 1])
            z = [x0(:),xm{:}];
            zc = mat2cell(z,repelem(nx,N - 1),d + 1);
            Z = blkdiag(zc{:});

            % Form block vector of Gauss pseudospectral differentiation matrices
            %   C = [C1,C2 ... CN - 1]^T
            C = repmat(obj.CollocationCoeffs,N - 1,1);

            % Get collocation controls
            fuc = @(r)obj.MidControls(r).Variable(:);
            um = arrayfun(fuc,1:d,"uniform",0);

            % Form block vector of state derivatives
            xk = mat2cell([xm{:}],repelem(nx,N - 1),d);
            uk = mat2cell([u0(:),um{:}],repelem(nu,N - 1),d);
            pk = mat2cell(repmat(p0(:),1,d),repelem(np,N - 1,1),d);
            f = @(x,u,p)obj.Plant.Dynamics(x,u,p);
            fk = cellfun(f,xk,uk,pk,"uniform",0);
            Fk = vertcat(fk{:});

            % vector of mesh intervals
            [t0,tf] = obj.getTimes();
            h = repelem((tf - t0).*diff(obj.Problem.Mesh),1,nx).';

            % Impose collocation constraint on state derivatives within mesh 
            % intervals
            obj.Problem.Problem.subject_to(h.*Fk - Z*C == 0);

            % Impose continuity constraint between ends and starts of intervals
            %   D = L(1)
            D = repmat(obj.EndCoeffs,N - 1,1);
            obj.Problem.Problem.subject_to(xf(:) - Z*D == 0);

            % TODO: Differentiate continuity constraints to include start and
            % end control variables?
        end
        function interpolateState(obj)
        end
        function interpolateControl(obj)
        end
    end
    methods (Access = private)
        function xc = initializeMidVariable(obj,var)
            x = var.getValues();
            x0 = x(:,1:end - 1);
            x1 = x(:,2:end);
            values = (x0 + x1)./2;
            initial = nan(size(x,1),1);
            final = nan(size(x,1),1);
            lower = [var.States.LowerBound].';
            upper = [var.States.UpperBound].';
            f = @CollocationVariableFactory;
            B = f(obj.Problem.Problem,values,initial,final,lower,upper);
            xc = struct("Values",values,"Variable",B.create());
        end 
        function Xc = initializeMidStates(obj)
            f = @(k)obj.initializeMidVariable(obj.Plant.States);
            Xc = arrayfun(f,1:obj.Degree);
        end
        function Uc = initializeMidControls(obj)
            f = @(k)obj.initializeMidVariable(obj.Plant.Controls);
            Uc = arrayfun(f,1:(obj.Degree - 1));
        end
    end
end