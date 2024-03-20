classdef Inertia < handle
properties (GetAccess = public, SetAccess = private)
    Ixx;
    Iyy;
    Izz;
    Ixy = 0;
    Ixz = 0;
    Iyz = 0;
end
methods (Access = public)
    function obj = Inertia(ixx,iyy,izz,options)
        arguments
            ixx (1,1);
            iyy (1,1);
            izz (1,1);
            options.Ixy (1,1) = 0;
            options.Ixz (1,1) = 0;
            options.Iyz (1,1) = 0;
        end
        obj.Ixx = ixx;
        obj.Iyy = iyy;
        obj.Izz = izz;
        obj.Ixy = options.Ixy;
        obj.Ixz = options.Ixz;
        obj.Iyz = options.Iyz;
    end
    function I = tensor(obj)
        I = [
            obj.Ixx,obj.Ixy,obj.Ixz;
            obj.Ixy,obj.Iyy,obj.Iyz;
            obj.Ixz,obj.Iyz,obj.Izz
            ];
    end
end
end