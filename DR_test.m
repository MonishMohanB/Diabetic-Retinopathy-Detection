clc
clear all
close all
load('net.mat')  %loading the saved net
[FileName,PathName] = uigetfile('*.png;','select the cover image');  %reading the specifies types of the image
dat=imread([PathName,FileName]);
data=imresize(dat,[500 700]);  %reesizing the image into 500 700
figure,imshow(data);

% no of micro neurysms
greenchannel = data(:,:,2);    % green channel of the image

ginverse = imcomplement (greenchannel); % complementing green channel           
adahisteq = adapthisteq(ginverse);   %increasing the intensity of the inverse green channel for highlitening the blood vessel
threshold = 0.2
BW = edge(adahisteq,'Canny',threshold);  %canny detection
h=imfill(BW,'holes'); % filling the holes
k=h-BW;

BW2 = bwpropfilt(logical(k),'Area',[7 12]); %taking out the clustered pixels of the specified range area
[l,numberOfCircles]= bwlabel(BW2);  % counting the number of clustered pixels

 
%extraction of blood vessel and haemorrhages
greenc = data(:,:,2);                          % Extract Green Channel
ginv = imcomplement (greenc);               % Complement the Green Channel
adahist = adapthisteq(ginv);
se = strel('ball',8,8);                     % Structuring Element
gopen = imopen(adahist,se);                 % Morphological Open
godisk = adahist - gopen;                   % Remove Optic Disk
 
medfilt = medfilt2(godisk);                 %2D Median Filter
background = imopen(medfilt,strel('disk',15));% imopen function
I2 = medfilt - background;                  % Remove Background
I3 = imadjust(I2);                          % Image Adjustment
 
level = graythresh(I3);                     % Gray Threshold
bw = im2bw(I3,level);                       % Binarization
bw1 = bwareaopen(bw, 30);
  
 [i,j]= size(bw1);
 c=0;
 for i=1:500
     for j=1:700
         if bw1(i,j)==1
             c=c+1;
         end
     end
 end
  bw2=im2bw(bw1);
 mea2=mean2(bw2);
sd1=std2(bw2)


 % extraction of exudates 
g=data(:,:,2);
a=adapthisteq(g);
 
im= imadjust(a);
im2=im2bw(im,.9);
med=medfilt2(im2);
 
im3=imerode(med,strel('disk',10));
im4=imdilate(im3,strel('octagon',63));
 
 
im5=imimposemin(g,im4);
 
 
im6=g-im5;
im8=adapthisteq(im6);
im9=im2bw(im8);
med1=medfilt2(im9);
 
 
im10=imdilate(med1,strel('disk',40));
im12=med-im10;
im13=im2bw(im12);
BW2 = bwpropfilt(logical(im13),'Area',[0 1000])

[k,l]= size(BW2);
c1=0;
 for k=1:500
     for l=1:700
         if im12(k,l)==1
             c1=c1+1;
         end
     end
 end
  mea1=mean2(BW2);
sd2=std2(BW2);
 p=[c;c1;numberOfCircles;mea2;sd1;mea1;sd2];  % seven iput features
 y=sim(net,p);  %estimted values
o=round(y);
a1=[0 0 0 1];   % target values of the class 1
a2=[0 0 1 0];   % target values of the class 2
a3=[0 1 0 0];   % target values of the class 3
a4=[1 0 0 0];   % target values of the class 4
a11=a1.';
a22=a2.';
a33=a3.';
a44=a4.';
if o == a11
    disp('Normal eye');
else if o== a22
   disp('Mild nonproliferative retinopathy');
    else if o==a33
        disp('moderate nonproliferative retinopathy');
        else
            disp('severe npdr');
        end
        
        end
    end

