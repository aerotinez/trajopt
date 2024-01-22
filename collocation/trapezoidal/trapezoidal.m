function Ceq = trapezoidal(f,x0,u0,x1,u1,dt)
    arguments
        f (1,1) function_handle;
        x0; 
        u0; 
        x1; 
        u1;
        dt (1,1); 
    end
    Ceq = x1 - (x0 + (dt/2).*(f(x0,u0) + f(x1,u1)));
end