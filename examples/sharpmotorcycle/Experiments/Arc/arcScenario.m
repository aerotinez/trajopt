function road = arcScenario()
road = Road();
road.AddStraightSegment(50);
radius = 50;
road.AddArcSegment(deg2rad(90)*radius,radius,"Left");
road.AddStraightSegment(50);
end
