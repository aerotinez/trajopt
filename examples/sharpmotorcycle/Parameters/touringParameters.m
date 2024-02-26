function params = touringParameters()
SM = SprungMass;
set(SM,'Mass',400);
set(SM,'Ixx',25.2);
set(SM,'Iyy',52.7);
set(SM,'Izz',36.3);
set(SM,'Ixz',-3);
set(SM,'Rx',251E-03);
set(SM,'Ry',363E-03);
set(SM,'Rz',301E-03);
set(SM,'CoMOffset',700E-03);
set(SM,'CoMHeight',400E-03);
set(SM,'Wheelbase',1664E-03);

RU = RiderUpperBody;
set(RU,'Mass',43.52);
set(RU,'Ixx',1.428);
set(RU,'Iyy',1.347);
set(RU,'Izz',0.916);
set(RU,'Ixz',0.433);
set(RU,'Rx',181E-03);
set(RU,'Ry',176E-03);
set(RU,'Rz',145E-03);
set(RU,'ForwardLean',11);
set(RU,'LeanAxisHeight',810E-03);
set(RU,'CoMOffset',1230E-3);
set(RU,'CoMHeight',100E-03);

RL = RiderLowerBody;
set(RL,'Mass',25.84);
set(RL,'Ixx',0.5);
set(RL,'Iyy',0.5);
set(RL,'Izz',0.5);
set(RL,'Ixz',0);
set(RL,'Rx',139E-03);
set(RL,'Ry',139E-03);
set(RL,'Rz',139E-03);
set(RL,'CoMOffset',861E-03);
set(RL,'CoMHeight',600E-03);

SH = SteeringHead;
set(SH,'Mass',9.99);
set(SH,'Ixx',1.341);
set(SH,'Iyy',1.584);
set(SH,'Izz',0.4125);
set(SH,'Ixz',0.0);
set(SH,'Rx',366E-03);
set(SH,'Ry',398E-03);
set(SH,'Rz',203E-03);
set(SH,'CoMOffset',-4E-03);
set(SH,'CoMHeight',125E-03);
set(SH,'ForkLength',700E-03);
set(SH,'Rake',86E-03);
set(SH,'Caster',29);
set(SH,'Damping',0.15);

F = Fork;
set(F,'Mass',7.25);
set(F,'CoMOffset',98.2507E-03);
set(F,'CoMHeight',410.613E-03);

FT = Tire;
set(FT,'EffectiveRollingRadius',313E-03);
set(FT,'Mass',10);
set(FT,'UndeflectedCrownRadius',50E-03);
set(FT,'SpinInertia',0.6);
set(FT,'CorneringStiffness',2.4931E04);
set(FT,'CamberStiffness',1.7450E03);
set(FT,'RelaxationLength',0.1949);

SA = SwingArm;
set(SA,'Mass',8);
set(SA,'Length',400E-03);
set(SA,'CoMOffset',214E-03);
set(SA,'CoMHeight',0E-03);
set(SA,'PivotHeight',313E-03);
set(SA,'AxelHeight',313E-03);

RT = Tire;
set(RT,'EffectiveRollingRadius',313E-03);
set(RT,'Mass',18);
set(RT,'UndeflectedCrownRadius',70E-03);
set(RT,'SpinInertia',0.9);
set(RT,'CorneringStiffness',2.4689E04);
set(RT,'CamberStiffness',1.1313E03);
set(RT,'RelaxationLength',0.1949);

params = BikeSimMotorcycleParameters(RU,RL,SM,SA,SH,F,FT,RT);