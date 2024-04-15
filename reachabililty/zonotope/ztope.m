classdef ztope
    properties (GetAccess = public, SetAccess = private)
        Center;
        Generators;
        Dimension;
        Order;
    end
    methods (Access = public)
        function obj = ztope(generators,center)
            arguments
                generators double;
                center (:,1) double = zeros(size(generators,1),1);
            end 
            obj.Center = center;
            obj.Generators = generators;
            obj.validateDimensions();
            obj.Dimension = size(center,1);
            obj.Order = size(generators,2)/obj.Dimension;
        end
        function zn = plus(za,zb)
            arguments
                za ztope;
                zb ztope;
            end
            za.validatePlusDimensions(zb);
            c = za.Center + zb.Center;
            g = [za.Generators,zb.Generators];
            f = str2func(class(za));
            zn = f(g,c);
        end
        function zn = mtimes(A,z)
            arguments
                A double;
                z ztope;
            end
            z.validateMtimesDimensions(A);
            c = A*z.Center;
            g = A*z.Generators;
            f = str2func(class(z));
            zn = f(g,c);
        end
        function g = condense(obj,gin)
            g = obj.removeZeroGenerators(gin);
            g = obj.condenseAligned(g);
        end
        function z = box(obj,order)
            arguments
                obj ztope;
                order (1,1) double {mustBeReal,mustBePositive} = 10;
            end
            if obj.Order <= order
                z = obj;
                return;
            end
            gk = vecnorm(obj.Generators,1,1) - vecnorm(obj.Generators,inf,1);
            k = [1,0]*sortrows([1:size(gk,2);gk].',2).';
            g = obj.Generators(:,k);
            n = obj.Dimension;
            h = diag(sum(abs(g(:,1:2*n)),2));
            f = str2func(class(obj));
            z = f([h,g(:,2*n + 1:end)],obj.Center);
        end
        function Z = generate(obj)
            M = cellfun(@(g)[-g,g],num2cell(obj.Generators,1),"uniform",0);
            if size(obj.Generators,2) <= obj.Dimension + 1
                Z = minkowskiSum(obj.Center,M{:});
                return;
            end
            Z = minkowskiSum(obj.Center,M{1:obj.Dimension});
            Z = unique(Z(:,convhulln(Z.')).',"rows","stable").';
            for i = obj.Dimension + 1:size(obj.Generators,2)
                Z = minkowskiSum(Z,M{i});
                Z = unique(Z(:,convhulln(Z.')).',"rows","stable").';
            end
        end 
    end
    methods (Access = protected)
        function validateDimensions(obj)
            if size(obj.Center,1) ~= size(obj.Generators,1)
                error("Center and Generators dimensions do not match");
            end
        end
        function validatePlusDimensions(obj,z)
            if obj.Dimension ~= z.Dimension
                error("Zonotopes must have the same dimension to be summed");
            end 
        end
        function validateMtimesDimensions(obj,A)
            msg = "A must have as many columns as the ztope has dimenions";
            if size(A,2) ~= size(obj.Center,1)
                error(msg);
            end
        end
        function g = removeZeroGenerators(~,gin)
            g = gin(:,any(gin,1));
        end
        function k_aligned = alignedPairs(~,g,tol)
            arguments
                ~;
                g double;
                tol (1,1) double {mustBePositive} = 1E-06;
            end
            k = nchoosek(1:size(g,2),2).';
            a = num2cell(g(:,k(1,:)),1);
            b = num2cell(g(:,k(2,:)),1);
            ang = cellfun(@(a,b)a.'*b./(norm(a)*norm(b)),a,b);
            inds = abs(1 - ang) < tol;
            ka = k(:,inds);
            [~,ia] = unique(ka(1,:));
            k_aligned = ka(:,ia);
        end
        function [gn,ga] = unalignedGenerators(obj,g)
            ka = obj.alignedPairs(g);
            kn = ~ismember(1:size(g,2),unique(ka).');
            gn = g(:,kn);
            ga = g(:,~kn);
        end  
        function g = condenseAligned(obj,gin)
            [gn,ga] = obj.unalignedGenerators(gin); 
            if isempty(ga)
                g = gn;
                return
            end
            k = obj.alignedPairs(ga);
            G = graph(k(1,:),k(2,:));
            bins = conncomp(G);
            gs = arrayfun(@(x)sum(ga(:,bins==x),2),unique(bins),"uniform",0);
            g = [cell2mat(gs),gn];
        end 
    end
end