function consoletitle(msg,delimiter)
    arguments
        msg (1,:) char = '';
        delimiter (1,1) char = ' ';
    end
    n = numel(msg) + 2;
    strl = repmat(delimiter,[1,ceil((80 - n)/2)]);
    strr = repmat(delimiter,[1,floor((80 - n)/2)]);
    str = [strl,' ',msg,' ',strr,'\n'];
    fprintf(str);
end