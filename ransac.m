function [H, inliers] = ransac(pts1,pts2)

nums=1:length(pts1);
minErr = 999999;
bestH = eye(3);
bestInliers = [];

for it = 1:1000
    sample = datasample(nums,4,'Replace', false);
    H = findHomography(pts1(sample,:), pts2(sample,:));

    reproject = H*[pts2(sample,:), ones(4,1)]';
    reproject = bsxfun(@rdivide, reproject, reproject(3,:));
    diff = reproject - [pts1(sample,:), ones(4,1)]';
    ssd = sum(diff(:).^2);
    
    if (ssd < 0.001)
       currInliers = findInliers(H, pts1, pts2);
       if (length(currInliers) > length(bestInliers))
            bestInliers = currInliers;
       end
    end
end

H = findHomography(pts1(bestInliers,:), pts2(bestInliers,:));

inliers = bestInliers;
end

function inliers = findInliers(H, pts1,pts2)
inliers = [];
reproject = H*[pts2, ones(length(pts2),1)]';
reproject = bsxfun(@rdivide, reproject, reproject(3,:));
for i = 1:length(pts1)
    diff = reproject(:,i) - [pts1(i,:), 1]';
    srssd = sqrt(sum(diff(:).^2));
    if (srssd < 15)
       inliers = [inliers,i]; 
    end
end
end