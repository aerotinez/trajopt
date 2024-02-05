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

% create Function
plant = dae.create('plant',{'x','u','p'},{'ode'});

%% Define objective function

objfun = (1/2).*F.'*F;
objective = Function('objective',{x,F},{objfun},{'x','u'},{'L'});

%% Define collocation polynomials

% degree of polynomial
d = 2;

% Get collocation points
tau = collocation_points(d,'legendre');

% Collocation linear maps
[C,D,B] = collocation_coeff(tau);

%% Finite horizon

tf = 1;
ns = 1000;
M = ns + 1;
h = tf/ns;

%% Initialize NLP

opti = Opti();
J = 0;

% initial conditions
Xk = opti.variable(2);
x0 = [0;0];
opti.subject_to(Xk == [0;0]);
opti.set_initial(Xk,x0);

% collect all states/controls
Xs = [{Xk},cell(1,M-1)];
Us = cell(1,M);

%% Formulate NLP

for k = 0:M - 1
   % New NLP variable for the control
   Uk = opti.variable();
   Us{k + 1} = Uk;
   opti.set_initial(Uk,0);

   % Decision variables for helper states at each collocation point
   Xc = opti.variable(2,d);
   opti.set_initial(Xc,repmat([0;0],1,d));

   % Evaluate ODE right-hand-side at all helper states
   ode = plant(Xc,Uk,1);
   L = objective(Xc,Uk);

   % Add contribution to quadrature function
   J = J + L*B*h;

   % Get interpolating points of collocation polynomial
   Z = [Xk,Xc];

   % Get slope of interpolating polynomial (normalized)
   Pidot = Z*C;
   % Match with ODE right-hand-side 
   opti.subject_to(Pidot == h*ode);

   % State at end of collocation interval
   Xk_end = Z*D;

   % New decision variable for state at end of interval
   Xk = opti.variable(2);
   Xs{k + 1} = Xk;
   opti.set_initial(Xk,[0;0]);

   % Continuity constraints
   opti.subject_to(Xk_end == Xk)
end
opti.subject_to(Xk == [1;0]);

Xs = [Xs{:}];
Us = [Us{:}];

opti.minimize(J);

opti.solver('ipopt');

sol = opti.solve();

x_opt = sol.value(Xs);
u_opt = sol.value(Us);

% Plot the solution
tgrid = linspace(0,tf,M);

hold("on");
plot(tgrid,x_opt(1,:))
plot(tgrid,x_opt(2,:))
hold("off");