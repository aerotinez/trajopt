close("all"); clear; clc;
N = 25;
xi = [0;0];
xf = [1;0];
plant = Plant(@slidingMass,xi,xf,1,1);
C = CollocationConstraints(plant,@trapezoidalConstraints,N);

x0 = zeros(2,N);
u0 = zeros(1,N);
tf0 = 1;
X = [
    reshape([x0;u0],[],1);
    tf0
    ];

fun = @(x)x(end);

xlb = -inf(2,N);
ulb = -ones(1,N);
tflb = 0;
lb = [
    reshape([xlb;ulb],[],1);
    tflb
    ];

xub = inf(2,N);
uub = ones(1,N);
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
    'Algorithm','sqp', ...
    'Display','iter', ...
    "EnableFeasibilityMode",true, ...
    'MaxFunctionEvaluations',1e5, ...
    'MaxIterations',1e5, ...
    "SpecifyConstraintGradient",true, ...
    "UseParallel",true ...
    );

sol = fmincon(fun,X,A,b,Aeq,beq,lb,ub,@C.nonlcon,options);

tf = sol(end);
t = linspace(0,tf,N);
X = reshape(sol(1:end-1),3,[]);

figure();
tiledlayout(3,1);
for i = 1:3
    nexttile;
    plot(t,X(i,:));
    xlim([0,tf]);
end