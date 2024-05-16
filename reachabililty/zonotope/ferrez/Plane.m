classdef Plane
    properties (GetAccess = public, SetAccess = private)
        n;
        r0;
        a;
        b;
        c;
        d;
    end
    methods (Access = public)
        function obj = Plane(n,r0)
            arguments
                n (3,1) double;
                r0 (3,1) double;
            end
            obj.n = n;
            obj.r0 = r0;
            obj.a = n(1);
            obj.b = n(2);
            obj.c = n(3);
            obj.d = -n.'*r0;
        end
    end
end