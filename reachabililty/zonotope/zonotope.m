classdef zonotope
    properties (GetAccess = public, SetAccess = private)
        Center;
        Generators;
        Dimension;
        Order;
    end
    methods (Access = public)
        function obj = zonotope(genertors,center)
            arguments
                genertors double;
                center (:,1) double = zeros(size(genertors,1),1);
            end 
            obj.Center = center;
            obj.Generators = genertors;
            obj.validateDimensions();
            obj.Dimension = size(center,1);
            obj.Order = size(genertors,2)/obj.Dimension;
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
        function zn = mtimes(A,obj)
            arguments
                A double;
                obj zonotope;
            end
            obj.validateMtimesDimensions(A);
            c = A*obj.Center;
            g = A*obj.Generators;
            zn = zonotope(g,c);
        end
        function Z = generate(obj)
            f = @(x)[zeros(obj.Dimension,1),x];
            G = cellfun(f,num2cell(obj.Generators,1),'UniformOutput',false);
            Z = obj.Center + minkowskiSum(G{:});
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