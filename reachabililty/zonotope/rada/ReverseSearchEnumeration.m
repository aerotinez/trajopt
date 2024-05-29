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
        function [S,w] = adjacencyOracle(obj,s0)
            S = obj.pmFlips(s0);
            w = nan(obj.n,size(S,1));
            idx = true(1,size(S,1));
            for k = 1:size(S,1)
                w(:,k) = witness(obj.G,S(k,:));
                if isnan(w(:,k))
                    idx(k) = false;
                end
            end
            S = S(idx,:);
            w = w(:,idx);
        end 
        function s = parentSearch(obj,p0,pf,s)
            d = pf - p0;
            t = (-p0.'*obj.G)./(d.'*obj.G); 
            P = p0 + t.*d;
            [~,k] = min(vecnorm(P - pf,2,1));
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
            wr = witness(obj.G,s0);
            obj.W = [obj.W,wr];
            [S,w] = obj.adjacencyOracle(s0);
            for k = 1:size(S,1) 
                if isequal(obj.parentSearch(wr,w(:,k),S(k,:)),s0)
                    obj.reverseSearch(S(k,:));
                end
            end
        end
    end
end