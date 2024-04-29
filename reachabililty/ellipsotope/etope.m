classdef etope
    properties (GetAccess = public, SetAccess = private)
        p; % norm number
        c; % center
        G; % generators
        A; % constraint matrix
        b; % constraint vector
        J; % index set
        n; % dimension
        m; % number of generators
        k; % number of constraints
    end
    methods (Access = public)
        function obj = etope(p,c,G,A,b,J)
            arguments
                p (1,1) double {mustBePositive};
                c (:,1) double;
                G (:,:) double;
                A (:,:) double = [];
                b (:,1) double = double.empty(0,1);
                J (1,:) indset = indset.empty(1,0);
            end
            obj.p = p;
            obj.c = c;
            obj.G = G;
            obj.A = A;
            obj.b = b;
            obj.J = J;
            obj.n = size(c,1);
            obj.m = size(G,2);
            obj.k = size(A,1);
        end
        function En = mtimes(M,E)
            arguments
                M double;
                E etope;
            end
            En = etope(E.p,M*E.c,M*E.G,E.A,E.b,E.J);
        end
        function En = plus(Ea,Eb)
            arguments
                Ea etope;
                Eb etope;
            end
            pn = Ea.p;
            cn = Ea.c + Eb.c;
            Gn = [Ea.G,Eb.G];
            An = blkdiag(Ea.A,Eb.A);
            bn = [Ea.b;Eb.b];
            Jn = Ea.J | (Eb.J + Ea.m);
            En = etope(pn,cn,Gn,An,bn,Jn);
        end
        function En = cartProd(Ea,Eb)
            arguments
                Ea etope;
                Eb etope;
            end
            pn = Ea.p;
            cn = [Ea.c;Eb.c];
            Gn = blkdiag(Ea.G,Eb.G);
            An = blkdiag(Ea.A,Eb.A);
            bn = [Ea.b;Eb.b];
            Jn = Ea.J | (Eb.J + Ea.m);
            En = etope(pn,cn,Gn,An,bn,Jn);
        end
        function En = and(Ea,Eb)
            arguments
                Ea etope;
                Eb etope;
            end
            pn = Ea.p;
            cn = Ea.c;
            Gn = [Ea.G,zeros(size(Eb.G))];
            An = [blkdiag(Ea.A,Eb.A);Ea.G,-Eb.G];
            bn = [Ea.b;Eb.b;Eb.c - Ea.c];
            Jn = Ea.J | (Eb.J + Ea.m);
            En = etope(pn,cn,Gn,An,bn,Jn); 
        end
        function En = convHull(Ea,Eb)
            arguments
                Ea etope;
                Eb etope;
            end
            mn = Ea.m + Eb.m;
            pn = Ea.p;
            cn = (1/2).*(Ea.c + Eb.c);
            Gn = [Ea.G,Eb.G,(1/2).*(Ea.c - Eb.c),zeros(Ea.n,mn)];
            A11 = blkdiag(Ea.A,Eb.A);
            A12 = [-(1/2).*[Ea.b;Eb.b],zeros(Ea.k + Eb.k,2*mn)];
            A21 = blkdiag([eye(Ea.m);-eye(Ea.m)],[eye(Eb.m);-eye(Eb.m)]);
            A22 = [(1/2).*[-ones(mn,1);ones(mn,1)],eye(2*mn)];
            An = [A11,A12;A21,A22];
            bn = (1/2).*[Ea.b;Eb.b;-ones(2*mn,1)];
            Jn = [Ea.J,Eb.J + Ea.m];
            En = etope(pn,cn,Gn,An,bn,Jn);
        end
    end
end