function road = arcScenario()
    road = Road();
    straight_length = 50;
    road.addStraight(straight_length);
    radius = 50;
    road.addArc(deg2rad(90)*radius,radius,"left");
    road.addStraight(straight_length);
end
