function setMesh(obj)
    arguments
        obj (1,1) directcollocation.LegendreGaussRadau
    end

    tau = obj.Nodes(:).';  % ensure row
    assert(numel(tau) == obj.NumNodes, ...
        'LegendreGaussRadau:setMesh:NumNodesMismatch', ...
        'numel(Nodes) must equal NumNodes.');

    % Map τ ∈ [-1,1] → mesh ∈ [0,1]
    mesh = (tau + 1)/2;

    % Basic sanity checks
    assert(abs(mesh(1)) < 1e-12 && abs(mesh(end) - 1) < 1e-12, ...
        'LegendreGaussRadau:setMesh:Endpoints', ...
        'Augmented Radau nodes must include -1 and +1.');
    assert(all(diff(mesh) > 0), ...
        'LegendreGaussRadau:setMesh:Monotone', ...
        'Nodes must be strictly increasing.');

    obj.Mesh = mesh;  % 1 × NumNodes
end
