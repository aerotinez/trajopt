function road = chicaneScenario()
ang = deg2rad(90);
straight_length = 25;
clothoid_length = 100;
arc_length = 150;
radius = arc_length/ang;
road = Road();
road.AddStraightSegment(straight_length);
road.AddClothoidSegment(clothoid_length,inf,radius,"Left");
road.AddClothoidSegment(clothoid_length,radius,inf,"Right");
road.AddStraightSegment(straight_length);
end