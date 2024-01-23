function results = trapezoidalInterpolation(plant,t,x,u)
    arguments
        plant (1,1) Plant;
        t (:,1) double;
        x double;
        u double;
    end
    validateInputs(t,x,u);
    n = 1000;
    results = [
        interpolateStates(plant.Dynamics,t,x,u,n);
        interpolateControls(t,u,n);
    ];
end
function x_interp = interpolateStates(f,t,x,u,n)
    k = numel(t);
    nx = size(x,1); 
    x_interp = zeros(nx,n*(k - 1));
    for i = 1:k - 1
        h = t(i + 1) - t(i);
        T = linspace(t(i),t(i + 1),n) - t(i);
        x0 = x(:,i);
        x1 = x(:,i + 1);
        u0 = u(:,i);
        u1 = u(:,i + 1);
        f0 = f(x0,u0);
        f1 = f(x1,u1);
        idx = (i - 1)*n + 1:i*n;
        x_interp(:,idx) = x0 + f0.*T + ((T.^2)./(2*h)).*(f1 - f0);
    end
end
function u_interp = interpolateControls(t,u,n)
    k = numel(t);
    nu = size(u,1);
    u_interp = zeros(nu,n*(k - 1));
    for i = 1:k - 1
        h = t(i + 1) - t(i);
        T = linspace(t(i),t(i + 1),n) - t(i);
        u0 = u(:,i);
        u1 = u(:,i + 1);
        idx = (i - 1)*n + 1:i*n;
        u_interp(:,idx) = u0 + (T./h).*(u1 - u0);
    end 
end
function validateInputs(t,x,u)
    if ~isequal(numel(t),size(x,2),size(u,2))
        error("The number of time steps must be the same for all inputs.")
    end
end