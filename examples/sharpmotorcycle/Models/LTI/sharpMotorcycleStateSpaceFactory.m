function plant = sharpMotorcycleStateSpaceFactory(vx,params)
    arguments
        vx (1,1) double {mustBePositive};
        params (1,1) SharpMotorcycleParameters; 
    end
    p = params.list();

    M = sharpMotorcycleLinearizedMassMatrix(vx,p);
    H = sharpMotorcycleLinearizedForcingMatrix(vx,p);
    G = sharpMotorcycleLinearizedInputMatrix(vx,p);

    A = M\H;
    B = M\G;
    C = eye(size(A));
    D = zeros(size(B));

    names = [
        "lean";
        "steer";
        "lateral velocity";
        "yaw rate";
        "lean rate";
        "steer rate";
        "Rear tire lateral force";
        "Front tire lateral force"
        ];

    units = [
        "rad";
        "rad";
        "m/s";
        "rad/s";
        "rad/s";
        "rad/s";
        "N";
        "N"
        ];

    plant = ss(A,B,C,D, ...
        "Name","Sharp motorcycle", ...
        "StateName",names, ...
        "StateUnit",units, ...
        "InputName","Steer torque", ...
        "InputUnit","Nm", ...
        "OutputName",names, ...
        "OutputUnit",units, ...
        "TimeUnit","seconds" ...
        );
end