close("all"); clear; clc;
import casadi.*

%% Define dae system

% Create a DaeBuilder object
dae = DaeBuilder('sliding_mass');

% Define the state variables
p = dae.add_x('x');
dae.set_unit('x','m');
v = dae.add_x('v');
dae.set_unit('v','m/s');

% Define the input variables
F = dae.add_u('F');
dae.set_unit('F','N');

% Define parameters
m = dae.add_p('m');
dae.set_unit('m','kg');

% Define the differential equations
x = [p;v];
xdot = slidingMass(x,F,m);
dae.set_ode('x',xdot(1));
dae.set_ode('v',xdot(2));

