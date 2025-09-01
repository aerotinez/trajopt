function setMesh(obj)
    arguments
        obj (1,1) directcollocation.LegendreGauss
    end

    tau = obj.Nodes(:).';  % ensure row
    assert(numel(tau) == obj.NumNodes, ...
        'LegendreGauss:setMesh:NumNodesMismatch', ...
        'numel(Nodes) must equal NumNodes.');

    % For LG we use the augmented set [-1, tau_G, +1]
    % Map tau ∈ [-1,1] → mesh ∈ [0,1]
    mesh = (tau + 1)/2;

    % Basic sanity: endpoints present and sorted
    assert(abs(mesh(1) - 0) < 1e-12 && abs(mesh(end) - 1) < 1e-12, ...
        'LegendreGauss:setMesh:Endpoints', ...
        'Augmented LG nodes must include -1 and +1.');
    assert(all(diff(mesh) > 0), ...
        'LegendreGauss:setMesh:Monotone', ...
        'Nodes must be strictly increasing.');

    obj.Mesh = mesh;  % 1 × NumNodes
end
