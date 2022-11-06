function K = centering(K)

% K = centering(K)
%
% Center a kernel matrix
%


[nrow nclom] = size(K);
if nrow ~= nclom
    error('input matrix must be symmetric matrax')
end


D = sum(K)/nrow;
E = sum(D)/nrow;
J = ones(nrow,1)*D;
K = K-J-J'+E;
