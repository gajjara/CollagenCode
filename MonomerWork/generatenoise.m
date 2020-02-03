I = imnoise(imread('/Users/Anuj/Desktop/MonomerSample.png'),'gaussian');
gamma = 2.2;
I = 0.2126*I(:,:,1) + 0.7152*I(:,:,2) + 0.0722*I(:,:,3);
I = uint8(I);
figure; imshow(I);
imwrite(I, '/Users/Anuj/Desktop/MonomerSampleNoise.png');