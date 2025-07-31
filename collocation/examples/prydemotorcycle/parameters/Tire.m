classdef Tire < matlab.mixin.SetGet
    properties
        EffectiveRollingRadius;
        SpringRate;
        Mass;
        UndeflectedCrownRadius;
        SpinInertia;
        LateralTireLag;
        Pacejka;
        RollingResistanceCoefficient;
        RollingResistanceTimeConstant;
    end
end