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
            H0 = [eye(3),zeros(3,1)]*hermitePolMat(0,4);
            Hf = [eye(3),zeros(3,1)]*hermitePolMat(h,4);
            A = [H0;Hf];
            for i = 1:obj.Plant.NumCoordinates
                b = [q0(i);qd0(i);qdd0(i);qf(i);qdf(i);qddf(i)];
                a = A\b;
                xf = [qf(i);qdf(i);qddf(i)];
                obj.Problem.Problem.subject_to(xf - Hf*a == 0); 
            end
        end
    end
end