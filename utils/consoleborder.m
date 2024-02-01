function consoleborder(delimiter)
    arguments
        delimiter (1,1) char = '=';
    end
    disp(repmat(delimiter,[1,80]));
end