I = imread('/Users/Anuj/Desktop/TestProcess.tiff');
I2 = flipdim(I, 2);
I3 = flipdim(I2, 1);
figure; imshow(I3);
imwrite(I3, '/Users/Anuj/Desktop/TestProcessOrientationRight.tiff');
