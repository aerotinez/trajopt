function Jsmooth = smoothCost(obj, rho1, rho2, rho3)
% Smoothness penalties on states using nonuniform Mesh spacings s∈[0,1].
% No dependence on InitialTime/FinalTime (so tf==t0 is harmless).
%
% Inputs (set to 0 or omit to disable):
%   rho1, rho2, rho3  ≥ 0  weights for 1st/2nd/3rd-order penalties.
%
% Returns:
%   Jsmooth  (casadi.MX scalar)

    if nargin < 2 || isempty(rho1), rho1 = 0; end
    if nargin < 3 || isempty(rho2), rho2 = 0; end
    if nargin < 4 || isempty(rho3), rho3 = 0; end

    X  = obj.States;               % nx × K (MX)
    nx = obj.NumStates;
    K  = obj.NumNodes;

    if (rho1==0 && rho2==0 && rho3==0) || K < 2
        Jsmooth = casadi.MX(0);
        return
    end

    % Mesh spacings (numeric)
    s  = obj.Mesh(:).';            % 1 × K in [0,1]
    ds = diff(s);                  % 1 × (K-1)
    ds = max(ds, 1e-12);           % guard tiny spacing (pure MATLAB max)

    Jsmooth = casadi.MX(0);

    % ---------- 1st order in s ----------
    if rho1 > 0 && K >= 2
        D1 = (X(:,2:end) - X(:,1:end-1)) ./ (ones(nx,1) * ds);   % nx × (K-1)
        w1 = (ones(nx,1) * ds);                                  % integrate ||x_s||^2 ds
        Jsmooth = Jsmooth + rho1 * sum(sum( (D1.^2) .* w1 ));
    end

    % ---------- 2nd order in s ----------
    if rho2 > 0 && K >= 3
        dsm    = ds(1:end-1);                                    % Δs_{i-1}
        dsp    = ds(2:end);                                      % Δs_i
        denom2 = max(dsm + dsp, 1e-12);                          % 1 × (K-2)

        D1m = (X(:,2:end-1) - X(:,1:end-2)) ./ (ones(nx,1) * dsm);
        D1p = (X(:,3:end)   - X(:,2:end-1)) ./ (ones(nx,1) * dsp);
        D2  = 2 * (D1p - D1m) ./ (ones(nx,1) * denom2);          % nx × (K-2)

        w2 = (ones(nx,1) * (0.5 * denom2));                      % integrate ||x_ss||^2 ds
        Jsmooth = Jsmooth + rho2 * sum(sum( (D2.^2) .* w2 ));
    end

    % ---------- 3rd order in s ----------
    % ---------- 3rd order in s (fixed) ----------
    if rho3 > 0 && K >= 4
        % Rebuild 2nd derivative on interior nodes (length K-2)
        dsm    = ds(1:end-1);                    % Δs_{i-1}, length K-2
        dsp    = ds(2:end);                      % Δs_i,   length K-2
        denom2 = max(dsm + dsp, 1e-12);          % 1 × (K-2)
    
        D1m = (X(:,2:end-1) - X(:,1:end-2)) ./ (ones(nx,1) * dsm);
        D1p = (X(:,3:end)   - X(:,2:end-1)) ./ (ones(nx,1) * dsp);
        D2  = 2 * (D1p - D1m) ./ (ones(nx,1) * denom2);   % nx × (K-2)
    
        % Center-to-center spacing between consecutive D2 positions:
        % 0.5 * (Δs_i + Δs_{i-1}) for i = 2..K-2  → length K-3
        denom3 = max(0.5 * (ds(2:end-1) + ds(1:end-2)), 1e-12);  % 1 × (K-3)
    
        % Third derivative as discrete derivative of D2 over these centers
        D3 = (D2(:,2:end) - D2(:,1:end-1)) ./ (ones(nx,1) * denom3);  % nx × (K-3)
        w3 = (ones(nx,1) * denom3);                                   % integrate ||x_sss||^2 ds
        Jsmooth = Jsmooth + rho3 * sum(sum( (D3.^2) .* w3 ));
    end

end
