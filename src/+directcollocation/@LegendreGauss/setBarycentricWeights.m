function setBarycentricWeights(obj)
    arguments
        obj (1,1) directcollocation.LegendreGauss
    end
    % Mesh must already be set by the subclass
    obj.BarycentricWeights = directcollocation.baryfit(obj.Mesh);
end