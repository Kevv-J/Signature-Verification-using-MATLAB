function [Feat_Val,im_processed] = featureExtraction(I)
%FEATUREEXTRACTION Summary of this function goes here
%   Detailed explanation goes here
%I=imread('image71.jpeg '); % Load the image file and store it as the variable I. 
% figure(1),imshow(I);
% pause
I2=imresize(I,[512 ,512]);
% figure(2),imshow(I2);
% pause

I3=rgb2gray(I2);
%I3=medfilt2(I3]);
I3=im2double(I3);

I3=im2bw(I3);                       %converting image to black and white

I3 = bwmorph(~I3, 'thin', inf);                   %thining the image

I3=~I3;
im1 = I3;
% figure(3),imshow(I3);
% pause

%extracting the black pixels
k=1;
for i=1:512
    for j=1:512
        if(I3(i,j)==0)
            u(k)=i;
            v(k)=j;
            k=k+1;
            I3(i,j)=1;
        end
    end
end

C=[u;v];
N=k-1;%the number of pixels in the signature

oub=sum(C(1,:))/N;   %the original x co-ordinate center of mass of the image
ovb=sum(C(2,:))/N;   %the original y co-ordinate center of mass of the image


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%********ROTATE******%%%%%%%%%%%%%%%%%%%%%%%%
%moving the signature to the origin
for i=1:N
    u(i)=u(i)-oub+1;
    v(i)=v(i)-ovb+1;
end
% the new curve of the signature
C=[u;v];
ub=sum(C(1,:))/N;
vb=sum(C(2,:))/N;
ubSq=sum((C(1,:)-ub).^2)/N;
vbSq=sum((C(2,:)-vb).^2)/N;
 
for i=1:N
    uv(i)=u(i)*v(i);
end
uvb=sum(uv)/N;
M=[ubSq uvb;uvb vbSq];
%calculating minimum igen value of the matrix
minIgen=min(abs(eig(M)));
%the eigen vector
MI=[ubSq-minIgen uvb;uvb vbSq-minIgen];
theta=(atan((-MI(1))/MI(2))*180)/pi;
thetaRad=(theta*pi)/180;
rotMat=[cos(thetaRad) -sin(thetaRad);sin(thetaRad) cos(thetaRad)];
%% rotating the signature and passing the new co-ordinates
for i=1:N
    v(i)=(C(2,i)*cos(thetaRad))-(C(1,i)*sin(thetaRad));
    u(i)=(C(2,i)*sin(thetaRad))+(C(1,i)*cos(thetaRad));
end
C=[u;v];
%moving the signature to its original position
for i=1:N
    u(i)=round(u(i)+oub-1);
    v(i)=round(v(i)+ovb-1);
end
%after rotating the image the signature might go out of the boundry (128x128) therefore 
%we have to move the signature curve 
mx=0;%the moving x co-ordinate
my=0;%the moving y co-ordinate
if (min(u)<0)
    mx=-min(u);
    for i=1:N
        u(i)=u(i)+mx+1;
    end
end
if (min(v)<0)
    my=-min(v);
    for i=1:N
        v(i)=v(i)+my+1;
    end
end
C=[u;v];
for i=1:N
    I3((u(i)),(v(i)))=0;
end
% figure(4),imshow(I3);
% pause


% removing extra white space in sides
xstart=512;
xend=1;
ystart=512;
yend=1;
for r=1:512
    for c=1:512
        if((I3(r,c)==0))
            if (r<ystart)
                ystart=r;
            end
            if((r>yend))
                yend=r; 
            end
            if (c<xstart)
                xstart=c;
            end
            if (c>xend)
                xend=c;
            end     
       end  
    end
end

%cutting the image and copying it to another matrix        
for i=ystart:yend
    for j=xstart:xend
        im((i-ystart+1),(j-xstart+1))=I3(i,j);
    end
end
% figure(5),imshow(im); %cropped image
im_processed = im;
% Feature Extraction - NSA --------------------------

PixelB = 0;
PixelA = 0;
for i=ystart:yend
    for j=xstart:xend
        if (im(i-ystart+1,j-xstart+1)== 0)
            PixelB = PixelB + 1;
        end
        PixelA = PixelA + 1;
    end
end

%disp([PixelB,PixelA]);
NSA = PixelB/PixelA;
% disp(NSA);

% Feature Extration - Aspect Ratio -----------------

height_sign = yend-ystart;
length_sign = xend-xstart;
aspect_ratio = length_sign/height_sign;

% Feature Extraction - Maximum Horizontal and Vertical Projection

max=0;

for i=ystart:yend
    summ=0;
    for j=xstart:xend
        if(im((i-ystart+1),(j-xstart+1))==0)
            summ=summ+1;
        end
    end
    if (summ>max)
        max=summ;
    end
end
max;
max1=0;
for i=xstart:xend
    summ=0;
    for j=ystart:yend
        if(im((j-ystart+1),(i-xstart+1))==0)
            summ=summ+1;
        end
    end
    if (summ>max1)
        max1=summ;
    end
end
max1;
xdiff=xend-xstart;
ydiff=yend-ystart;
%disp(xdiff)
%disp(ydiff)
Hor_Proj = max/xdiff;
Ver_Proj = max1/ydiff;


% Feature Extraction End Points ---------------------------
i1 = im1;
[row, col, depth] = size(i1);
%add row%
addrow = ones(1, col);
i1 = [addrow; addrow; i1; addrow];
[row, col, depth] = size(i1);
%add column%
addcol = ones(row, 1);
i1 = horzcat(addcol, i1, addcol, addcol);
[row, col, depth] = size(i1);
i1=~i1;
crosspoints=0;
 for r = 3:row-1
        for c = 2:col-2
            if(i1(r,c)==1)
                if (i1(r-1,c-1)+i1(r-1,c)+i1(r-1,c+1)+i1(r,c-1)+i1(r,c+1)+i1(r+1,c-1)+i1(r+1,c)+i1(r+1,c+1)==1)
                    crosspoints=crosspoints+1;
                    %disp(i1(r,c))
                end
            end
        end
 end
%disp(crosspoints)

% Feature Extraction Center of Gravities of the vertically divided images--
n1 = im(:,  1: xdiff/2);%splitting images
n2 = im(:,  xdiff/2+1:xdiff);
%figure(6),imshow(n1);
%figure(7),imshow(n2);
sum1=0;
pix_total=0;
%for the first half
for i=1:ydiff
    pix_sum=0;
    for j=1:xdiff/2
       if(n1(i,j)==0)
           pix_sum=pix_sum+1;
           pix_total=pix_total+1;
       end
    end
    sum1=sum1+(pix_sum*i);
end
Y1=sum1/pix_total;
RY1=Y1/ydiff;
sum1=0;
for i=1:xdiff/2
    pix_sum=0;
    for j=1:ydiff
       if(n1(j,i)==0)
           pix_sum=pix_sum+1;
       end
    end
    sum1=sum1+(pix_sum*i);
end
X1=sum1/pix_total;
RX1=2*X1/xdiff;
%for the secong half
sum1=0;
pix_total=0;
for i=1:ydiff
    pix_sum=0;
    for j=1:xdiff/2
       if(n2(i,j)==0)
           pix_sum=pix_sum+1;
           pix_total=pix_total+1;
       end
    end
    sum1=sum1+(pix_sum*i);
end
Y2=sum1/pix_total;
RY2=Y2/ydiff;
sum1=0;
for i=1:xdiff/2
    pix_sum=0;
    for j=1:ydiff
       if(n2(j,i)==0)
           pix_sum=pix_sum+1;
       end
    end
    sum1=sum1+(pix_sum*i);
end
X2=sum1/pix_total;
RX2=2*X2/xdiff;


centroid = [ [RX1 RY1] [RX2 RY2] ];
% Feature Extraction - Slope ------------------


m=xdiff;
m=m/2;
k=m+X2;
slope=(Y2-Y1)/(k-X1);


Feat_Val = [ NSA aspect_ratio Hor_Proj crosspoints centroid slope];



end

