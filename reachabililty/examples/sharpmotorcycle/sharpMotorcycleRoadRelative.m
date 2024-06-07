function sys = sharpMotorcycleRoadRelative(sharp_params,vx,curvature)
    arguments
        sharp_params (1,1) SharpMotorcycleParameters;
        vx (1,1) double {mustBePositive};
        curvature (1,1) double;
    end
    sys_sharp = sharpMotorcycleStateSpaceFactory(vx,sharp_params);
    Asharp = sys_sharp.a;
    Bsharp = sys_sharp.b;

    Arel = [
        0,1,0,0,1/vx,zeros(1,5);
        zeros(1,5),1/vx,zeros(1,4)
        ];

    Brel = zeros(2,1);

    A = [
        Arel;
        zeros(size(Asharp,1),2),Asharp./vx
        ];

    B = [
        Brel;
        Bsharp./vx
        ];

    c = [
        0;
        -curvature;
        zeros(size(Asharp,1),1)
        ];

    sys = linearSys(A,B,c,eye(size(A)),zeros(size(A,1),1),0.*c);
end