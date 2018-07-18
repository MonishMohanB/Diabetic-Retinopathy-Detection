clc
clear all;
close all;
%t2 = path(path,'C:\Users\Jissmol\Desktop\diaretdb1_v_1_1\diaretdb1_v_1_1\resources\images\Train_Images');
t=dir('Train_Images');  % loading the directory
t1=struct2cell(t);  % converting into cell 
t2=t1(1,3:end);     % taking out the last 3rd coloumn 

for m=1:length(t2);
    waitbar(m/length(t2))
    data=imresize(imread(strcat('Train_Images\',t2{m})),[500 700]); % reading the image one by one and resizing into 500 700
  

% no of micro neurysms
greenchannel = data(:,:,2);    % green channel of the image
ginverse = imcomplement (greenchannel); % complementing green channel           
adahisteq = adapthisteq(ginverse);   %increasing the intensity of the inverse green channel for highlitening the blood vessel
threshold = 0.2
BW = edge(adahisteq,'Canny',threshold); % canny edge detection
h=imfill(BW,'holes'); % filling the holes
k=h-BW;
BW2 = bwpropfilt(logical(k),'Area',[7 12]);  %taking out the clustered pixels of the specified range area
subplot(2,2,1);
imshow(BW2);
[l,numberOfCircles(m)]= bwlabel(BW2); % counting the number of clustered pixels

%extraction of blood vessel and haemorrhages
greenc = data(:,:,2);                          % Extract Green Channel
ginv = imcomplement (greenc);               % Complement the Green Channel
adahist = adapthisteq(ginv);                % adaptive histogram equalization
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
subplot(2,2,2);
imshow(bw1);
[i,j]= size(bw1);
 c(m)=0;
 for i=1:500
     for j=1:700
         if bw1(i,j)==1
             c(m)=c(m)+1;
         end
     end
 end
 bw2=im2bw(bw1);
 mea2(m)=mean2(bw2);
sd1(m)=std2(bw2);


 % extraction of exudates
g=data(:,:,2);   % green channel
a=adapthisteq(g); % adaptive histogram equalization
im= imadjust(a); % adjusting the contrast
im2=im2bw(im,.9); 
med=medfilt2(im2);
im3=imerode(med,strel('disk',10)); %morphological erosion
im4=imdilate(im3,strel('octagon',63)); %morphological dilation
im5=imimposemin(g,im4); %imposing one mage on the other
im6=g-im5;
im8=adapthisteq(im6);
im9=im2bw(im8);
med1=medfilt2(im9);
im10=imdilate(med1,strel('disk',40)); %morphological dilation
im12=med-im10;
im13=im2bw(im12);
BW2 = bwpropfilt(logical(im13),'Area',[0 1000])
subplot(2,2,3);
imshow(BW2);
[k,l]= size(BW2)
c1(m)=0;
 for k=1:500
     for l=1:700
         if BW2(k,l)==1
             c1(m)=c1(m)+1;
         end
     end
 end
 im13=im2bw(im12);
  mea1(m)=mean2(im13);
sd2(m)=std2(im13);
 
end
p=[c;c1;numberOfCircles;mea2;sd1;mea1;sd2];  % all the seven input features
ta=[         
1	0	0	0  % target/desired values
0	1	0	0
1	0	0	0
0	0	0	1
0	0	1	0

];
ta1=ta.'
net1=newff(minmax(p),[20,4],{'logsig','purelin'});  % designing the net with the acti ation functions
net1.trainParam.epochs = 8000;  % defining the range of epochs
net1.trainParam.goal=0;    % defining the mean square error


[net,tr]=train(net1,p,ta1);  % traing the net with the input features and the target values
plotperform(tr)
yn=sim(net,p);  % estimated values

save('net.mat','net') % saving the net