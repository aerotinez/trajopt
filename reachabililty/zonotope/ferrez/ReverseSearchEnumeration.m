classdef ReverseSearchEnumeration < handle
    properties (GetAccess = public, SetAccess = private)
        G;
        X;
        W;
    end
    properties (Access = private)
        n;
        m;
    end
    methods (Access = public)
        function obj = ReverseSearchEnumeration(G)
            arguments
                G double;
            end
            obj.G = G;
            [obj.n,obj.m] = size(G);
            obj.X = double.empty(0,obj.m);
            obj.W = double.empty(obj.n,0);
            obj.reverseSearch(ones(1,obj.m));
            obj.X = unique([obj.X;-obj.X],'rows','stable');
        end
    end
    methods (Access = private)
        function S = pmFlips(obj,s)
            ind = s ~= -1;
            idx = 1:obj.m;
            idx = idx(ind);
            N = sum(ind);
            S = repmat(s,[N,1]);
            for k = 1:N
                S(k,idx(k)) = -1;
            end
        end
        function w = witness(obj,s)
            f = [
                -1;
                zeros(obj.n,1);
                ];
            
            A = [
                ones(obj.m,1),-diag(s)*obj.G.';
                1,zeros(1,obj.n);
                ];

            b = [
                -diag(s)*ones(obj.m,1);
                1;
                ];
            
            opts = optimoptions('linprog','Display','none');
            [x,~,flag,~] = linprog(f,A,b,[],[],[],[],opts);

            if flag ~= 1 || x(1) < 0
                w = nan(obj.n,1);
                return
            end 
            w = x(2:end);
        end
        function [S,w] = adjacencyOracle(obj,s0)
            S = obj.pmFlips(s0);
            w = nan(obj.n,size(S,1));
            idx = true(1,size(S,1));
            for k = 1:size(S,1)
                w(:,k) = obj.witness(S(k,:));
                if isnan(w(:,k))
                    idx(k) = false;
                end
            end
            S = S(idx,:);
            w = w(:,idx);
        end 
        function P = intersections(obj,p0,pf)
            P = nan(size(obj.G));
            d = pf - p0;
            for k = 1:obj.m
                g = obj.G(:,k);
                P(:,k) =  p0 + d.*((-p0.'*g)./(d.'*g)); 
            end
        end
        function s = parentSearch(obj,p0,pf,s)
            P = obj.intersections(p0,pf);
            [~,k] = min(vecnorm(pf - P,2,1));
            s(k) = 1; 
        end
        function reverseSearch(obj,s0)
            if ismember(s0,obj.X,'rows')
                return
            end
            if all(s0 == -1)
                return
            end 
            obj.X = [obj.X;s0];
            wr = obj.witness(s0);
            obj.W = [obj.W,wr];
            [S,w] = obj.adjacencyOracle(s0);
            for k = 1:size(S,1) 
                if isequal(obj.parentSearch(wr,w(:,k),S(k,:)),s0)
                    obj.reverseSearch(S(k,:));
                    continue
                end
            end
        end
    end
end