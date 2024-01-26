close("all"); clear; clc;
N = 10;
xi = [0;deg2rad(180);0;0];
xf = [2;0;0;0];
params = [-9.81,0.5,1,0.3].';
plant = Plant(@invertedPendulumAndCart,xi,xf,1,params);
nx = 4;
nu = 1;
C = CollocationConstraints(plant,@trapezoidalConstraints,N);
M = 10;

x0 = zeros(nx,N);
u0 = zeros(nu,N);
tf0 = 2;
X = [
    reshape([x0;u0],[],1);
    tf0
    ];

xlb = -inf(nx,N);
ulb = -M.*ones(nu,N);
tflb = 0;
lb = [
    reshape([xlb;ulb],[],1);
    tflb
    ];

xub = inf(nx,N);
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
    'MaxFunctionEvaluations',1e5, ...
    'MaxIterations',1e5, ...
    "UseParallel",true ...
    );

sol = fmincon(@fun,X,A,b,Aeq,beq,lb,ub,@C.nonlcon,options);

tf = sol(end);
t = linspace(0,tf,N);
X = reshape(sol(1:end-1),nx + nu,[]);

figure();
tiledlayout(nx + nu,1);
for i = 1:nx + nu
    nexttile;
    plot(t,X(i,:));
    xlim([0,tf]);
end

function J = fun(x)
tf = x(end);
X = reshape(x(1:end -1),5,[]);
u = X(end,:);
J = tf + 0.5.*u(:).'*u(:);
% J = tf;
end