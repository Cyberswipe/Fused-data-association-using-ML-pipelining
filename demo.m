% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear all

%% add path in
p = fileparts(mfilename('fullpath'));
addpath(fullfile(p,'Algorithms'));
addpath(fullfile(p,'Images'));
addpath(fullfile(p,'KPCA'));

%% parameters for different methods
classifier_type='svm';% the classifier used to classification

%% load the hyperspectral data set and ground truth
%load UPavia
spectraldata=double(imread('2013_IEEE_GRSS_DF_Contest_CASI.tif'));
testlabels=imread('allgrd.tif');%imread('testlabels.tif');%Test_Pavia;
trainlabels=imread('grd.tif');
RGB=imread('Grd_Falsecolor.png');%Test_Pavia;
class_num=15;% the number of the class
%% information from the Lidar data
LiDAR=double(imread('2013_IEEE_GRSS_DF_Contest_LiDAR.tif'));


load NewEMP_Lidar_disk%pad%EMP_LiDAR
load NewEMP_Lidar_line%EMP_LiDAR
%% morphological features for Lidar data
EMPLidar=cat(3,EMPLidar_diskO,EMPLidar_diskC, EMPLidar_lineO, EMPLidar_lineC);%
clear EMPLidar_diskO EMPLidar_diskC EMPLidar_lineO EMPLidar_lineC
%%% Information from hyperspectral data
%% morphological features for hyperspectral data
%%
load NewEMP_hsi_disk%pad%EMPhsi_diskP
load NewEMP_hsi_line%EMPhsi_lineP
EMPhsi=cat(3, EMPhsi_diskO(:,:,1:30),EMPhsi_diskC(:,:,1:30),EMPhsi_lineO(:,:,1:40),EMPhsi_lineC(:,:,1:40));%cat(3,EMPhsi_lineP,EMPhsi_disk);
clear EMPhsi_diskO EMPhsi_diskC EMPhsi_lineO EMPhsi_lineC%EMPhsi_disk EMPhsi_lineP
%%
spectraldata=spectraldata(1:100,1:100,1:5);
testlabels=testlabels(1:100,1:100,:);
trainlabels=trainlabels(1:100,1:100,:);
RGB=RGB(1:100,1:100,:);
EMPhsi=EMPhsi(1:100,1:100,1:5);
EMPLidar=EMPLidar(1:100,1:100,1:5);
%Lidar=Lidar(1:100,1:100,:);
%trls=trls(1:100,1:100,:);

%% Data fusion
No_sam_KPCA=100; % Number of samples to train KPCA
No_KPCs=10;
spectraldata =kpca(spectraldata, No_sam_KPCA, No_KPCs, 'Gaussian',20);%[spectraldata,idxtrain]NWFE_Fusion(spectraldata, trainlabels, 12);%'poly',[1, 2.5]);%kpca2(spectraldata, 0.99, 1000, 2);%pca(spectraldata, 2);%
EMPhsi=kpca(EMPhsi, No_sam_KPCA, No_KPCs,'Gaussian', 10);%NWFE_Fusion(EMPhsi, trainlabels, 15);%30 'poly',[1, 3.8]);%kpca2(EMPhsi, 0.99, 1000, 20);%pca(EMPhsi, 17);%
EMPLidar=kpca(EMPLidar, No_sam_KPCA, No_KPCs, 'Gaussian',10);%NWFE_Fusion(EMPLidar, trainlabels, 15);%10'poly',[1, 2.8]);%kpca2(EMPLidar, 0.99, 1000, 20);%pca(EMPLidar, 16);%

spectraldata=hsinormalize(spectraldata);
EMPhsi=hsinormalize(EMPhsi);
EMPLidar=hsinormalize(EMPLidar);

Xsp=reshape(spectraldata,size(spectraldata,1)*size(spectraldata,2),size(spectraldata,3));
Xemp=reshape(EMPhsi,size(EMPhsi,1)*size(EMPhsi,2),size(EMPhsi,3));
XLiDAR=reshape(EMPLidar,size(EMPLidar,1)*size(EMPLidar,2),size(EMPLidar,3));

trls=double(getlabeledUH(trainlabels, 0));%
method='randomly';%'1classnearest';%'nearest';%
ws=11;
[Xspunlab,XLiDARunlab,Xempunlab] = sampling2(spectraldata,EMPLidar, EMPhsi, trls, ws,method,70);

Xunlab=[Xspunlab, Xempunlab, XLiDARunlab];%
X=[Xsp, Xemp, XLiDAR];%
tStart2 = tic;
W=GGF(Xunlab,Xspunlab,XLiDARunlab,Xempunlab, 22,10);
Xts=X*W;
DF_allFea=reshape(Xts,size(spectraldata,1),size(spectraldata,2),22);
tFea = toc(tStart2);

%% ==============classification precessing==========================
    
    mask= trainlabels; % training sets
    labels=testlabels; % testing sets

    %% do classification 
    c=Classifier(classifier_type);

    %% use the features from the proposed data fusion
    tStart3 = tic;
    cDF=train(c,DF_allFea,labels,mask);
    outDF=classify(cDF,DF_allFea);
    tCls = toc(tStart3);

    labels=imread('testlabels.tif');%imread('allgrd.tif');% 
    OADF= size(find(outDF==labels),1)/size(find(labels>0),1);    
    
    %% calculate the classifying accuracy for each class
    for j=1:class_num
         AVDF(j)=size(find(outDF==labels & outDF==j & labels==j),1)/size(find(labels==j),1);       
         for jjj=1:class_num
             KDF(j,jjj)=size(find(outDF==j & labels==jjj),1);
         end
    end
    
% calculate the kappa coefficient (Kappa)
    disp('Kappa coefficients for proposed data fusion:')
    [poDF,kpDF]=kappa(KDF);   
    
% calculate the classification accuracy for each class
disp('The classification accuracy for each class: ')
for i=1:class_num
    disp(['The classify accuracy of class ' num2str(i),sprintf(' is: %.4f%',AVDF(i))]) 
    
end

%===========================================
% calculate the overall classification accuracy (OA)
disp('The overall classification accuracy:')
OADF=OADF*100
%===========================================
% calculate the average classification accuracy (AA)
disp('The average classification accuracy:' )
AADF=100*sum(AVDF)/class_num


RGBoutDF=Contest_colorchange(outDF);
%% display the classification maps
figure;
subplot(2,1,1);imagesc(uint8(RGB));title('Grd_color')
subplot(2,1,2);imagesc(uint8(RGBoutDF));title(sprintf('Proposed data fusion: (OA= %.1f%%, AA= %.1f%%)', [OADF,AADF]))
