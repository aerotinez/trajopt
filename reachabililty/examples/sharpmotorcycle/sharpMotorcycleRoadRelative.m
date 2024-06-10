function sys = sharpMotorcycleRoadRelative(sharp_params,vx)
    arguments
        sharp_params (1,1) SharpMotorcycleParameters;
        vx (1,1) double {mustBePositive};
    end
    sys_sharp = sharpMotorcycleStateSpaceFactory(vx,sharp_params);
    Asharp = sys_sharp.a;
    Bsharp = sys_sharp.b;

    Arel = [
        0,1,0,0,1/vx,zeros(1,5);
        zeros(1,5),1/vx,zeros(1,4)
        ];

    Brel = [0,0;0,-1];

    A = [
        Arel;
        zeros(size(Asharp,1),2),Asharp./vx
        ];

    B = [
        Brel;
        [Bsharp./vx,0.*Bsharp]
        ];

    sys = linearSys(A,B);
end