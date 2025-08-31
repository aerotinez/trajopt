function defect(obj)
    arguments
        obj (1,1) directcollocation.LegendreGauss
    end
    % assumes: setMesh → setBarycentricWeights → setDifferentiationMatrix
    % were called by LegendrePseudospectral.solve()

    if obj.NumParameters > 0
        P = obj.Parameters;                           % np×N
    else
        P = casadi.MX.zeros(0, obj.NumNodes);         % 0×N
    end

    % dynamics at Gauss nodes, vectorized
    Fmap   = obj.Plant.map(obj.NumNodes);
    Fnodes = Fmap(obj.States, obj.Controls, P);       % nx×N

    % pseudospectral collocation: X * D' = (tf - t0) * F
    hT = obj.FinalTime - obj.InitialTime;
    obj.Problem.subject_to( obj.States * obj.DifferentiationMatrix.' == hT * Fnodes );

    % boundary conditions at true endpoints using endpoint basis
    a0 = directcollocation.baryval(obj.BarycentricWeights, obj.Mesh, 0.0);   % 1×N
    a1 = directcollocation.baryval(obj.BarycentricWeights, obj.Mesh, 1.0);   % 1×N

    X0 = obj.States * a0.';     % nx×1
    XF = obj.States * a1.';     % nx×1

    for i = 1:obj.NumStates
        s0 = obj.StartStateVals(i);
        sf = obj.EndStateVals(i);

        if ~isnan(s0)
            obj.Problem.subject_to( X0(i) == s0 );
        end
        if ~isnan(sf)
            obj.Problem.subject_to( XF(i) == sf );
        end
    end
end