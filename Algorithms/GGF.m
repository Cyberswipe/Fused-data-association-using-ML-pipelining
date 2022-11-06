function eigvector= GGF(X, Xsp, Xli, Xemp, no_dims, k)

%
%   [eigvector, GG]= GGF(X, Xsp, Xli, Xemp, no_dims, k)
%
% Generalized Graph-Based Fusion of Hyperspectral and LiDAR Data Using Morphological Features
%

  

    % Construct neighborhood graph
        G = L2_distance(X', X');
        Gsp = L2_distance(Xsp', Xsp');
        Gli = L2_distance(Xli', Xli');
        Gemp = L2_distance(Xemp', Xemp');
        [tmpsp, indsp] = sort(Gsp);
        [tmpli, indli] = sort(Gli); 
        [tmpemp, indemp] = sort(Gemp); 
        k1=150;
        for i=1:size(G, 1)
            Gsp(i, indsp((2 + k1):end, i)) = 0;
            Gli(i, indli((2 + k1):end, i)) = 0; 
            Gemp(i, indemp((2 + k1):end, i)) = 0; 
            
            Gsp(i, indsp(2:(k1+1), i)) = 1;
            Gli(i, indli(2:(k1+1), i)) = 1; 
            Gemp(i, indemp(2:(k1+1), i)) =1;             
        end

        FuG=Gsp.*Gemp.*Gli;
        FuG=~FuG;
        G=G+FuG*max(G(:));
        [tmp, ind] = sort(G);
        for i=1:size(G, 1)
           G(i, ind((2 + k):end, i)) = 0;
        end

    G = max(G, G');
    D = diag(sum(G, 2));
    
    % Compute Laplacian
    L = D - G;
    L(isnan(L)) = 0; D(isnan(D)) = 0;
	L(isinf(L)) = 0; D(isinf(D)) = 0;

    % Compute XDX and XLX and make sure these are symmetric
    DP = X' * D * X;
    LP = X' * L * X;
    DP = (DP + DP') / 2;
    LP = (LP + LP') / 2;

    % Perform eigenanalysis of generalized eigenproblem (as in LEM)
   [eigvector, eigvalue] = eig(LP, DP);

    
    % Sort eigenvalues in descending order and get largest eigenvectors
    [eigvalue, ind] = sort(diag(eigvalue), 'ascend');
    eigvector = eigvector(:,ind(1:no_dims));
        
