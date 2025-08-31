classdef ReferenceFrame < handle
properties (GetAccess = public, SetAccess = private)
   x (3,1) = [1,0,0].';
   y (3,1) = [0,1,0].';
   z (3,1) = [0,0,1].'; 
end
methods (Access = public)
    function obj = ReferenceFrame(varargin)
        if nargin > 0 && isequal(size(varargin{1}),[3,3])
            obj.x = varargin{1}(:,1);
            obj.y = varargin{1}(:,2);
            obj.z = varargin{1}(:,3);
        end 
    end
    function new_frame = orientNew(obj,axis,angle)
        obj.parseConstructorArgs(axis,angle); 
        new_frame = ReferenceFrame();
        R = obj.dcm();
        for i = 1:numel(axis)
            switch axis(i)
            case 'x'
                R = R*Rx(angle(i));
            case 'y'
                R = R*Ry(angle(i));
            case 'z'
                R = R*Rz(angle(i));
            end
        end
        new_frame.x = R(:,1);
        new_frame.y = R(:,2);
        new_frame.z = R(:,3);
    end
    function R = dcm(obj,varargin)
        obj.parseVararginReferenceFrames(varargin{:}); 
        Rwb = [obj.x,obj.y,obj.z];
        if nargin < 2
            R = Rwb;
            return 
        end 
        Rwa = [varargin{1}.x,varargin{1}.y,varargin{1}.z];
        R = Rwa.'*Rwb;
    end
    function wb = bodyAngVel(obj,varargin)
        obj.parseVararginReferenceFrames(varargin{:});
        t = sym('t');
        if nargin < 2
            wb = skew2vec(obj.dcm().'*diff(obj.dcm(),t));
            return 
        end
        wb = skew2vec(obj.dcm(varargin{1}).'*diff(obj.dcm(varargin{1}),t));
    end
    function ws = spaceAngVel(obj,varargin)
        obj.parseVararginReferenceFrames(varargin{:});
        t = sym('t');
        if nargin < 2
            ws = skew2vec(diff(obj.dcm(),t)*obj.dcm().');
            return 
        end
        N = varargin{1};
        ws = skew2vec(diff(obj.dcm(N),t)*obj.dcm(N).');
    end 
end
methods (Access = private)
    function parseConstructorArgs(~,axis,angle)
        if ~isa(axis,'char')
            error('AXIS must be a CHAR');
        end 
        if ~isequal(numel(axis),numel(angle))
            error('Number of axes and angles must be equal');
        end
        if ~all(ismember(axis,'xyz'))
            error('Axis must be x, y, or z');
        end
    end
    function parseVararginReferenceFrames(~,varargin)
        if nargin > 2
            error('Too many input arguments');
        end
        if nargin < 2
            return 
        end
        if ~isa(varargin{1},'ReferenceFrame')
            error('Input must be a ReferenceFrame object')
        end
    end
end
end