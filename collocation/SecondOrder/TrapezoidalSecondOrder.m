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
            qd0 = obj.Plant.Kinematics(q0,u0,p0);
            qdf = obj.Plant.Kinematics(qf,uf,pf);
            ud0 = obj.Plant.Dynamics(q0,u0,F0,p0);
            udf = obj.Plant.Dynamics(qf,uf,Ff,pf);
            qdd0 = obj.Plant.KinematicRates(q0,u0,ud0,p0);
            qddf = obj.Plant.KinematicRates(qf,uf,udf,pf);
            h = obj.Time(k + 1) - obj.Time(k);
            Cq = qf - h.*qd0 - (h*h/6).*(qddf + 2.*qdd0);
            Cqd = qdf - qd0 - (h/2).*(qddf + qdd0);
            nq = obj.Plant.NumCoordinates;
            obj.Problem.Problem.subject_to([Cq;Cqd] == zeros(2*nq,1)); 
        end
    end
end