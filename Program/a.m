I = imread('indir.jpg');
bw = im2bw(I, graythresh(I));
bw = imfill(bw, 'holes');


se = strel('disk',2);
bw = imclose(bw,se);

bw = imfill(bw,'holes');
[A,B,N] = bwboundaries(bw);
subplot(2,N,N/2),subimage(I);
for k=1:length(A),
 boundary = A{k};
 minx=min(boundary(:,1));
 maxx=max(boundary(:,1));
 miny=min(boundary(:,2));
 maxy=max(boundary(:,2));
 tx=maxx-minx;
 ty=maxy-miny;
 I2 = imcrop(I,[miny minx ty tx]);
 subplot(2,N,k+N),subimage(I2);
end