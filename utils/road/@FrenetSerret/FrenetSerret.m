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
            arguments
                expression (1,1) function_handle;
                parameter (1,1) sym = sym('t');
            end
            obj.Expression = expression(parameter);
            obj.Parameter = parameter;
            obj.FirstDerivative = diff(obj.Expression,obj.Parameter,1);
            obj.SecondDerivative = diff(obj.Expression,obj.Parameter,2);
            obj.ThirdDerivative = diff(obj.Expression,obj.Parameter,3);
            obj.Tangent = ComputeTangent(obj);
            obj.Normal = ComputeNormal(obj);
            obj.Binormal = ComputeBinormal(obj);
            obj.RotationMatrix = ComputeRotationMatrix(obj);
            obj.Curvature = ComputeCurvature(obj);
            obj.Torsion = ComputeTorsion(obj);
        end
    end
    methods (Access = private)
        T = ComputeTangent(obj);
        N = ComputeNormal(obj);
        B = ComputeBinormal(obj);
        R = ComputeRotationMatrix(obj);
        k = ComputeCurvature(obj);
        t = ComputeTorsion(obj);
    end
end