function hex = mcolor(c)
    arguments
        c (1,1) char {mustBeMember(c,'boypgcr')}
    end
    keys = 'boypgcr'.';
    vals = [
        "#0072BD";
        "#D95319";
        "#EDB120";
        "#7E2F8E";
        "#77AC30";
        "#4DBEEE";
        "#A2142F"
        ];
    d = dictionary(keys,vals);
    hex = d(c);
end