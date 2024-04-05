function M = minkowskiSum(varargin)
    A = varargin{1};
    B = varargin{2};
    if size(A,1) ~= size(B,1)
        error('A and B must have the same number of rows');
    end 
    Ma = repelem(A,1,size(B,2));
    Mb = repmat(B,1,size(A,2));
    M = Ma + Mb;
    if nargin < 3
        return;
    end
    M = minkowskiSum(M,varargin{3:end});
end 