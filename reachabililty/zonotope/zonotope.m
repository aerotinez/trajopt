classdef zonotope
    properties (GetAccess = public, SetAccess = private)
        Center;
        Generators;
        Dimension;
        Order;
    end
    methods (Access = public)
        function obj = zonotope(generators,center)
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
                za zonotope;
                zb zonotope;
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
                z zonotope;
            end
            z.validateMtimesDimensions(A);
            c = A*z.Center;
            g = A*z.Generators;
            f = str2func(class(z));
            zn = f(g,c);
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
            msg = "A must have as many columns as the zonotope has dimenions";
            if size(A,2) ~= size(obj.Center,1)
                error(msg);
            end
        end 
    end
end