function set_k = reachableSet(obj,k)
    arguments
        obj (1,1) Kafash2022;
        k (1,1) double {mustBeInteger,mustBePositive};
    end
    A = obj.Sys.A;
    B = obj.Sys.B;
    n = size(A,1);
    a = obj.Epsilon/obj.NumSteps;
    if rank(A) == n && rank(B) == n
        a = 0;
    end
    F = (A^k)*B;
    set_k = obj.alphaApproximate(obj.Input,F,a);
end