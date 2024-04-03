function M = minkowskiSum(A,B)
    arguments
        A double;
        B double;
    end
    if ~isequal(size(A,2),size(B,2))
        error("A and B must have same number of columns");
    end
    C = permute(A,[1 3 2]) + permute(B,[3 1 2]);
    M = reshape(C,[],size(A,2));
end