classdef SteeringHead < matlab.mixin.SetGet
properties
    Mass;
    Ixx;
    Iyy;
    Izz;
    Ixz;
    Rx;
    Ry;
    Rz;
    Damping;
    Caster;
    ForkLength;
    Rake;
    CoMHeight;
    CoMOffset;
end
end