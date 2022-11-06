function normalizedM  = hsinormalize( M )
[h, w, numBands] = size(M);

M = reshape(M, w*h, numBands).';

minVal = min(M(:));
maxVal = max(M(:));

normalizedM = M - minVal;
normalizedM = normalizedM ./ (maxVal-minVal);

normalizedM = reshape(normalizedM.', h, w, numBands); 