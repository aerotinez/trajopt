% function L = lagpol(p,t)
%     arguments
%         p (1,:);
%         t (1,:);
%     end
%     n = numel(p) - 1;
%     A = (p.').^(0:n);
%     L = ((A\eye(n + 1)).')*(t.^((0:n).'));
% end
% 
function L = lagpol(p,t)
% Numerically stable Lagrange basis evaluation (barycentric form)
% p : 1×(n+1) nodes
% t : 1×m    evaluation points
% L : (n+1)×m basis matrix (same size as your original)

    arguments
        p (1,:)
        t (1,:)
    end

    n = numel(p) - 1;

    % Barycentric weights: w_i = 1 / prod_{j≠i} (p_i - p_j)
    % Use a stable pairwise product via differences matrix.
    Pdiff = p - p.';                  % (n+1)×(n+1)
    Pdiff(1:n+2:end) = 1;             % avoid zeros on diagonal when taking prod
    w = 1 ./ prod(Pdiff,2);           % column (n+1)×1

    % Evaluate
    % v_ij = 1 / (t_j - p_i)
    v = 1 ./ (t - p.');               % (n+1)×m

    denom = w.' * v;                  % 1×m
    L = (w .* v) ./ denom;            % broadcasting -> (n+1)×m

    % Handle t exactly equal to a node (avoid NaNs/Inf): column becomes e_i
    [ii,jj] = find(abs(t - p.') < eps(max(abs(p))) ); % indices where t_j == p_i
    if ~isempty(jj)
        L(:,jj) = 0;
        L(sub2ind(size(L),ii,jj)) = 1;
    end
end
