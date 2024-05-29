function y = nbinm(x)
    arguments
        x (1,:) logical;
    end
    n = numel(x);
    k = sum(x);
    c = nchoosek(1:n,k);
    m = size(c,1);
    y = false(m,n);
    y(sub2ind([m,n],(1:m).'*ones(1,k),c)) = true;
end