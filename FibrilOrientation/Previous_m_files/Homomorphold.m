sigma = 10;
filterRadius = sigma;
filterSize = 2*filterRadius + 1;
hLowPass = fspecial('gaussian', filterSize);
hImpulse = zeros(filterSize, filterSize);
hImpulse(filterRadius, filterRadius) = 1;
hHighPass = hImpulse - hLowPass;
Ih_spatial = imfilter(I, hHighPass, 'replicate');
Ih_spatial = exp(double(Ih_spatial)) -1;