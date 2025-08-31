function cost(obj)
    arguments
        obj (1,1) directcollocation.HermiteSimpson
    end

    J = casadi.MX(0);
    Nn = obj.NumNodes;
    hT = (obj.FinalTime - obj.InitialTime);

    if ~isempty(obj.LagrangeCost)
        L = obj.LagrangeCost;

        for i = 1:2:(Nn-2)
            xL = obj.States(:, i);
            xM = obj.States(:, i+1);
            xR = obj.States(:, i+2);

            uL = obj.Controls(:, i);
            uM = obj.Controls(:, i+1);
            uR = obj.Controls(:, i+2);

            if obj.NumParameters > 0
                pL = obj.Parameters(:, i);
                pM = obj.Parameters(:, i+1);
                pR = obj.Parameters(:, i+2);
            else
                pL = casadi.DM([]);
                pM = casadi.DM([]);
                pR = casadi.DM([]);
            end

            h = hT * (obj.Mesh(i+2) - obj.Mesh(i));

            J = J + (h/6) * ( L(xL,uL,pL) + 4*L(xM,uM,pM) + L(xR,uR,pR) );
        end
    end

    if ~isempty(obj.MayerCost)
        x0 = obj.States(:, 1);
        xf = obj.States(:, end);
        t0 = obj.InitialTime;
        tf = obj.FinalTime;
        J = J + obj.MayerCost(x0, t0, xf, tf);
    end

    obj.Problem.minimize(J);
end
