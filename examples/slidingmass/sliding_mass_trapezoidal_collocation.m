close("all"); clear; clc;
import casadi.*

%% Define dae system

% Create a DaeBuilder object
dae = DaeBuilder('sliding_mass');

% Define the state variables
p = dae.add_x('x');
v = dae.add_x('v');

% Define the input variables
F = dae.add_u('F');

% Define parameters
m = dae.add_p('m');

% Define the differential equations
x = [p;v];
xdot = slidingMass(x,F,m);
dae.set_ode('x',xdot(1));
dae.set_ode('v',xdot(2));

% create Function
plant = dae.create('plant',{'x','u','p'},{'ode'});

%% Define objective function
% objfun = (1/2).*F.'*F;
objfun = 1;
objective = Function('objective',{x,F},{objfun},{'x','u'},{'L'});


%% Initialize NLP
opti = Opti();

% initial state conditions
X0 = opti.variable(2);
x0 = [0;0];
opti.set_initial(X0,x0);

% initial control conditions
U0 = opti.variable();
u0 = 0;
opti.set_initial(U0,u0);
opti.subject_to((-1 <= U0) <= 1);

% initialize cost
W0 = objective(X0,U0);

%% Define mesh
t0 = 0;
Tf = opti.variable(1);
opti.set_initial(Tf,10);
opti.subject_to(Tf > 0);

ns = 33 ;
M = ns + 1;
T = linspace(0,1,M);

%% Start boundary constraints
opti.subject_to(X0 == [0;0]);

%% Collocation constraints

% collect all states/controls
X = [{X0},cell(1,M - 1)];
U = [{U0},cell(1,M - 1)];
W = [{W0},cell(1,M - 1)];

tic;
for k = 1:M - 1
    X{k + 1} = opti.variable(2,1);
    opti.set_initial(X{k + 1},[0;0]);

    U{k + 1} = opti.variable();
    opti.set_initial(U{k + 1},0);
    opti.subject_to((-1 <= U{k + 1}) <= 1);

    f0 = plant(X{k},U{k},1);
    f1 = plant(X{k + 1},U{k + 1},1);
    h = (T(k + 1) - T(k))*(Tf - t0);
    opti.subject_to(X{k + 1} - X{k} - (h/2).*(f0 + f1) == zeros(2,1));

    W{k + 1} = objective(X{k + 1},U{k + 1});
end
toc;

%% End boundary conditions
opti.subject_to(X{end} == [1;0]);

%% Objective function
q = (Tf - t0).*[W{:}].';
b = (1/2).*sum([diff(T),0;0,diff(T)],1);
J = b*q;

%% Solve
X = [X{:}];
U = [U{:}];

opti.minimize(J);

opti.solver('ipopt');

tic;
sol = opti.solve();
toc;

tf = sol.value(Tf);
x_opt = sol.value(X);
u_opt = sol.value(U);

%% Interpolate state
t = linspace(0,tf,M);
ns = 100;

x = zeros(2,(M - 1)*ns);
f = @(x,u)full(plant(x,u,1));
for i = 1:M - 1
    x0 = x_opt(:,i);
    xf = x_opt(:,i + 1);
    u0 = u_opt(:,i);
    uf = u_opt(:,i + 1);
    x(:,ns*i - ns + 1:ns*i) = interpolateState(f,t(i),t(i + 1),x0,xf,u0,uf,ns);
end

%% Interpolate control
u = zeros(1,(M - 1)*ns);
for i = 1:M - 1
    u0 = u_opt(:,i);
    uf = u_opt(:,i + 1);
    u(:,ns*i - ns + 1:ns*i) = interpolateControl(t(i),t(i + 1),u0,uf,ns);
end

%% Plot the solution
res_h = 480;
res_v = 240;

%% State solution
state_title = [
    "Position";
    "Velocity"
    ];

state_unit = [
    "position (m)";
    "speed (m/s)"
    ];

fig_states = figure();
tiledlayout(2,1,"Parent",fig_states);
for i = 1:2
    nexttile;
    hold("on")
    scatter(t,x_opt(i,:),20,'k',"filled");
    plot(linspace(t0,tf,numel(x(i,:))),x(i,:),'k',"LineWidth",2);
    hold("off");
    box("on");
    xlim([t0,tf]);
    title(state_title(i));
    xlabel("time (s)");
    ylabel(state_unit(i));
end
set(fig_states,"Position",[240,360,res_h,2*res_v]);

%% Control solution
control_title = "Force";

control_unit = "force (N)";

fig_control = figure();
tiledlayout(1,1,"Parent",fig_control);
for i = 1:1
    nexttile;
    hold("on");
    plot(linspace(t0,tf,numel(u(i,:))),u(i,:),'k',"LineWidth",2);
    scatter(t,u_opt(i,:),20,'k',"filled");
    hold("off");
    box("on");
    xlim([t0,tf]);
    title(control_unit(i));
    xlabel("time (s)");
    ylabel(control_unit(i));
end
set(fig_control,"Position",[240 + 1.1*res_h,360,res_h,res_v]);

%% Functions
function x = interpolateState(f,t0,tf,x0,xf,u0,uf,ns)
t = linspace(t0,tf,ns);
f0 = f(x0,u0);
ff = f(xf,uf);
T = t - t0;
h = tf - t0;
a0 = T;
a1 = (T.^2)./(2.*h);
x = x0 + a0.*f0 + a1.*(ff - f0);
end

function u = interpolateControl(t0,tf,u0,uf,ns)
t = linspace(t0,tf,ns);
T = (t - t0)./(tf - t0);
u = u0 + T.*(uf - u0);
end