function normal = ComputeNormal(obj)
    arguments
        obj (1,1) FrenetSerret;
    end
    N = diff(obj.Tangent,obj.Parameter);
    normal = simplify(N./obj.Norm(N),'Steps',100); 
end