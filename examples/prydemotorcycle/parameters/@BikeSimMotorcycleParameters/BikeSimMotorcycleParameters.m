classdef BikeSimMotorcycleParameters
properties (GetAccess = public, SetAccess = private)
    RiderUpperBody;
    RiderLowerBody;
    SprungMass;
    SwingArm;
    SteeringHead;
    Fork;
    FrontTire;
    RearTire;
end
methods (Access = public)
    function obj = BikeSimMotorcycleParameters(RU,RL,SM,SA,SH,F,FT,RT)
        obj.RiderUpperBody = RU;
        obj.RiderLowerBody = RL;
        obj.SprungMass= SM;
        obj.SwingArm = SA;
        obj.SteeringHead = SH;
        obj.Fork = F;
        obj.FrontTire = FT;
        obj.RearTire = RT;
    end
end
end