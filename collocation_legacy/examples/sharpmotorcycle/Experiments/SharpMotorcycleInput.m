classdef SharpMotorcycleInput < handle
    properties (GetAccess = ?SharpMotorcycleExperiment, SetAccess = private)
        Table;
    end
    methods (Access = public)
        function obj = SharpMotorcycleInput()
            StateName = "Steering torque rate";
            Name = "torque rate";
            Units = "Nm/s";
            Initial = nan;
            Final = nan;
            Min = -inf;
            Max = inf;
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