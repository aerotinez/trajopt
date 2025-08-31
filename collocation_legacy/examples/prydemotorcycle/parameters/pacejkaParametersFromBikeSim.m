function T = pacejkaParametersFromBikeSim(str)
    arguments
        str (1,1) string;
    end
    name = "C:\Users\marti\PhD\Code\Models\BikeSim2017.1_Data\Generic\" + str;
    S = readlines(name);
    p = S(3:end - 3);
    fs = @(s)s(22:end);
    vals = strrep(arrayfun(@(s)string(fs(char(s))),p)," ","");
    keys = strrep(arrayfun(@(s,v)strrep(s,v,""),p,vals)," ","");
    keys = lower(strrep(keys,"P_BIKE_",""));
    types = repmat("double",[1,57]);
    T = table('Size',[1,57],'VariableTypes',types,'VariableNames',keys);
    T(1,:) = num2cell(double(vals)).';
end