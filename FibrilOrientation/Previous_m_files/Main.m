%% Read Image
I = imread('/Users/Anuj/Desktop/Data^1.png');
I = I(:,:,1); %Greyscale
I = single(I(:,:));

%% Normalize MATLAB
normval = 216;
norm = normval*normalize(I, 'range');
I = uint8(norm);

figure(1); imshow(I);

%% Diffuse Filter

[gradientThreshold, numIter] = imdiffuseest(I);
I_F = imdiffusefilt(I, 'GradientThreshold', gradientThreshold, 'NumberOfIterations', numIter);

figure(2), imshow(I_F);

%% Renormalize MATLA
normval = 255;
norm = normval*normalize(single(I_F), 'range');
I_R = uint8(norm);

figure(3); imshow(I_R);

%% Sharpen
sharpenVal = 2.0;
I_S = imsharpen(I_R, 'Amount', sharpenVal);

figure(4); imshow(I_S);

%% Threshold
I_T = Threshold(I_S, 253);
figure(5); imshow(I_T);
