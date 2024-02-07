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
objective = ObjectiveFunction();
objective.setLagrange(1,x,F);

%% Mesh
ns = 10;
M = ns + 1;
mesh = linspace(0,1,M);

%% NLP
nlp = Trapezoidal(objective,plant,mesh);
nlp.setState([0;0]);
nlp.setControl(0);
nlp.setParameters(1);
nlp.setInitialState([0;0]);
nlp.setFinalState([1;0]);
nlp.setState([0;0]);
nlp.setControl(0);
nlp.setControlBounds(-1,1);
nlp.setInitialTime(0);
nlp.setFinalTimeGuess(10);
nlp.setFinalTimeLowerBound(0);

%% Solution
nlp.solve();

state_name = [
    "Position";
    "Velocity"
    ];

nlp.setStateName(state_name);

state_unit = [
    "position (m)";
    'speed (m/s)'
    ];

nlp.setStateUnit(state_unit);

control_name = "Force";

nlp.setControlName(control_name);

control_unit = "force (N)";

nlp.setControlUnit(control_unit);

nlp.plotState(2,1);
nlp.plotControl(1,1);