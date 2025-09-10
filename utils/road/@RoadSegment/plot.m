function plot(obj)
    arguments
        obj (1,1) RoadSegment;
    end
    plot(obj.Data(1,:),obj.Data(2,:));
    view([90,-90]);
    set(gca,'Ydir','reverse');
    title('Road segment');
    xlabel('x(m)');
    ylabel('y(m)');
    axis('equal'); 
end 