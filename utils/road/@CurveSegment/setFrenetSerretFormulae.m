function setFrenetSerretFormulae(obj)
    arguments
        obj (1,1) CurveSegment;
    end
    obj.FS = FrenetSerret(obj.Formula);
    t = obj.FS.Parameter;
    R = obj.FS.RotationMatrix;
    k = obj.FS.Curvature;
    obj.fRotationMatrix = matlabFunction(R,'Vars',{t});
    obj.fCurvature = matlabFunction(k,'Vars',{t});
end