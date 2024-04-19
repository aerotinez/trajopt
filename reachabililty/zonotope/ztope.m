classdef ztope
    properties (GetAccess = public, SetAccess = private)
        Center;
        Generators;
    end
    methods (Access = public)
        function obj = ztope(generators,center)
            arguments
                generators double;
                center (:,1) double = zeros(size(generators,1),1);
            end 
            obj.Center = center;
            obj.Generators = generators;
            validateDimensions(obj);
        end
        function zn = plus(za,zb)
            arguments
                za ztope;
                zb ztope {validatePlusDimensions(za,zb)};
            end
            zn = ztope([za.Generators,zb.Generators],za.Center + zb.Center);
        end
        function zn = mtimes(A,z)
            arguments
                A double;
                z ztope {validateMtimesDimensions(z,A)};
            end
            zn = ztope(A*z.Generators,A*z.Center);
        end
        function n = dim(obj)
            n  = size(obj.Center,1);
        end
        function p = order(obj)
            p = size(obj.Generators,2)/dim(obj);
        end
        function zn = project(obj,dims)
            arguments
                obj ztope;
                dims (1,:) double {mustBeInteger,mustBePositive};
            end
            zn = ztope(obj.Generators(dims,:),obj.Center(dims));
        end
        function p = vertices(obj)
            Z = filtercollinear(rmnullcols(obj.Generators));
            combs = (dec2bin(0:2^size(Z,2) - 1) - '0').';
            combs(combs == 0) = -1;
            p = zeros(size(Z,1),size(combs,2));
            for i = 1:size(combs,2)
                p(:,i) = sum(Z.*combs(:,i).',2);
            end
            p = unique(p.','rows').';
            p = unique(p(:,convhulln(p.')).','rows').' + obj.Center;
        end
        function plot(obj,dims)
            arguments
                obj ztope;
                dims (1,:) double {mustBeInteger,mustBePositive} = 1:dim(obj);
            end
            if ~ismember(numel(dims),[2,3])
                error("Only 2D and 3D plots are supported");
            end
            P = obj.project(dims).vertices();
            H = P(:,convhull(P.'));
            switch numel(dims)
                case 2
                    obj.plot2d(H);
                case 3
                    obj.plot3d(H);
            end
        end
        function z = box(obj,ord)
            arguments
                obj ztope;
                ord (1,1) double {mustBeReal,mustBePositive} = 10;
            end
            if order(obj) <= ord
                z = obj;
                return;
            end
            gk = vecnorm(obj.Generators,1,1) - vecnorm(obj.Generators,inf,1);
            k = [1,0]*sortrows([1:size(gk,2);gk].',2).';
            g = obj.Generators(:,k);
            n = dim(obj);
            h = diag(sum(abs(g(:,1:2*n)),2));
            z = ztope([h,g(:,2*n + 1:end)],obj.Center);
        end 
    end
    methods (Access = protected)
        function validateDimensions(obj)
            if size(obj.Center,1) ~= size(obj.Generators,1)
                error("Center and Generators dimensions do not match");
            end
        end
        function validatePlusDimensions(obj,z)
            if dim(obj) ~= dim(z)
                error("Zonotopes must have the same dimension to be summed");
            end 
        end
        function validateMtimesDimensions(obj,A)
            msg = "A must have as many columns as the ztope has dimenions";
            if size(A,2) ~= size(obj.Center,1)
                error(msg);
            end
        end
        function plot2d(~,H)
            axe = gca; 
            hold(axe,"on");
            fill(H(1,:),H(2,:),[0,0.4470,0.7410]);
            hold(axe,"off");
        end
        function plot3d(~,H)
            axe = gca;
            view(axe,3); 
            [Tfb,Xfb] = freeBoundary(delaunayTriangulation(unique(H.',"rows")));
            TR = triangulation(Tfb,Xfb);
            hold(axe,"on");
            trisurf(TR,"FaceColor",[0,0.4470,0.7410]);
            lighting(axe,"flat");
            hold(axe,"off");
        end
    end
end