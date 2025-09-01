function defect(obj)
    arguments
        obj (1,1) directcollocation.HermiteSimpson
    end

    Nn = obj.NumNodes;         % must be odd
    hT = (obj.FinalTime - obj.InitialTime);

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

        % macro-step size over [i, i+2]
        h = hT * (obj.Mesh(i+2) - obj.Mesh(i));

        fL = obj.Plant(xL, uL, pL);
        fM = obj.Plant(xM, uM, pM);
        fR = obj.Plant(xR, uR, pR);

        % Simpson defect: xR - xL = (h/6)(fL + 4 fM + fR)
        obj.Problem.subject_to( xR - xL == (h/6) * (fL + 4*fM + fR) );

        % Hermite midpoint: xM = (xL + xR)/2 + (h/8)(fL - fR)
        obj.Problem.subject_to( xM == 0.5*(xL + xR) + (h/8)*(fL - fR) );
    end
end
