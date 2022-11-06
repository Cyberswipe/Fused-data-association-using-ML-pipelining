function [out, l] = kpca2(spectraldata, perc, No_Train, sigma)
[nrows,ncols,nbands] = size(spectraldata);
Xtest = reshape(spectraldata,nrows*ncols,nbands);
%clear spectraldata

%% sub-sample for training, select No_Train samples randomly
% parameters for different methods
%No_Train=1000; % number of samples randomly selected to train KPCA
kernel='rbf';%sigma=1; % parameters for KPCA
%numfea=100; % number of extracted features for KPCA
rand('state',4711007);% initialization of rand
if No_Train>nrows*ncols, No_Train = nrows*ncols; end
idxtrain = randsample(nrows*ncols, No_Train);
Xtrain = double(Xtest(idxtrain,:));
Xtrain=Xtrain';
Xtest=Xtest';

    % Calculate constants
    X2 = sum(Xtrain.*Xtrain,1)';
    D2 = repmat(X2,1,No_Train) + repmat(X2',No_Train,1) - 2*Xtrain'*Xtrain; % distance metric for the Gaussian kernel
    dum = sort(D2,1,'ascend');
    commonscale = mean(mean(dum(1:0.25*No_Train,:)));
    sigma = commonscale*sigma;
    clear dum X2
    %
    %% Step II - perform kPCA
    K = exp(-D2/sigma);
    J = ones(No_Train,No_Train)/No_Train;
    Kc = K - J*K - K*J + J*K*J; % centered kernel
    [V,S] = eig((Kc+Kc')/2);
    [dsort, idum]=sort(diag(S),'descend'); % sort eigenvectors
    l=abs(dsort);
    V=V(:,idum);
    for i = 1:No_Train
        ppp=sum(l(1:i))/sum(l);
        if l(i) ~= 0,
            V(:,i) = V(:,i)/sqrt(l(i));
        end
        if ppp<=perc,
            numfea=i;
        end
    end
    %
    numfea
    eigenvec = V(:,1:numfea);
    
    meanK = mean(K(:));
    meanrowsK = mean(K);
    
    beta = NaN(numfea, size(Xtest,2));
    for rr=1:nrows
       idx = (rr-1)*ncols+1;
       idx = idx:(idx+ncols-1);
       [Ktrn, Xk]=kernel2(Xtrain,Xtest(:,idx),kernel,sigma);
       Xk = Xk - repmat(meanrowsK,ncols,1)' - repmat(mean(Xk),No_Train,1) + meanK;
       beta(:,idx) = (Xk'*eigenvec)';
    end
    
out = reshape(beta',nrows,ncols,numfea);


