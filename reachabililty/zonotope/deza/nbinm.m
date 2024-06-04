function x = nbinm(m,n,N)
    arguments
        m  (1,1) double {mustBeInteger, mustBePositive};
        n (1,1) double {mustBeInteger, mustBePositive};
        N (1,1) double {mustBeInteger, mustBePositive} = 100;
    end
    x = double.empty(0,n);
    k = 1;
    Nmax = binaryVectorToDecimal([ones(1,m),zeros(1,n-m)]);
    while size(x,1) < N + 1 && k < Nmax + 1
        if sum(dec2bin(k) - '0') == m
            x = [
                x;
                fliplr(dec2bin(k,n) - '0')
                ];
        end
        k = k + 1;
    end
end