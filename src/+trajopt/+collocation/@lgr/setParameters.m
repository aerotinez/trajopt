function setParameters(obj,params)
    arguments
        obj (1,1) trajopt.collocation.lgr;
        params table;
    end
    p = table2array(params);
    sz = [obj.NumNodes - 1,size(p,2)];
    validateattributes(p,{'double'},{'size',sz},mfilename,'params');
    obj.Parameters = obj.Problem.parameter(sz(2),sz(1));
    obj.Problem.set_value(obj.Parameters,p');
    obj.NumParameters = sz(2);
end