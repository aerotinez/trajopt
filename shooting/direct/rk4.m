function x_dot = rk4(f,x,u,dt)
    arguments
        f (1,1) function_handle; % plant dynamics
        x (:,1) double; % states
        u (:,1) double; % controls
        dt (1,1) double; % step size
    end
    k1 = f(x,u);
    k2 = f(x + k1*dt/2,u);
    k3 = f(x + k2*dt/2,u);
    k4 = f(x + k3*dt,u);
    x_dot = x + (k1 + 2*k2 + 2*k3 + k4)*dt/6;
end