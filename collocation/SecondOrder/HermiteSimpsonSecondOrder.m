classdef HermiteSimpsonSecondOrder < SecondOrderCollocation
    properties (Access = private)
        Qm;
        Um;
        Fm;
    end
    methods (Access = public)
        function obj = HermiteSimpsonSecondOrder(varargin)
            obj = obj@SecondOrderCollocation(varargin{:});
            obj.Qm = obj.initializeMidCoordinates();
            obj.Um = obj.initializeMidSpeeds();
            obj.Fm = obj.initializeMidControls(); 
        end
    end
    methods (Access = private) 
        function Qc = initializeMidCoordinates(obj)
            nq = obj.Plant.NumCoordinates;
            M = obj.Problem.NumNodes;
            f = @(k)obj.Problem.Problem.variable(nq);
            Qc = arrayfun(f,1:M - 1,'UniformOutput',false);
            q = obj.Plant.Coordinates.getValues();
            qc = num2cell((q(:,end - 1) + q(:,2:end))./2,1);
            g = @(k)obj.Problem.Problem.set_initial(Qc{k},qc{k});
            arrayfun(g,1:M - 1,"UniformOutput",false);
        end
        function Uc = initializeMidSpeeds(obj)
            nu = obj.Plant.NumSpeeds;
            M = obj.Problem.NumNodes;
            f = @(k)obj.Problem.Problem.variable(nu);
            Uc = arrayfun(f,1:M - 1,'UniformOutput',false);
            u = obj.Plant.Speeds.getValues();
            uc = num2cell((u(:,end - 1) + u(:,2:end))./2,1);
            g = @(k)obj.Problem.Problem.set_initial(Uc{k},uc{k});
            arrayfun(g,1:M - 1,"UniformOutput",false);
        end
        function Fc = initializeMidControls(obj)
            nc = obj.Plant.NumControls;
            M = obj.Problem.NumNodes;
            g = @(k)obj.Problem.Problem.variable(nc);
            Fc = arrayfun(g,1:M - 1,'UniformOutput',false);
            f = obj.Plant.Controls.getValues();
            fc = num2cell((f(:,end - 1) + f(:,2:end))./2,1);
            h = @(k)obj.Problem.Problem.set_initial(Fc{k},fc{k});
            arrayfun(h,1:M - 1,"UniformOutput",false);
            for k = 1:M - 1
                for i = 1:obj.Plant.NumControls
                    lb = obj.Plant.Controls.Variables(i).LowerBound;
                    ub = obj.Plant.Controls.Variables(i).UpperBound;
                    if ~isinf(lb)
                        obj.Problem.Problem.subject_to(lb <= Fc{k}(i));
                    end
                    if ~isinf(ub)
                        obj.Problem.Problem.subject_to(ub >= Fc{k}(i));
                    end
                end
            end
        end
    end
    methods (Access = protected)
        function defect(obj,k)
            q0 = obj.Q{k};
            qc = obj.Qm{k};
            qf = obj.Q{k + 1};
            u0 = obj.U{k};
            uc = obj.Um{k};
            uf = obj.U{k + 1};
            F0 = obj.F{k};
            Fc = obj.Fm{k};
            Ff = obj.F{k + 1};
            p0 = obj.P(:,k);
            pf = obj.P(:,k + 1);
            ud0 = obj.Plant.Dynamics(q0,u0,F0,p0);
            udc = obj.Plant.Dynamics(qc,uc,Fc,p0);
            udf = obj.Plant.Dynamics(qf,uf,Ff,pf);
            Jqdc = obj.Plant.RateJacobian(qc,p0);
            Jqdf = obj.Plant.RateJacobian(qf,pf);
            Ju0 = obj.Plant.SpeedJacobian(q0,p0);
            Juc = obj.Plant.SpeedJacobian(qc,p0);
            Juf = obj.Plant.SpeedJacobian(qf,pf);
            Jdu0 = obj.Plant.SpeedJacobianRate(q0,u0,p0);
            Jduc = obj.Plant.SpeedJacobianRate(qc,uc,p0);
            Jduf = obj.Plant.SpeedJacobianRate(qf,uf,pf);
            qd0 = Ju0*u0;
            qdf = Juf*uf;
            qdd0 = Ju0*ud0 + Jdu0*u0;
            qddc = Juc*udc + Jduc*uc;
            qddf = Juf*udf + Jduf*uf; 
            [t0,tf] = obj.getTimes(); 
            h = (obj.Problem.Mesh(k + 1) - obj.Problem.Mesh(k))*(tf - t0);
            Cq = qf - (q0 + h.*qd0 + (h*h/6).*(qdd0 + 2.*qddc));
            Cu = uf - Jqdf*(qd0 + (h/6).*(qdd0 + 4.*qddc + qddf));
            Cqc = qc - (q0 + (h/32).*(13.*qd0 + 3.*qdf) + (h*h/192).*(11.*qdd0 - 5.*qddf));
            Cuc = uc - Jqdc*((1/2).*(qd0 + qdf) + (h/8).*(qdd0 - qddf));
            nq = obj.Plant.NumCoordinates;
            nu = obj.Plant.NumSpeeds;
            n = 2*(nq + nu);
            obj.Problem.Problem.subject_to([Cq;Cu;Cqc;Cuc] == zeros(n,1));
        end
    end
end