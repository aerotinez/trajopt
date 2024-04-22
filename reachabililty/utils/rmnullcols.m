function vout = rmnullcols(v)
    arguments
        v double;
    end
    vout = v(:,any(v,1));
end