classdef FrenetSerret
    properties (Access = public)
        Expression;
        Parameter;
        FirstDerivative;
        SecondDerivative;
        ThirdDerivative;
        Tangent;
        Normal;
        Binormal;
        RotationMatrix;
        Curvature;
        Torsion;
    end
    properties (Access = private)
        Norm = @(x)simplify(sqrt(x.'*x),'Steps',100);
    end
    methods (Access = public)
        function obj = FrenetSerret(expression,parameter)
            obj.Expression = expression;
            obj.Parameter = parameter;
            obj.FirstDerivative = diff(obj.Expression,obj.Parameter,1);
            obj.SecondDerivative = diff(obj.Expression,obj.Parameter,2);
            obj.ThirdDerivative = diff(obj.Expression,obj.Parameter,3);
            obj.Tangent = obj.ComputeTangent();
            obj.Normal = obj.ComputeNormal();
            obj.Binormal = obj.ComputeBinormal();
            obj.RotationMatrix = obj.ComputeRotationMatrix();
            obj.Curvature = obj.ComputeCurvature();
            obj.Torsion = obj.ComputeTorsion();
        end
    end
    methods (Access = private) 
        function tangent = ComputeTangent(obj)
            T = obj.FirstDerivative./obj.Norm(obj.FirstDerivative);
            tangent = simplify(T,'Steps',100);
        end
        function normal = ComputeNormal(obj)
            N = diff(obj.Tangent,obj.Parameter);
            normal = simplify(N./obj.Norm(N),'Steps',100); 
        end
        function binormal = ComputeBinormal(obj)
            binormal = simplify(cross(obj.Tangent,obj.Normal),'Steps',100);
        end
        function rotation_matrix = ComputeRotationMatrix(obj)
            rotation_matrix = [obj.Tangent,obj.Normal,obj.Binormal];
        end
        function curvature = ComputeCurvature(obj)
            f1 = obj.FirstDerivative;
            f2 = obj.SecondDerivative;
            k = obj.Norm(cross(f1,f2))./(obj.Norm(f1).^3);
            curvature = simplify(k,'Steps',100);
        end
        function torsion = ComputeTorsion(obj)
            f1 = obj.FirstDerivative;
            f2 = obj.SecondDerivative;
            f3 = obj.ThirdDerivative;
            num = f1.'*cross(f2,f3);
            den = obj.Norm(cross(f1,f2))^2;
            torsion = simplify(num./den,'Steps',100);
        end
    end 
end