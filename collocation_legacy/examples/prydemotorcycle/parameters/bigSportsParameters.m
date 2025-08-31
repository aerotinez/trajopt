function params = bigSportsParameters()
SM = SprungMass;
set(SM,'Mass',165);
set(SM,'Ixx',11.0);
set(SM,'Iyy',22.0);
set(SM,'Izz',14.0);
set(SM,'Ixz',-3);
set(SM,'Rx',258E-03);
set(SM,'Ry',365E-03);
set(SM,'Rz',291E-03);
set(SM,'CoMOffset',560E-03);
set(SM,'CoMHeight',532E-03);
set(SM,'Wheelbase',1370E-03);
set(SM,'LiftCoefficient',0.085);
set(SM,'DragCoefficient',0.52);
set(SM,'PitchCoefficient',0.205);
set(SM,'FrontalArea',0.6);

RU = RiderUpperBody;
set(RU,'Mass',43.52);
set(RU,'Ixx',1.428);
set(RU,'Iyy',1.347);
set(RU,'Izz',0.916);
set(RU,'Ixz',0.433);
set(RU,'Rx',181E-03);
set(RU,'Ry',176E-03);
set(RU,'Rz',145E-03);
set(RU,'ForwardLean',45);
set(RU,'LeanAxisHeight',830E-03);
set(RU,'CoMOffset',1049E-3);
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
set(RL,'CoMOffset',859E-03);
set(RL,'CoMHeight',532E-03);

SH = SteeringHead;
set(SH,'Mass',9.99);
set(SH,'Ixx',1.341);
set(SH,'Iyy',1.584);
set(SH,'Izz',0.4125);
set(SH,'Ixz',0.0);
set(SH,'Rx',366E-03);
set(SH,'Ry',398E-03);
set(SH,'Rz',203E-03);
set(SH,'CoMOffset',45E-03);
set(SH,'CoMHeight',-200E-03);
set(SH,'ForkLength',610E-03);
set(SH,'Rake',26.5E-03);
set(SH,'Caster',24);
set(SH,'Damping',0.2212);

F = Fork;
set(F,'Mass',7.25);
set(F,'CoMOffset',-3.08273E-03);
set(F,'CoMHeight',263.848E-03);

FT = Tire;
set(FT,'EffectiveRollingRadius',282E-03);
set(FT,'SpringRate',130E03);
set(FT,'Mass',7);
set(FT,'UndeflectedCrownRadius',50E-03);
set(FT,'SpinInertia',0.484);
set(FT,'LateralTireLag',200E-03);
set(FT,'RollingResistanceCoefficient',0.002);
set(FT,'RollingResistanceTimeConstant',0.000015);
set(FT,'Pacejka',pacejkaParametersFromBikeSim("Example_Front_v102.par"));

SA = SwingArm;
set(SA,'Mass',8);
set(SA,'Length',426.64E-03);
set(SA,'CoMOffset',176E-03);
set(SA,'CoMHeight',19.3374E-03);
set(SA,'PivotHeight',365E-03);
set(SA,'AxelHeight',290E-03);

RT = Tire;
set(RT,'EffectiveRollingRadius',297E-03);
set(RT,'SpringRate',141E03);
set(RT,'Mass',14.7);
set(RT,'UndeflectedCrownRadius',70E-03);
set(RT,'SpinInertia',0.638);
set(RT,'LateralTireLag',200E-03);
set(RT,'RollingResistanceCoefficient',0.004);
set(RT,'RollingResistanceTimeConstant',0.000025);
set(RT,'Pacejka',pacejkaParametersFromBikeSim("Example_Rear_v102.par"));

params = BikeSimMotorcycleParameters(RU,RL,SM,SA,SH,F,FT,RT);