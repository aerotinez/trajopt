function setFormula(obj)
    arguments
        obj (1,1) ArcSegment;
    end
    obj.Formula = @(s)obj.Radius.*[cos(s);sin(s);0.*s];
end