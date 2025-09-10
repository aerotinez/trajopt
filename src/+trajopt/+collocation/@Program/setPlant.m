function setPlant(obj,f)
    arguments
        obj (1,1) trajopt.collocation.Program;
        f (1,1) function_handle;
    end
    x = casadi.MX.sym('x',obj.NumStates);
    u = casadi.MX.sym('u',obj.NumControls);
    p = casadi.MX.sym('p',obj.NumParameters);
    vars = {x,u,p};
    inputs = {'x','u','p'};
    outputs = {'dx'};
    
    obj.Plant = casadi.Function( ...
        'plant', ...
        vars, ...
        {f(x,u,p)}, ...
        inputs, ...
        outputs ...
        );
end