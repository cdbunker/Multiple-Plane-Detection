im1 = rgb2gray(imread('im1.jpeg'));
im2 = rgb2gray(imread('im2.jpeg'));
im2Color = imread('im2.jpeg');

im1=imresize(im1,0.5)';
im2=imresize(im2,0.5)';
im2Color=fliplr(imrotate(imresize(im2Color,0.5),-90));

points1 = detectSURFFeatures(im1,'MetricThreshold', 50);
[features1,vpts1] = extractFeatures(im1, points1);

points2 = detectSURFFeatures(im2,'MetricThreshold', 50);
[features2,vpts2] = extractFeatures(im2,points2);

indexPairs = matchFeatures(features1,features2, 'MatchThreshold', 100);
matchedPoints1 = vpts1(indexPairs(1:end, 1));
matchedPoints2 = vpts2(indexPairs(1:end, 2));
showMatchedFeatures(im1,im2,matchedPoints1,matchedPoints2,'montage');


pts1 = matchedPoints1.Location;
pts2 = matchedPoints2.Location;

figure
[H, inliers] = ransac(pts2,pts1);
showMatchedFeatures(im1,im2,matchedPoints1(inliers),matchedPoints2(inliers),'montage');

mP2i = matchedPoints2(inliers).Location;

plane1=uint8(zeros(size(im2Color)));
colorFeatures1 = uint8(zeros(length(inliers), 21*21*3));
for i=1:length(mP2i)
    loc = mP2i(i,:);
    locX = round(loc(2));
    locY = round(loc(1));
    color = im2Color(locX-10:locX+10, locY-10:locY+10, :);
    plane1(locX-10:locX+10, locY-10:locY+10, :) = color;
    colorFeatures1(i,:) = color(:);
end
imshow(plane1)

pts1New = pts1;
pts1New(inliers,:)=[];
pts2New = pts2;
pts2New(inliers,:)=[];

matchedPoints1New = matchedPoints1;
matchedPoints1New(inliers,:)=[];
matchedPoints2New = matchedPoints2;
matchedPoints2New(inliers,:)=[];

figure
[H2, inliers2] = ransac(pts2New,pts1New);
showMatchedFeatures(im1,im2,matchedPoints1New(inliers2),matchedPoints2New(inliers2),'montage');

mP2iNew = matchedPoints2New(inliers2).Location;
plane2=uint8(zeros(size(im2Color)));
colorFeatures2 = zeros(length(inliers2), 21*21*3);
for i=1:length(mP2iNew)
    loc = mP2iNew(i,:);
    locX = round(loc(2));
    locY = round(loc(1));
    color = im2Color(locX-10:locX+10, locY-10:locY+10, :);
    plane2(locX-10:locX+10, locY-10:locY+10, :) = color;
    colorFeatures2(i,:) = color(:);
end
imshow(plane2)

BWplane1=(plane1(:,:,1)+plane1(:,:,2)+plane1(:,:,3))>0;
BWplane2=(plane2(:,:,1)+plane2(:,:,2)+plane2(:,:,3))>0;

%se = strel('disk',9);
BWplane2=bwmorph(BWplane2,'close',Inf);
imshow(BWplane2);
stats = regionprops(BWplane2,'BoundingBox');

for i=1:length(stats)
    xStart=stats(i).BoundingBox(1);
    xStop=xStart+stats(i).BoundingBox(3);
    
    yStart=stats(i).BoundingBox(2);
    yStop=yStart+stats(i).BoundingBox(4);
    
    bb(i,:)=[xStart,yStart,xStop,yStop];
end

maxX=max(bb(:,3));
maxY=max(bb(:,4));
minX=min(bb(:,1));
minY=min(bb(:,2));

finalBB=[minX,minY,maxX-minX,maxY-minY];

finalBook=uint8(zeros(size(im2Color)));
finalWall=im2Color;
finalBook(minY:maxY, minX:maxX,:) = imcrop(im2Color,finalBB);
figure;
imshow(finalBook)

figure;
finalWall(minY:maxY, minX:maxX,:)=0;
imshow(finalWall)