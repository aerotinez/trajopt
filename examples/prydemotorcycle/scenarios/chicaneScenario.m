function road = chicaneScenario()
ang = deg2rad(90);
straight_length = 200;
clothoid_length = 200;
arc_length = 200;
radius = arc_length/ang;
road = Road();
road.addStraight(straight_length);
road.addClothoid(clothoid_length,inf,radius,"left");
road.addClothoid(clothoid_length,radius,inf,"right");
road.addStraight(straight_length);
end