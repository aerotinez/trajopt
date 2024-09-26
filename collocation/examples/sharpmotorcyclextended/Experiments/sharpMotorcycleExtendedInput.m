function T = sharpMotorcycleExtendedInput()
    StateName = [
        "Throttle torque rate";
        "Steering torque rate"
    ];

    Name = [
        "torque rate";
        "torque rate"
    ];

    Units = [
        "Nm/s";
        "Nm/s"
    ];

    n = numel(Name);
    Initial = nan(n,1);
    Final = nan(n,1);
    Min = -inf(n,1);
    Max = inf(n,1);
    varnames = {'Name','Units','Initial','Final','Min','Max'};
    T = table(Name,Units,Initial,Final,Min,Max, ...
        'VariableNames',varnames, ...
        'RowNames',cellstr(StateName));
end
