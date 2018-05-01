function [newPts, T] = normalizePts(points)
    avg = mean(points, 1);

    meanCentered = points - avg;
    
    sqrDist = sum(hypot(meanCentered(:,1),meanCentered(:,2)).^2);
    s = sqrt(2*size(points,1)) / sqrt(sqrDist);
    
    newPts = meanCentered .* s;
    
    T = [1/s, 0, 0; ...
        0, 1/s, 0; ...
        avg(1), avg(2), 1];
end
