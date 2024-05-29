classdef IncrementalEnumeration < handle
    properties (GetAccess = public, SetAccess = private)
        G;
        X;
    end
    properties (Access = private)
        n;
        m;
    end
    methods (Access = public)
        function obj = IncrementalEnumeration(G)
            arguments
                G double;
            end
            obj.G = G;
            [obj.n,obj.m] = size(G);
            obj.X = double.empty(0,obj.m);
            obj.incrementalSearch([],witness(obj.G,ones(1,obj.m)));
            obj.X = unique([obj.X;-obj.X],'rows','stable');
        end
    end
    methods (Access = private)
        function incrementalSearch(obj,s,w)
            sm = fullSized(obj.G,w);
            if ismember(sm,obj.X,'rows')
                return
            end 
            obj.X = [obj.X;sm];
            i = numel(s);
            for j = obj.m:-1:i + 1
                sj = shorten(sm,j);
                sj(j) = -sj(j);
                w = witness(obj.G(:,1:j),sj);
                if ~all(isnan(w))
                    obj.incrementalSearch(sj,w);
                end
            end
        end
    end
end