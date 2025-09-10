close("all"); clear; clc;
cd(fileparts(mfilename('fullpath')));

%% Imports
dirs = [
    "objfun";
    "parameters";
    "prydeMotorcycleStateSpace";
    "roadRelativeKinematicsDAE";
    "roads";
    "scenarios"
    ];

arrayfun(@addpath,dirs);

%% Constants
NUM_COLLOCATION_POINTS = 22;
SPEED = 130;
LANE_WIDTH = 3.5;

%% Scenario
scen = straightScenario;

%% Problem
prob = CollocationProblem(NUM_COLLOCATION_POINTS);
prob_units = Unit("arclength",'m');
s0 = FixedTime("s0",prob_units,0);
sf = FixedTime("sf",prob_units,scen.Parameter(end));

%% Parameters
bike = bigSportsParameters;
params = bikeSimToPrydeParameters(bike,SPEED/3.6);
p = cell2mat(struct2cell(params));

x0 = stateCostTrim(p,ones(7,1));
w0 = trimWheelSpeeds(p);
d0 = -LANE_WIDTH/2;
vx0 = SPEED/3.6;
wr0 = w0(1);
wf0 = w0(2);

u0 = inputCostTrim(p,ones(3,1));
My0 = abs(u0(1));

%% States
r = State(prob,"Relative heading",Unit("angle","rad"),0,0,0);
d = State(prob,"Offset",Unit("distance","m"),d0,d0,-d0,2*d0,-2*d0);
vx = State(prob,"Forward speed",Unit("speed","m/s"),vx0,vx0,vx0,1);
wr = State(prob,"Rear wheel speed",Unit("speed","rad/s"),wr0,NaN,NaN);
wf = State(prob,"Front wheel speed",Unit("speed","rad/s"),wf0,NaN,NaN);
camber = State(prob,"Camber",Unit("angle","rad"),0,0,0);
steer = State(prob,"Steer",Unit("angle","rad"),0,0,0);
wz = State(prob,"Yaw rate (body-fixed)",Unit("speed","rad/s"),0,0,0);
vy = State(prob,"Side speed",Unit("speed","m/s"),0,0,0);
wx = State(prob,"Roll rate (body-fixed)",Unit("speed","rad/s"),0,0,0);
ws = State(prob,"Steer rate (body-fixed)",Unit("speed","rad/s"),0,0,0);

x = StateVector([r,d,vx,wr,wf,camber,steer,wz,vy,wx,ws]);

%% Inputs
My = State(prob,"Throttle",Unit("torque","Nm"),My0,NaN,NaN,0);
Mb = State(prob,"Brake",Unit("torque","Nm"),0,0,0,0);
Ms = State(prob,"Steer torque",Unit("torque","Nm"),0,0,0);

u = StateVector([My,Mb,Ms]);

%% Curvature
tau = ([-1,sort(roots(legpol(prob.NumNodes - 2))).',1] + 1)/2;
k = interp1(scen.Parameter/scen.Parameter(end),scen.Curvature,tau);

%% Plant
sys = prydeMotorcycleStateSpace(p);
A = sys.A;

% Brake mapping
Rr = params.rr + params.tr;
Rf = params.rf + params.tf;
l = (params.a - params.an)/cos(params.caster);

Pb = [
    1,0,0;
    0,1,0;
    0,(params.b/l)*Rf/Rr,0;
    0,0,1
    ];

B = sys.B*Pb;

rr = params.rr;
fRoadRel = @roadRelativeKinematicsForcingVector;
frr = @(x,p)fRoadRel([0*x(1,:);x(1:2,:)],x(3:end,:),[p;rr]);
fs = @(x,p)[1,0,0]*frr(x,p);
fdr = @(x,p)[zeros(2,1),eye(2)]*frr(x,p);

f = @(x,u,p)(1/fs(x,p))*[
    fdr(x,p);
    sys.E\(A*(x(3:end,:) - sys.Offsets.x) + B*(u - sys.Offsets.u(1:3)))
    ];

plant = Plant(prob,x,u,k,f);

%% Objective

opts = optimoptions('fmincon', ...
    'Display','iter', ...
    'Algorithm','sqp' ...
    );

sfx = [
    1E09; % wfr (1E08)
    1E09; % wff (1E08)
    1E09; % wa (1E08)
    1E09; % wda
    0; % wac
    0; % wsr
    0; % wv
    ];

% Input cost weights
sfu = [
    1E04;
    1;
    1
    ];

Q = stateCost(p,sfx);
R = inputCost(p,sfu);
Jxu = @(x,u,p)(x(3:end,:) - x0)'*Q*(x(3:end,:) - x0) + u'*R*u;
Jt = @(x0,t0,xf,tf)0.*tf;

cost = Objective(plant,Jxu,Jt);

%% Nonlinear program
rwx = [
    1; % r
    1; % d
    1; % vx
    100; % wr
    100; % wf
    1; % camber
    1; % steer
    1; % wz
    1; % vy
    1; % wx
    1; % ws
    ];

Wx = rwx.*ones(11,3);

rwu = [
    10;
    1;
    1
    ];

Wu = rwu.*ones(3,3);

prog = LegendreGaussRadau(prob,cost,plant,s0,sf,Wx,Wu);
prog.solve();

%% Collect results
sc = prog.Time;
s = prog.interpolateTime();
zc = StateVector([r,d,vx,wr,wf,camber,steer,wz,vy,wx,ws,My,Mb,Ms]);
z = [
    prog.interpolateState(s);
    prog.interpolateControl(s)
    ];

fig = figure('Position',[100,50,1280,720]);
tl = tiledlayout(5,3,'Parent',fig,'Padding','compact','TileSpacing','compact');
for k = 1:14
    axe = nexttile(tl,k);
    hold(axe,'on');
    hc = scatter(axe,sc,zc.States(k).Value,10,'filled');
    h = plot(axe,s,z(k,:));
    h.Color = hc.CData;
    hold(axe,'off');
    box(axe,'on');
    axis(axe,'tight');
    title(axe,zc.States(k).Name);
    ylabel(axe,zc.States(k).Unit.Name + " (" + zc.States(k).Unit.Symbol + ")");
    if contains(zc.States(k).Unit.Symbol,"rad")
        h.YData = (180/pi)*h.YData;
        hc.YData = (180/pi)*hc.YData;
        axe.YLabel.String = strrep(axe.YLabel.String,"rad","deg");
    end
    if ~ismember(k,13:15)
        xticks(axe,[]);
    else
        xlabel(axe,"Progress (m)");
    end
end
sgtitle("Trajectory generation : Straight scenario");
leg = legend({"Big Sports",''});
leg.Orientation = "horizontal";
leg.Layout.Tile = "south";

%% Cleanup
arrayfun(@rmpath,dirs);