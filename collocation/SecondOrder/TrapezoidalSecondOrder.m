classdef TrapezoidalSecondOrder < SecondOrderCollocation
    methods (Access = protected)
        function defect(obj,k)
            q0 = obj.Q{k};
            qf = obj.Q{k + 1};
            u0 = obj.U{k};
            uf = obj.U{k + 1};
            F0 = obj.F{k};
            Ff = obj.F{k + 1};
            p0 = obj.P(:,k);
            pf = obj.P(:,k + 1);
            ud0 = obj.Plant.Dynamics(q0,u0,F0,p0);
            udf = obj.Plant.Dynamics(qf,uf,Ff,pf);
            Ju0 = obj.Plant.SpeedJacobian(q0,p0);
            Jdu0 = obj.Plant.SpeedJacobianRate(q0,u0,p0);
            Jqdf = obj.Plant.RateJacobian(qf,pf);
            Juf = obj.Plant.SpeedJacobian(qf,pf);
            Jduf = obj.Plant.SpeedJacobianRate(qf,uf,pf);
            qd0 = Ju0*u0;
            qdd0 = Ju0*ud0 + Jdu0*u0;
            qddf = Juf*udf + Jduf*uf;
            [t0,tf] = obj.getTimes(); 
            h = (obj.Problem.Mesh(k + 1) - obj.Problem.Mesh(k))*(tf - t0);
            Cq = qf - (q0 + h.*qd0 + (h*h/6).*(qddf + 2.*qdd0));
            Cu = uf - Jqdf*(qd0 + (h/2).*(qddf + qdd0));
            nq = obj.Plant.NumCoordinates;
            nu = obj.Plant.NumSpeeds;
            obj.Problem.Problem.subject_to([Cq;Cu] == zeros(nq + nu,1)); 
        end
    end
end