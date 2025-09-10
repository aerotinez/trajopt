function curvature = ComputeCurvature(obj)
    arguments
        obj (1,1) FrenetSerret;
    end
    f1 = obj.FirstDerivative;
    f2 = obj.SecondDerivative;
    k = obj.Norm(cross(f1,f2))./(obj.Norm(f1).^3);
    curvature = simplify(k,'Steps',100);
end