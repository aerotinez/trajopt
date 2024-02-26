function x_dot = sharpMotorcycleRoadRelative(x,u,params)
% States
d = x(1,:);
rel_head = x(2,:);
lean = x(3,:);
steer = x(4,:);
vy = x(5,:);
yaw_rate = x(6,:);
lean_rate = x(7,:);
steer_rate = x(8,:);
Yr = x(9,:);
Yf = x(10,:);
Msteer = x(11,:);

x_sd = [
    0;
    d;
    rel_head
    ];

x_sharp = [
    lean;
    steer;
    vy;
    yaw_rate;
    lean_rate;
    steer_rate;
    Yr;
    Yf
    ];

% Parameters
vx = params(1,:);
curvature = params(2,:);
p_sd = curvature;
p_sharp = params(3:end,:);

% sharp model
A = sharpMotorcycleStateMatrix(vx,p_sharp);
B = sharpMotorcycleInputMatrix(vx,p_sharp);
fsharp = A*x_sharp + B*Msteer;

% road-relative kinematics
u_sd = [
    vx;
    vy;
    yaw_rate
    ];

fsd = roadRelativeKinematics(x_sd,u_sd,p_sd);

x_dot = (1./fsd(1,:)).*[
    fsd(2:end,:);
    fsharp;
    u
    ];
end