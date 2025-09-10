function tab = vartable(name,options)
    arguments
        name (:,1) string;
        options.InitialValue (:,1) double {mustBeReal} = nan(size(name));
        options.FinalValue (:,1) double {mustBeReal} = nan(size(name));
        options.LowerBound (:,1) double {mustBeReal} = -inf(size(name));
        options.UpperBound (:,1) double {mustBeReal} = inf(size(name));
        options.Quantity (:,1) string = strings(size(name)); 
        options.Units (:,1) string = strings(size(name));
    end

    % validate size
    sz = size(name);
    nm = mfilename;
    f = @(x,s)validateattributes(x,{class(x)},{"size",sz},nm,s);
    cellfun(f,struct2cell(options),fieldnames(options));

    % validate bounds
    for k = 1:numel(name)
        lb = options.LowerBound(k);
        ub = options.UpperBound(k);
        validateattributes(lb,{'double'},{'<=',ub},nm,'LowerBound',k);
        validateattributes(ub,{'double'},{'>=',lb},nm,'UpperBound',k);
    end

    Name = name;
    InitialValue = options.InitialValue(:);
    FinalValue = options.FinalValue(:);
    LowerBound = options.LowerBound(:);
    UpperBound = options.UpperBound(:);
    Quantity = options.Quantity(:);
    Units = options.Units(:);

    tab = table(Name,Quantity,Units,InitialValue,FinalValue,LowerBound,UpperBound);
end