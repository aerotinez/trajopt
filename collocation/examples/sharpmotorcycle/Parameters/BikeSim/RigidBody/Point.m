classdef Point < handle
properties (GetAccess = public, SetAccess = private)
    x (1,1) = 0;
    y (1,1) = 0;
    z (1,1) = 0;
end
methods (Access = public)
    function obj = Point(varargin)
        if nargin > 0
            p = varargin{1};
            obj.x = p(1);
            obj.y = p(2);
            obj.z = p(3);
        end
    end
    function new_point = locateNew(obj,pnew)
        new_point = Point;
        new_point.x = obj.x + pnew(1);
        new_point.y = obj.y + pnew(2);
        new_point.z = obj.z + pnew(3);
    end
    function d = posFrom(obj,varargin)
        switch nargin
        case 1
            d = [obj.x; obj.y; obj.z];
        case 2 
            P = varargin{1};
            if ~isa(P,'Point')
                error('P must be a POINT');
            end
            d = [obj.x - P.x; obj.y - P.y; obj.z - P.z];
        case 3
            P = varargin{1};
            N = varargin{2};
            if ~isa(P,'Point') || ~isa(N,'ReferenceFrame')
                error('P must be a POINT');
            end
            d = N.dcm().'*[obj.x - P.x; obj.y - P.y; obj.z - P.z];
        otherwise
            error('Too many input arguments');
        end
    end
    function vb = bodyVel(obj,frame)
        obj.parseReferenceFrame(frame); 
        t = sym('t');
        p = [obj.x,obj.y,obj.z].';
        vb = frame.dcm().'*diff(p,t);
    end
    function vs = spaceVel(obj,frame)
        obj.parseReferenceFrame(frame);
        t = sym('t');
        p = [obj.x,obj.y,obj.z].';
        vs = diff(p,t) - cross(frame.spaceAngVel(),p);
    end
    function Vb = bodyTwist(obj,frame)
        Vb = [
            frame.bodyAngVel(); 
            obj.bodyVel(frame)
            ];
    end
    function Vs = spaceTwist(obj,frame)
        Vs = [
            frame.spaceAngVel(); 
            obj.spaceVel(frame)
            ];
    end 
    function Jb = bodyJacobian(obj,frame,qd)
        Jb = jacobian(obj.bodyTwist(frame),qd);
    end
    function Js = spaceJacobian(obj,frame,qd)
        Js = jacobian(obj.spaceTwist(frame),qd);
    end
end
methods (Access = private)
    function parseConstructorArgs(~,p)
        if ~isvector(p) || length(p) ~= 3
            error('Input must be a 3x1');
        end
    end
    function parseReferenceFrame(~,frame)
        if ~isa(frame,'ReferenceFrame')
            error('Input must be a ReferenceFrame');
        end
    end
end
end