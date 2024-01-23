close("all"); clear; clc;
N = 20;
nx = 7;
nu = 2;
r = 0.5;
v = 20/3.6;
w = v/r;
xi = [0;0;0;0;0;0;w];
xf = [10;1;0;0;0;0;w];
params = [9.81,1,r].';
I = eye(8);
f = @(x,u,p)I([1:4,6:8],:)*rollingDisk([x(1:4);0;x(5:7)],u,p);
plant = Plant(f,xi,xf,nu,params);
C = CollocationConstraints(plant,@trapezoidalConstraints,N);
M = [
    1;
    1
    ];

x0 = repmat([0;0;0;0;0;0;w],[1,N]);
u0 = zeros(nu,N);
tf0 = 1;
X = [
    reshape([x0;u0],[],1);
    tf0
    ];

xlb = -repmat([inf;inf;deg2rad(45);deg2rad(45);inf;inf;0],[1,N]);
ulb = -M.*ones(nu,N);
tflb = 0;
lb = [
    reshape([xlb;ulb],[],1);
    tflb
    ];

xub = repmat([inf;inf;deg2rad(45);deg2rad(45);inf;inf;inf],[1,N]);
uub = M.*ones(nu,N);
tfub = inf;
ub = [
    reshape([xub;uub],[],1);
    tfub
    ];

A = [];
b = [];
Aeq = [];
beq = [];

options = optimoptions( ...
    'fmincon', ...
    'Display','iter', ...
    'EnableFeasibilityMode',true, ...
    'SpecifyConstraintGradient',true, ...
    'OptimalityTolerance',1E-04, ...
    'ConstraintTolerance',1E-04, ...
    'MaxFunctionEvaluations',1e5, ...
    'MaxIterations',1e3, ...
    "UseParallel",true ...
    );

sol = fmincon(@fun,X,A,b,Aeq,beq,lb,ub,@C.nonlcon,options);

tf = sol(end);
t = linspace(0,tf,N);
X = reshape(sol(1:end-1),nx + nu,[]);

titles = [
    "x";
    "y";
    "yaw";
    "lean";
    "yaw rate";
    "lean rate";
    "pitch rate";
    "pitch torque";
    "yaw torque"
    ];

figure();
tiledlayout(3,3);
for i = 1:nx + nu
    nexttile;
    plot(t,X(i,:));
    xlim([0,tf]);
    title(titles(i));
end

function J = fun(x)
tf = x(end);
X = reshape(x(1:end -1),9,[]);
u = X(end-1:end,:);
% J = tf + (1/2).*u(:).'*u(:);
J = tf;
end