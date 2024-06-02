model WhippleBicycle
Real px;
Real py;
Real pz;
Real yaw;
Real lean;
Real pitch;
Real steer;
Real pitch_r;
Real pitch_f;
Real lean_rate;
Real steer_rate;
Real pitch_r_rate;
  inner Modelica.Mechanics.MultiBody.World world annotation(
    Placement(transformation(origin = {-90, 10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Mechanics.MultiBody.Parts.FixedRotation fixedRotation(each final r)  annotation(
    Placement(transformation(origin = {-50, 10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Mechanics.MultiBody.Joints.Prismatic prismatic annotation(
    Placement(transformation(origin = {-10, 10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Mechanics.MultiBody.Joints.Prismatic prismatic1(n = {0, 1, 0})  annotation(
    Placement(transformation(origin = {30, 10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Mechanics.MultiBody.Joints.Prismatic prismatic2(n = {0, 0, 1})  annotation(
    Placement(transformation(origin = {70, 10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Mechanics.MultiBody.Joints.Revolute revolute annotation(
    Placement(transformation(origin = {110, 10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Mechanics.MultiBody.Joints.Revolute revolute1(n = {1, 0, 0})  annotation(
    Placement(transformation(origin = {150, 10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Mechanics.MultiBody.Joints.Revolute revolute2(n = {0, 1, 0})  annotation(
    Placement(transformation(origin = {190, 10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Mechanics.MultiBody.Parts.Body body annotation(
    Placement(transformation(origin = {230, 10}, extent = {{-10, -10}, {10, 10}})));
equation
  connect(world.frame_b, fixedRotation.frame_a) annotation(
    Line(points = {{-80, 10}, {-60, 10}}, color = {95, 95, 95}));
  connect(fixedRotation.frame_b, prismatic.frame_a) annotation(
    Line(points = {{-40, 10}, {-20, 10}}, color = {95, 95, 95}));
  connect(prismatic.frame_b, prismatic1.frame_a) annotation(
    Line(points = {{0, 10}, {20, 10}}, color = {95, 95, 95}));
  connect(prismatic1.frame_b, prismatic2.frame_a) annotation(
    Line(points = {{40, 10}, {60, 10}}, color = {95, 95, 95}));
  connect(revolute.frame_a, prismatic2.frame_b) annotation(
    Line(points = {{100, 10}, {80, 10}}, color = {95, 95, 95}));
  connect(revolute1.frame_a, revolute.frame_b) annotation(
    Line(points = {{140, 10}, {120, 10}}, color = {95, 95, 95}));
  connect(revolute2.frame_a, revolute1.frame_b) annotation(
    Line(points = {{180, 10}, {160, 10}}, color = {95, 95, 95}));
  connect(body.frame_a, revolute2.frame_b) annotation(
    Line(points = {{220, 10}, {200, 10}}, color = {95, 95, 95}));
  annotation(
    uses(Modelica(version = "4.0.0")));
end WhippleBicycle;
