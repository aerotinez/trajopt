function M = minkowskiSum(varargin) 
    if size(varargin{1},1) ~= size(varargin{2},1)
        error('A and B must have the same number of rows');
    end
    A = varargin{1};
    B = varargin{2};
    M = repelem(A,1,size(B,2)) + repmat(B,1,size(A,2));
    if nargin < 3
        return;
    end
    M = minkowskiSum(M,varargin{3:end});
end 