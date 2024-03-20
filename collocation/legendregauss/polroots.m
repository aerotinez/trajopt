function r = polroots(a)
    arguments
        a (1,:) double;
    end
    a = a./a(1);
    F = fiedler(a(2:end));
    B = balance(F);
    r = eig(B);
end

function F = fiedler(a)
    n = length(a);
    b = ones(n - 2,1); 
    b(1:2:n - 2) = 0;
    c = -a(2:n); 
    c(1:2:n - 1) = 0; 
    c(1) = 1;
    d = -a(2:n); 
    d(2:2:n - 1) = 0;
    e = ones(n - 2,1); 
    e(2:2:n - 2) = 0;
    F = diag(b,-2) + diag(c,-1) + diag(d,1) + diag(e,2); 
    F(1,1) = -a(1);
end