classdef SharpMotorcycleState < handle
    properties (GetAccess = ?SharpMotorcycleExperiment, SetAccess = private)
        Table;
    end
    methods (Access = public)
        function obj = SharpMotorcycleState()
            StateName = [
                "Offset";
                "Relative heading";
                "Lean";
                "Steer";
                "Lateral velocity";
                "Yaw rate";
                "Lean rate";
                "Steer rate";
                "Rear tire lateral force";
                "Front tire lateral force";
                "Steering torque";
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
                "force";
                "force";
                "torque";
                ];

            Units = [
                "m";
                "rad";
                "rad";
                "rad";
                "m/s";
                "rad/s";
                "rad/s";
                "rad/s";
                "N";
                "N";
                "Nm";
                ];

            n = numel(Name);
            Initial = zeros(n,1);
            Final = zeros(n,1);
            Min = -inf(n,1);
            Max = inf(n,1);

            varnames = {'Name','Units','Initial','Final','Min','Max'};

            obj.Table = table(Name,Units,Initial,Final,Min,Max, ...
                'VariableNames',varnames, ...
                'RowNames',cellstr(StateName) ...
                );
        end
        function disp(obj)
            disp(obj.Table);
        end
        function setInitial(obj,name,value)
            obj.set(name,'Initial',value);
        end
        function setFinal(obj,name,value)
            obj.set(name,'Final',value);
        end
        function setMin(obj,name,value)
            obj.set(name,'Min',value);
        end
        function setMax(obj,name,value)
            obj.set(name,'Max',value);
        end 
    end
    methods (Access = private)
        function set(obj,row,col,value)
            obj.Table{row,col} = value;
        end
    end
end