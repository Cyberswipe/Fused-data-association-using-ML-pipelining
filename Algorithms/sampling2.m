function [Xunlabeled,Xunlabeledli,Xunlabeledemp,unlabeled,grdnew] = sampling2(spectraldata, LiDAR, EMP, grd, ws, method,num_samp)
%%%=============================================
%[Xunlabeled,unlabeled,grdnew] = sampling(spectraldata, grd, ws) gets unlabeled
%samples from the groundtruth to do classification
%      output:
%              spectraldata  ---- Hypercube
%              grd           ----the ground truth of the hyperspectral
%                                image
%              ws            ----the sliding window size
%              method        ----methods of sampling unlabeled samples
%                                
%      input:  
%              Xunlabeled    ----unlabeled samples
%              unlabeled     ----the test samples
%              grdnew        ---- unlabeled sample map
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[width,height,nDimsp]=size(spectraldata);
nDimli=size(LiDAR,3);
nDimemp=size(EMP,3);
hws=(ws-1)/2;  % half ws 
Xunlabeled=[];
Xunlabeledli=[];
Xunlabeledemp=[];
unlabeled=[];
grdnew=grd;

switch lower(method)
   case 'randomly'
      [x0,y0]=find(grd==0);
      xx0=randperm(size(x0,1));
      for i=1:num_samp
          Xunlabeled=[Xunlabeled;reshape(spectraldata(x0(xx0(i)),y0(xx0(i)),:),1,nDimsp)];
          Xunlabeledli=[Xunlabeledli;reshape(LiDAR(x0(xx0(i)),y0(xx0(i)),:),1,nDimli)];
          Xunlabeledemp=[Xunlabeledemp;reshape(EMP(x0(xx0(i)),y0(xx0(i)),:),1,nDimemp)];
          unlabeled=[unlabeled,grd(x0(xx0(i)),y0(xx0(i)))];
          grdnew(x0(xx0(i)),y0(xx0(i)))=20;
      end
   case 'nearest'
       [xlab,ylab]=find(grd>0);
       for i=1:length(xlab)
           iMin = max(xlab(i)-hws,1);
           iMax = min(xlab(i)+hws,width);
           jMin = max(ylab(i)-hws,1);
           jMax = min(ylab(i)+hws,height);
           for j=iMin:iMax
               for k=jMin:jMax
                   if grdnew(j,k)==0
                       Xunlabeled=[Xunlabeled;reshape(spectraldata(j,k,:),1,nDimsp)];
                       Xunlabeledli=[Xunlabeledli;reshape(LiDAR(j,k,:),1,nDimli)];
                       Xunlabeledemp=[Xunlabeledemp;reshape(EMP(j,k,:),1,nDimemp)];
                       unlabeled=[unlabeled,grd(j,k)];
                       grdnew(j,k)=20;
                   end
               end
           end
       end
       
   case '1classnearest'
       no_class=unique(grd);
       for i=1:length(no_class)-1
           [xlab,ylab]=find(grd==no_class(i+1));
           xcur=randperm(length(xlab));
           for jj=1:1
               iMin = max(xlab(xcur(jj))-hws,1);
               iMax = min(xlab(xcur(jj))+hws,width);
               jMin = max(ylab(xcur(jj))-hws,1);
               jMax = min(ylab(xcur(jj))+hws,height);
               for j=iMin:iMax
                   for k=jMin:jMax
                       if grdnew(j,k)==0
                           Xunlabeled=[Xunlabeled;reshape(spectraldata(j,k,:),1,nDimsp)];
                           Xunlabeledli=[Xunlabeledli;reshape(LiDAR(j,k,:),1,nDimli)];
                           Xunlabeledemp=[Xunlabeledemp;reshape(EMP(j,k,:),1,nDimemp)];
                           unlabeled=[unlabeled,grd(j,k)];
                           grdnew(j,k)=20;
                       end
                   end
               end
           end
       end          

   otherwise
      disp('Unknown method.')
end
