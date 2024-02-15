classdef TrapezoidalSecondOrder < SecondOrderCollocation
    methods (Access = protected)
        function defect(obj)
            q0 = obj.Plant.Coordinates.Variable(:,1:end - 1);
            qf = obj.Plant.Coordinates.Variable(:,2:end);
            u0 = obj.Plant.Speeds.Variable(:,1:end - 1);
            uf = obj.Plant.Speeds.Variable(:,2:end);
            F0 = obj.Plant.Controls.Variable(:,1:end - 1);
            Ff = obj.Plant.Controls.Variable(:,2:end);
            p0 = obj.Plant.Parameters(:,1:end - 1);
            pf = obj.Plant.Parameters(:,2:end);

            [t0,tf] = obj.getTimes();
            h = diff(obj.Problem.Mesh(1:2))*(tf - t0);

            qd0 = obj.Plant.Kinematics(q0,u0,p0);
            qdd0 = obj.Plant.Dynamics(q0,u0,F0,p0);
            qddf = obj.Plant.Dynamics(qf,uf,Ff,pf);

            nq = obj.Plant.NumCoordinates;

            A = [
                eye(2*nq),zeros(2*nq);
                zeros(nq,2*nq),2.*eye(nq),zeros(nq);
                zeros(nq,2*nq),2.*eye(nq),6*h.*eye(nq);
                ];

            B = A\eye(size(A));

            x = [
                q0;
                qd0;
                qdd0;
                qddf
                ];

            a = B*x;

            I = eye(nq);
            Hq = [I,h.*I,(h^2).*I,(h^3).*I];
            Hqd = [0.*I,I,2*h.*I,(3*h^2).*I];

            obj.Problem.Problem.subject_to(qf - Hq*a == 0);

            f = obj.Plant.RatesToSpeeds;
            obj.Problem.Problem.subject_to(uf - f(qf,Hqd*a,pf) == 0);
        end
    end
end