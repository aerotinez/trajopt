function tangent = ComputeTangent(obj)
    arguments
        obj (1,1) FrenetSerret;
    end
    T = obj.FirstDerivative./obj.Norm(obj.FirstDerivative);
    tangent = simplify(T,'Steps',100);
end