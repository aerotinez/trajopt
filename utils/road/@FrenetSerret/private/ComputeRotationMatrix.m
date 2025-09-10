function rotation_matrix = ComputeRotationMatrix(obj)
    arguments
        obj (1,1) FrenetSerret;
    end
    rotation_matrix = [obj.Tangent,obj.Normal,obj.Binormal];
end