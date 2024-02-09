close("all"); clear; clc;
import casadi.*

%% Define dae system
dae = DaeBuilder('inverted_pendulum_and_cart');

% Define states
position = dae.add_x('x');
angle = dae.add_x('theta');
velocity = dae.add_x('v');
angular_velocity = dae.add_x('omega');

% Define inputs
force = dae.add_u('F');

% Define parameters
gravity = dae.add_p('g');
length_pendulum = dae.add_p('l');
mass_cart = dae.add_p('m_c');
mass_pendulum = dae.add_p('m_p');

% Define differential equations
x = [
    position;
    angle;
    velocity;
    angular_velocity;
];

u = force;

p = [
    gravity;
    length_pendulum;
    mass_cart;
    mass_pendulum;
];

xdot = invertedPendulumAndCart(x,u,p);
dae.set_ode('x',xdot(1));
dae.set_ode('theta',xdot(2));
dae.set_ode('v',xdot(3));
dae.set_ode('omega',xdot(4));

% create Function
plant = dae.create('plant', {'x','u','p'}, {'ode'});

%% Define objective function
objective = ObjectiveFunction();
objective.setLagrange(1,x,u);

%% Mesh
ns = 25;
M = ns + 1;
mesh = linspace(0,1,M);

%% NLP
nlp = HermiteSimpson(objective,plant,mesh);
nlp.setState([0;0;0;0]);
nlp.setControl(0);
nlp.setParameters([-9.81;0.3;0.5;0.2]);
nlp.setInitialState([0,deg2rad(-180),0,0]);
nlp.setFinalState([2,0,0,0]);
nlp.setControlBounds(-100,100);
nlp.setInitialTime(0);
nlp.setFinalTimeGuess(10);
nlp.setFinalTimeLowerBound(0);
nlp.setMidState([0;0;0;0]);
nlp.setMidControl(0);

%% Solution
nlp.solve();
state_name = [
    "Position";
    "Angle";
    "Velocity";
    "Angular velocity";
];
nlp.setStateName(state_name);
state_unit = [
    "position (m)";
    "angle (rad)";
    "speed (m/s)";
    "speed (rad/s)";
];
nlp.setStateUnit(state_unit);

control_name = "Force";
nlp.setControlName(control_name);
control_unit = "force (N)";
nlp.setControlUnit(control_unit);

nlp.plotState(2,2);
nlp.plotControl(1,1);