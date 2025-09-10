function plot(obj)
    arguments
        obj (1,1) Road;
    end
    scen = drivingScenario;
    lm = [laneMarking('Solid')
        laneMarking('Dashed','Length',2,'Space',4)
        laneMarking('Solid')];
    l = lanespec(2,'Marking',lm,"width",3.5);
    road(scen,obj.Data.',0.*obj.Data(1,:).',"Lanes",l);
    plot(scen);
    axe = gca;
    axe.SortMethod = 'childorder';
    title(axe,'Road network');
end