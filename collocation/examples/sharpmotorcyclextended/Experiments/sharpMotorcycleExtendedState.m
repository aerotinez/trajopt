function T = sharpMotorcycleExtendedState()
    StateName = [
        "Offset";
        "Relative heading";
        "Lean";
        "Steer";
        "Yaw rate";
        "Longitudinal speed";
        "Lateral speed";
        "Lean rate";
        "Steer rate";
        "Rear lateral tire force";
        "Front lateral tire force";
        "Throttle torque";
        "Steering torque"
    ];

    Name = [
        "distance";
        "angle";
        "angle";
        "angle";
        "speed";
        "speed";
        "speed";
        "speed";
        "speed";
        "force";
        "force";
        "torque";
        "torque"
    ];

    Units = [
        "m";
        "rad";
        "rad";
        "rad";
        "rad/s";
        "m/s";
        "m/s";
        "rad/s";
        "rad/s";
        "N";
        "N";
        "Nm";
        "Nm"
    ];

    n = numel(Name);
    Initial = zeros(n, 1);
    Final = zeros(n, 1);
    Min = -inf(n, 1);
    Max = inf(n, 1);

    varnames = {'Name','Units','Initial','Final','Min','Max'};

    T = table(Name,Units,Initial,Final,Min,Max, ...
                'VariableNames',varnames, ...
                'RowNames',cellstr(StateName) ...
                );
end