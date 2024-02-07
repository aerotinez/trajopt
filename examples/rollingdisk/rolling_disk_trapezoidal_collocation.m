close("all"); clear; clc;
import casadi.*;

%% Define dae system
dae = DaeBuilder('rolling_disk');

% Define states
px = dae.add_x('x');
py = dae.add_x('y');
yaw = dae.add_x('psi');
lean = dae.add_x('varphi');
yaw_rate = dae.add_x('psi_dot');
lean_rate = dae.add_x('varphi_dot');
pitch_rate = dae.add_x('theta_dot');

% Define inputs
My = dae.add_u('tau_y');
Mz = dae.add_u('tau_z');

% Define parameters
gravity = dae.add_p('g');
mass = dae.add_p('m');
radius = dae.add_p('r');

% Define differential equations
x = [
    px;
    py;
    yaw;
    lean;
    yaw_rate;
    lean_rate;
    pitch_rate
];

u = [
    My;
    Mz
];

p = [
    gravity;
    mass;
    radius
];

xdot = rollingDisk([x(1:4);0;x(5:end)],u,p);
dae.set_ode('x',xdot(1));
dae.set_ode('y',xdot(2));
dae.set_ode('psi',xdot(3));
dae.set_ode('varphi',xdot(4));
dae.set_ode('psi_dot',xdot(6));
dae.set_ode('varphi_dot',xdot(7));
dae.set_ode('theta_dot',xdot(8));

% create Function
plant = dae.create('plant', {'x', 'u', 'p'}, {'ode'});

%% Define objective function
objective = ObjectiveFunction();
objective.setLagrange(1,x,u);

%% Mesh
ns = 100;
M = ns + 1;
mesh = linspace(0,1,M);

%% NLP
nlp = HermiteSimpson(objective,plant,mesh);
nlp.setState([0;0;0;0;0;0;0]);
nlp.setControl([0;0]);
nlp.setParameters([9.81;7;0.297]);
nlp.setInitialState([0;0;0;0;0;0;0]);
nlp.setFinalState([10;1;0;0;0;0;0]);
nlp.setControlBounds([-1;-1],[1;1]);
nlp.setInitialTime(0);
nlp.setFinalTimeGuess(30);
nlp.setFinalTimeLowerBound(0);
nlp.setMidState([0;0;0;0;0;0;0]);
nlp.setMidControl([0;0]);

%% Solution
nlp.solve();
state_name = [
    "Longitudinal position";
    "Lateral position";
    "Yaw";
    "Lean";
    "Yaw rate";
    "Lean rate";
    "Pitch rate"
];
nlp.setStateName(state_name);
state_unit = [
    "position (m)";
    "position (m)";
    "angle (rad)";
    "angle (rad)";
    "speed (rad/s)";
    "speed (rad/s)";
    "speed (rad/s)"
];
nlp.setStateUnit(state_unit);

control_name = [
    "Pitch torque";
    "Yaw torque"
];
nlp.setControlName(control_name);
control_unit = [
    "torque (Nm)";
    "torque (Nm)"
];
nlp.setControlUnit(control_unit);

nlp.plotState(4,2);
nlp.plotControl(2,1);