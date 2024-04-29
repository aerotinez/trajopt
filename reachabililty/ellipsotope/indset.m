classdef indset
    properties (Access = private)
        A;
    end
    methods (Access = public)
        function obj = indset(A)
            arguments
                A (1,:) double {mustBeInteger};
            end
            obj.A = sort(unique(A));
        end
        function disp(obj)
            disp(obj.A);
        end
        function C = plus(A,B)
            arguments
                A (1,1) indset;
                B (1,:) double;
            end
            C = indset(A.A + B);
        end
        function C = minus(A,B)
            arguments
                A (1,1) indset;
                B (1,:) double;
            end
            C = indset(A.A - B);
        end
        function C = and(A,B)
            arguments
                A indset;
                B indset;
            end
            D = [A.A,B.A];
            [~,j] = unique(D,"stable");
            k = setdiff(1:numel(D),j);
            C = indset(D(k));
        end
        function C = or(A,B)
            arguments
                A indset;
                B indset;
            end
            C = indset([A.A,B.A]);
        end
        function C = mldivide(A,B)
            arguments
                A indset;
                B indset;
            end
            C = indset(setdiff(A.A,B.A));
        end
        function C = cartProd(A,B)
            arguments
                A indset;
                B indset;
            end
            i = repelem(1:numel(A.A),numel(B.A));
            j = repmat(1:numel(B.A),1,numel(A.A));
            C = [A.A(i);B.A(j)].'; 
        end 
    end
end