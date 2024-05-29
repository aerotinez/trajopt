function s = fullSized(G,w)
    arguments
        G double;
        w (:,1) double;
    end
    if size(G,1) ~= numel(w)
        error("The size of g must be equal to the size of w.")
    end
    s = double(G.'*w >= 1).';
    s(s == 0) = -1;
end