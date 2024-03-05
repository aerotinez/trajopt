function f = sharpMotorcycleRoadRelativeFactory(params)
x = sym('x_',[11,1]);
u = sym('u_',[1,1]);
p = sym('p_',[2,1]);
A = sharpMotorcycleRoadRelative(x,u,p,params);
f = matlabFunction(A,"Vars",{x,u,p});
end