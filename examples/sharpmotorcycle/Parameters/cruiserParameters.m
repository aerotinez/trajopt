function params = cruiserParameters()
SM = SprungMass;
set(SM,'Mass',165.13);
set(SM,'Ixx',11.0);
set(SM,'Iyy',22.0);
set(SM,'Izz',14.0);
set(SM,'Ixz',-3.692);
set(SM,'Rx',258E-03);
set(SM,'Ry',365E-03);
set(SM,'Rz',291E-03);
set(SM,'CoMOffset',859E-03);
set(SM,'CoMHeight',532E-03);
set(SM,'Wheelbase',1539E-03);

RU = RiderUpperBody;
set(RU,'Mass',43.52);
set(RU,'Ixx',1.4);
set(RU,'Iyy',1.3);
set(RU,'Izz',0.9);
set(RU,'Ixz',0.433);
set(RU,'Rx',179E-03);
set(RU,'Ry',173E-03);
set(RU,'Rz',144E-03);
set(RU,'ForwardLean',11.3);
set(RU,'LeanAxisHeight',720E-03);
set(RU,'CoMOffset',1200E-3);
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
set(RL,'CoMOffset',816E-03);
set(RL,'CoMHeight',504E-03);

SH = SteeringHead;
set(SH,'Mass',9.99);
set(SH,'Ixx',1.341);
set(SH,'Iyy',1.584);
set(SH,'Izz',0.4125);
set(SH,'Ixz',0.0);
set(SH,'Rx',366E-03);
set(SH,'Ry',398E-03);
set(SH,'Rz',203E-03);
set(SH,'CoMOffset',49.944E-03);
set(SH,'CoMHeight',-60.3452E-03);
set(SH,'ForkLength',722.556E-03);
set(SH,'Rake',49.9397E-03);
set(SH,'Caster',34);
set(SH,'Damping',0.2122);

F = Fork;
set(F,'Mass',7.25);
set(F,'CoMOffset',49.9397E-03);
set(F,'CoMHeight',0.*722.556E-03);

FT = Tire;
set(FT,'EffectiveRollingRadius',318E-03);
set(FT,'Mass',7);
set(FT,'UndeflectedCrownRadius',50E-03);
set(FT,'SpinInertia',0.484);
set(FT,'CorneringStiffness',1.8022E04);
set(FT,'CamberStiffness',745.0421);
set(FT,'RelaxationLength',0.098);

SA = SwingArm;
set(SA,'Mass',8);
set(SA,'Length',400E-03);
set(SA,'CoMOffset',100E-03);
set(SA,'CoMHeight',9E-03);
set(SA,'PivotHeight',321E-03);
set(SA,'AxelHeight',321E-03);

RT = Tire;
set(RT,'EffectiveRollingRadius',321E-03);
set(RT,'Mass',14.7);
set(RT,'UndeflectedCrownRadius',70E-03);
set(RT,'SpinInertia',0.638);
set(RT,'CorneringStiffness',2.1959E04);
set(RT,'CamberStiffness',762.6843);
set(RT,'RelaxationLength',0.098);

params = BikeSimMotorcycleParameters(RU,RL,SM,SA,SH,F,FT,RT);