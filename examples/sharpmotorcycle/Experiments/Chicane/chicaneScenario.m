function road = chicaneScenario()
ang = deg2rad(90);
straight_length = 25;
clothoid_length = 100;
arc_length = 150;
radius = arc_length/ang;
road = Road();
road.addStraight(straight_length);
road.addClothoid(clothoid_length,inf,radius,"left");
road.addClothoid(clothoid_length,radius,inf,"right");
road.addStraight(straight_length);
end