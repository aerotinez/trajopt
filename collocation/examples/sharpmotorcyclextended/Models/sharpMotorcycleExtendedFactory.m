function plant = sharpMotorcycleExtendedFactory(params)
    arguments
        params (1,1) BikeSimMotorcycleParameters;
    end
    % parameter vector
    p = bikeSimToSharp(params).list();
    fp = @(x)[p(1:10);x(6);p(11:end)];

    % road relative kinematics
    frr = @roadRelativeKinematics;
    fr = @(x,p)frr([0.*x(1,:);x(1:2,:)],x([6,7,5],:),p);

    % progress rate
    fds = @(x,p)[1,0,0]*fr(x,p);

    % lateral offset and relative heading ODEs
    fk = @(x,p)[zeros(2,1),eye(2)]*fr(x,p);

    % extended sharp model
    A = @sharpMotorcycleExtendedStateMatrix;
    B = @sharpMotorcycleExtendedInputMatrix;
    fsharp = @(x)A(x,fp(x))*x(3:end - 2,:) + B(x,fp(x))*x(end - 1:end,:);

    % plant
    plant = @(x,u,p)(1./fds(x,p)).*[
        fk(x,p);
        fsharp(x);
        u
    ];
end