classdef HermiteSimpson < DirectCollocation
    properties (GetAccess = public, SetAccess = private)
        MidState;
        MidControl;
    end
    properties (Access = private) 
        Xm;
        Um;
    end
    methods (Access = public)
        function obj = HermiteSimpson(objective,plant,mesh)
            obj = obj@DirectCollocation(objective,plant,mesh);
            obj.initializeNLPMidStateVariables();
            obj.initializeNLPMidControlVariables();
        end
        function setMidState(obj,x)
            arguments
                obj (1,1) DirectCollocation;
                x double;
            end
            obj.validateState(x);
            if isequal(size(x),[obj.NumStates,1])
                obj.MidState = repmat(x,1,obj.NumNodes - 1);
            else
                obj.validateMidNodes(x);
                obj.MidState = x;
            end
            for i = 1:obj.NumNodes - 1
                obj.Problem.set_initial(obj.Xm{i},obj.MidState(:,i));
            end
        end
        function setMidControl(obj,u)
            arguments
                obj (1,1) DirectCollocation;
                u double;
            end
            obj.validateControl(u);
            if isequal(size(u),[obj.NumControls,1])
                obj.MidControl = repmat(u,1,obj.NumNodes - 1);
            else
                obj.validateMidNodes(u);
                obj.MidControl = u;
            end
            for i = 1:obj.NumNodes - 1
                obj.Problem.set_initial(obj.Um{i},obj.MidControl(:,i));
            end
        end
        function setStateLowerBound(obj,lb)
            setStateLowerBound@DirectCollocation(obj,lb);
            for i = 1:obj.NumNodes - 1 
                obj.Problem.subject_to(obj.Xm{i} >= lb);
            end
        end
        function setStateUpperBound(obj,ub)
            setStateUpperBound@DirectCollocation(obj,ub);
            for i = 1:obj.NumNodes - 1 
                obj.Problem.subject_to(obj.Xm{i} <= ub);
            end
        end
        function setControlLowerBound(obj,lb)
            setControlLowerBound@DirectCollocation(obj,lb);
            for i = 1:obj.NumNodes - 1 
                obj.Problem.subject_to(obj.Um{i} >= lb);
            end
        end
        function setControlUpperBound(obj,ub)
            setControlUpperBound@DirectCollocation(obj,ub);
            for i = 1:obj.NumNodes - 1 
                obj.Problem.subject_to(obj.Um{i} <= ub);
            end
        end
        function solve(obj,solver)
            arguments
                obj (1,1) DirectCollocation;
                solver string = "ipopt";
            end
            sol = solve@DirectCollocation(obj,solver);
            obj.setMidState(sol.value([obj.Xm{:}]));
            obj.setMidControl(sol.value([obj.Um{:}]));
        end
    end 
    methods (Access = private)
        function initializeNLPMidStateVariables(obj)
            obj.Xm = cell(1,obj.NumNodes - 1);
            for i = 1:obj.NumNodes - 1
                obj.Xm{i} = obj.Problem.variable(obj.NumStates);
            end
        end
        function initializeNLPMidControlVariables(obj)
            obj.Um = cell(1,obj.NumNodes - 1);
            for i = 1:obj.NumNodes - 1
                obj.Um{i} = obj.Problem.variable(obj.NumControls);
            end
        end
        function validateMidNodes(obj,x)
            if size(x,2) ~= obj.NumNodes - 1
                msg = "X must have one less column than there are nodes.";
                error(msg);
            end
        end 
    end
    methods (Access = protected)
        function defect(obj,i)
            x0 = obj.X{i};
            xm = obj.Xm{i};
            xf = obj.X{i + 1};
            u0 = obj.U{i};
            um = obj.Um{i};
            uf = obj.U{i + 1};
            p0 = obj.Parameters(:,i);
            pf = obj.Parameters(:,i + 1);
            f0 = obj.Plant(x0,u0,p0);
            fm = obj.Plant(xm,um,p0);
            ff = obj.Plant(xf,uf,pf);
            [t0,tf] = obj.getTimes(); 
            h = (obj.Mesh(i + 1) - obj.Mesh(i))*(tf - t0);
            nx = obj.NumStates;
            Ch = xm - (1/2).*(xf + x0) - (h./8).*(f0 - ff);
            Cs = xf - x0 - (h./6).*(ff + 4.*fm + f0);
            obj.Problem.subject_to(Ch == zeros(nx,1));
            obj.Problem.subject_to(Cs == zeros(nx,1));
        end
        function x = interpolateState(obj,i)
            x0 = obj.State(:,i);
            xf = obj.State(:,i + 1);
            u0 = obj.Control(:,i);
            uf = obj.Control(:,i + 1);
            p0 = obj.Parameters(:,i);
            pf = obj.Parameters(:,i + 1);
            f0 = full(obj.Plant(x0,u0,p0));
            ff = full(obj.Plant(xf,uf,pf));
            t0 = obj.Time(i);
            tf = obj.Time(i + 1);
            t = linspace(0,tf - t0,obj.ns);
            h = tf - t0;
            x = zeros(obj.NumStates,obj.ns);
            for i = 1:obj.NumStates
                A = [
                    1,0,0,0;
                    0,1,0,0;
                    1,h,h^2,h^3;
                    0,1,2*h,3*h^2
                ];
                b = [
                    x0(i);
                    f0(i);
                    xf(i);
                    ff(i)
                    ];
                a = A\b;
                x(i,:) = a(1) + a(2).*t + a(3).*t.^2 + a(4).*t.^3;
            end
        end
        function u = interpolateControl(obj,i)
            u0 = obj.Control(:,i);
            um = obj.MidControl(:,i);
            uf = obj.Control(:,i + 1);
            t0 = obj.Time(i);
            tf = obj.Time(i + 1);
            tm = (t0 + tf)/2;
            t = linspace(t0,tf,obj.ns);
            u = zeros(obj.NumControls,obj.ns);
            for i = 1:obj.NumControls
                A = [
                    t0^2, t0, 1;
                    tm^2, tm, 1;
                    tf^2, tf, 1 
                ];
                b = [
                    u0(i);
                    um(i);
                    uf(i);
                ];
                a = A\b;
                u(i,:) = a(3) + a(2).*t + a(1).*t.^2;
            end
        end
    end
end