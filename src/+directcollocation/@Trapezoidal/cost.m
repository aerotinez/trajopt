function cost(obj)
    arguments
        obj (1,1) directcollocation.Trapezoidal;
    end
    N = obj.NumIntervals;
    h = diff(obj.Mesh)*(obj.FinalTime - obj.InitialTime);

    J = casadi.MX(0);

    if ~isempty(obj.LagrangeCost)
        L = obj.LagrangeCost;
        for k = 1:N
            xk   = obj.States(:,k);
            xkp1 = obj.States(:,k + 1);
            uk   = obj.Controls(:,k);
            ukp1 = obj.Controls(:,k + 1);

            if obj.NumParameters > 0
                pk   = obj.Parameters(:,k);
                pkp1 = obj.Parameters(:,k + 1);
            else
                pk   = casadi.DM([]);
                pkp1 = casadi.DM([]);
            end

            J = J + (1/2)*h(k)*(L(xk,uk,pk) + L(xkp1,ukp1,pkp1));
        end
    end

    if ~isempty(obj.MayerCost)
        t0 = obj.InitialTime;
        tf = obj.FinalTime;
        x0 = obj.States(:,1);
        xf = obj.States(:,end);
        J = J + obj.MayerCost(x0,t0,xf,tf);
    end

    obj.Problem.minimize(J);
end