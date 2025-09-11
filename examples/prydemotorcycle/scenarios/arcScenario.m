function road = arcScenario()
    road = Road();
    straight_length = 200;
    road.addStraight(straight_length);
    radius = 200;
    road.addArc(deg2rad(90)*radius,radius,"left");
    road.addStraight(straight_length);
end
