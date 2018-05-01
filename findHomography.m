function H = findHomography(imagePoints,worldPoints2D)
    [normImagePoints,T] = normalizePts(worldPoints2D);
    [normWorldPoints, Tp] = normalizePts(imagePoints);

    x = normImagePoints(:,1);
    y = normImagePoints(:,2);
    xp = normWorldPoints(:,1);
    yp = normWorldPoints(:,2);    
    
    b = [x;y];
    
    A = [xp, yp, ones(size(x,1),1), zeros(size(x,1),1), zeros(size(x,1),1), zeros(size(x,1),1), -x.*xp, -x.*yp; ...
        zeros(size(x,1),1), zeros(size(x,1),1), zeros(size(x,1),1), xp, yp, ones(size(x,1),1), -y.*xp, -y.*yp];
    
    H = A\b;
    
    H(9) = 1;
    H = reshape(H,3,3);
    
    H = inv(Tp)*H*T;
    H = inv(H);
    H = H./H(3,3);
    H = H';
end
