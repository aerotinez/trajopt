function sj = shorten(si,j)
    arguments
        si (1,:) double {mustBeMember(si,[-1,1])};
        j (1,1) double;
    end
    i = numel(si);
    sj = si(1:end - (i - j));
end