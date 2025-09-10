function binormal = ComputeBinormal(obj)
    arguments
        obj (1,1) FrenetSerret;
    end
    binormal = simplify(cross(obj.Tangent,obj.Normal),'Steps',100);
end