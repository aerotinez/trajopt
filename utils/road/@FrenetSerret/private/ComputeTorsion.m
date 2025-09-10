function torsion = ComputeTorsion(obj)
    arguments
        obj (1,1) FrenetSerret;
    end
    f1 = obj.FirstDerivative;
    f2 = obj.SecondDerivative;
    f3 = obj.ThirdDerivative;
    num = f1.'*cross(f2,f3);
    den = obj.Norm(cross(f1,f2))^2;
    torsion = simplify(num./den,'Steps',100);
end