function sharp_params = bikeSimToSharp(bikesim_params)
arguments
    bikesim_params (1,1) BikeSimMotorcycleParameters;
end
bs = bikesim_params;
s = SharpModel1971StraightRunParameters;

%% geometric parameters
s.rf = bs.FrontTire.EffectiveRollingRadius;
s.rr = bs.RearTire.EffectiveRollingRadius;
s.varepsilon = deg2rad(bs.SteeringHead.Caster);
s.an = s.rf*sin(s.varepsilon) - bs.SteeringHead.Rake;

%%
I = @(Ixx,Iyy,Izz,Ixz)Inertia(Ixx,Iyy,Izz,'Ixz',Ixz).tensor;
body = @(m,p,Ixx,Iyy,Izz,Ixz,N)struct('m',m,'p',p,'I',I(Ixx,Iyy,Izz,Ixz),'R',N.dcm());
N = ReferenceFrame;
O = Point;

%% Sprung mass
SM = bs.SprungMass;
pSM = O.locateNew(-SM.CoMOffset.*N.x + SM.CoMHeight.*N.z);
sm = body(SM.Mass,pSM.posFrom,SM.Ixx,SM.Iyy,SM.Izz,SM.Ixz,N);

%% Rider lower body
RL = bs.RiderLowerBody;
pRL = O.locateNew(-RL.CoMOffset.*N.x + RL.CoMHeight.*N.z);
rl = body(RL.Mass,pRL.posFrom,RL.Ixx,RL.Iyy,RL.Izz,RL.Ixz,N);

%% Rider upper body
RU = bs.RiderUpperBody;
NRU = N.orientNew('y',deg2rad(RU.ForwardLean));
pRU = O.locateNew(-RU.CoMOffset.*N.x + RU.LeanAxisHeight.*N.z + RU.CoMHeight.*NRU.z);
ru = body(RU.Mass,pRU.posFrom,RU.Ixx,RU.Iyy,RU.Izz,RU.Ixz,NRU);

%% Swing arm
SA = bs.SwingArm;
Wr = O.locateNew(-SM.Wheelbase.*N.x + SA.AxelHeight.*N.z);
NSA = N.orientNew('y',-asin((SA.PivotHeight - SA.AxelHeight)/SA.Length));
pSA = Wr.locateNew(SA.CoMOffset.*NSA.x + SA.CoMHeight.*NSA.z);
sa = body(SA.Mass,pSA.posFrom,0,0,0,0,NSA);

%% Rear tire
RT = bs.RearTire;
pRT = O.locateNew(-SM.Wheelbase.*N.x + s.rr.*N.z);
rt = body(RT.Mass,pRT.posFrom,0,RT.SpinInertia,0,0,N);
s.iry = RT.SpinInertia;

%% Steering head
SH = bs.SteeringHead;
NSH = N.orientNew('y',-s.varepsilon);
Wf = O.locateNew(s.rf.*N.z);
H = Wf.locateNew(-SH.Rake.*NSH.x + SH.ForkLength.*NSH.z);
pSH = H.locateNew(SH.CoMOffset.*NSH.x + SH.CoMHeight.*NSH.z);
sh = body(SH.Mass,pSH.posFrom,SH.Ixx,SH.Iyy,SH.Izz,SH.Ixz,NSH);

%% Fork
F = bs.Fork;
pF = H.locateNew(F.CoMOffset.*NSH.x - F.CoMHeight.*NSH.z);
f = body(F.Mass,pF.posFrom,0,0,0,0,NSH);

%% Front tire
FT = bs.FrontTire;
pFT = Wf;
ft = body(FT.Mass,pFT.posFrom,0,FT.SpinInertia,0,0,N);
s.ify = FT.SpinInertia;

%% inertial parameters
G = @(b,m)sum(cell2mat(arrayfun(@(b)b.m.*b.p,b.','uniform',0)),2)./m;
fp = @(b,p)b.p - p;
fI = @(b,p)b.R*b.I*b.R.' + b.m.*(fp(b,p).'*fp(b,p).*eye(3) - fp(b,p)*fp(b,p).');
I = @(b,p)sum(cell2mat(reshape(arrayfun(@(b)fI(b,p),b,'uniform',0),1,1,[])),3);

%% Rear body
rear_bodies = [
    sm
    rl
    ru
    sa
    rt
    ];

s.mr = sum([rear_bodies.m]);
pr = G(rear_bodies,s.mr);
s.b = SM.Wheelbase + pr(1);
s.h = pr(3);
Ir = I(rear_bodies.',pr);
s.Irx = Ir(1,1);
s.Irz = Ir(3,3);
s.Crxz = Ir(1,3);
s.g = 9.81;

%% Front body
front_bodies = [
    sh
    f
    ft
    ];
s.mf = sum([front_bodies.m]);
pf = G(front_bodies,s.mf);
If = I(front_bodies.',pf);
s.Ifx = If(1,1);
s.Ifz = If(3,3);

%% derived geometric parameters
l = SM.Wheelbase - s.b;
s.a = l*cos(s.varepsilon) + s.an;
A = O.locateNew(-l.*N.x);
B = A.locateNew(s.a.*NSH.x);
pGf = NSH.dcm.'*(pf - B.posFrom);
s.e = pGf(1);
s.f = pGf(3);

%% normal front tire force
m = s.mr + s.mf;
p = (s.mr.*pr + s.mf.*pf)./m;
s.Zf = p(1)*m*s.g/SM.Wheelbase;

%% steering stiffness
s.Cdelta = (180/pi)*SH.Damping;

%% tire parameters
s.Cr1 = bs.RearTire.CorneringStiffness;
s.Cr2 = bs.RearTire.CamberStiffness;
s.Cf1 = bs.FrontTire.CorneringStiffness;
s.Cf2 = bs.FrontTire.CamberStiffness;
s.sigma = bs.FrontTire.RelaxationLength;

% fig = figure();
% axe = axes(fig);
% hold(axe,'on');
% ang = linspace(0,2*pi,1000);
% c = 0.7.*ones(1,3);
% wheel = @(r,G)patch(r.*cos(ang) + G(1),r.*sin(ang) + G(3),c,'LineWidth',2);
% wheel(s.rr,rt.p);
% wheel(s.rf,ft.p);
% pff = [Wf.posFrom,Wf.locateNew(-SH.Rake.*NSH.x).posFrom,H.posFrom];
% plot(pff(1,:),pff(3,:),'Color','k','LineWidth',2);
% c = matplotlibcolors();
% c = c(1:numel([rear_bodies;front_bodies]),:);
% fplot = @(b,c)scatter(b.p(1),b.p(3),'filled','CData',c);
% cellfun(fplot,num2cell([rear_bodies;front_bodies],2),num2cell(c,2));
% c = matplotlibcolors();
% scatter(pr(1),pr(3),'filled','CData',c(9,:),'SizeData',100);
% scatter(pf(1),pf(3),'filled','CData',c(10,:),'SizeData',100);
% A = O.locateNew((-SM.Wheelbase + s.b).*N.x);
% pA = A.posFrom;
% B = A.locateNew(s.a.*NSH.x);
% pB = B.posFrom;
% Gf = B.locateNew(s.e.*NSH.x + s.f.*NSH.z);
% pGf = Gf.posFrom;
% scatter(pA(1),0,'filled');
% scatter(pB(1),pB(3),'filled');
% scatter(pGf(1),pGf(3),'filled');
% hold(axe,'off');
% box(axe,'on');
% axis(axe,'equal');
% xlim(axe,[-(SM.Wheelbase + s.rr),s.rf]);
% nms = [
%     "";
%     "";
%     "";
%     "Sprung mass";
%     "Rider lower body";
%     "Rider upper body";
%     "Swing arm";
%     "Rear tire";
%     "Steering head";
%     "Fork";
%     "Front tire";
%     "Rear body";
%     "Front body";
%     "A";
%     "B";
%     "Gf";
%     ];
% legend(axe,nms,'Location','eastoutside');

%% out
sharp_params = s;