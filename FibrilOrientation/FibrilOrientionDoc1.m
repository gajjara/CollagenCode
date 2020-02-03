%% FIBRIL ORIENTATION TRY
% Program explores the use of a radon transform and hough transform to
% identify the orientation of firils in an image
%
% Before the images are undergone a radon transform and hough transform the
% images are undergone through a processing algorithm built in Java, this
% algorithm essentially consists of these steps:
%
% * Adaptive Histogram normalization of the image
% * The adaptive histogram equalaizatoin is done so by looping through all
% the possible values of normalization (i.e. 0-255) and identifying the
% highest constrast producing normalization by comparing the normalization
% of an image histogram with an ideally distributed image histogram
% * And finally median filtering for noise reduction
%
% (This algoritm can be added as MATLAB code)
%
% Then the image that was processsed through Java is ran through a series
% of processes in MATLAB, which consists of: 
%
% * A second histogram normalization of the image
% * A Diffusion Filter to reduce more noise
% * A third and final histogram normalization that expands the image
% intensity range over the whole 8-bit range (i.e 0-255)
% * Sharpening of the image
% * Thresholding of the image
%
% After the image has undergone those processing steps the resulting image
% is then ran through the Hough and Radon transforms


%% ORIGINAL IMAGE
figure;
imshow(imread('/Users/Anuj/Downloads/ChuckCode/data/DATA_1/Fluor_Fibril_100ms/labeled_monomerst001c2.tif'));
title('Original Image');

%% IMAGE PROCESSED IN JAVA
% See above for processing steps
I = imread('/Users/Anuj/Desktop/Current_Work/OSL_NEU/MonomerImageProcessing/Outputs/OutJava1.jpeg');
I = I(:,:,1);
figure; imshow(I);
title('Image Processed in Java');

%% IMAGE PROCESSED IN MATLAB
% See above for processing steps
    normval1 = 216;
    normalization = normval1.*normalize(double(I), 'range');
    I = uint8(normalization);
    [gradientThreshold, numIter] = imdiffuseest((I));
    I_F = imdiffusefilt(I, 'GradientThreshold', gradientThreshold, 'NumberOfIterations', numIter);
    normval2 = 255;
    normalization2 = normval2*normalize(single(I_F), 'range');
    I_R = uint8(normalization2);
    sharpenVal = 2.0;
    I_S = imsharpen(I_R, 'Amount', sharpenVal);
    I_T = Threshold(I_S, 245);
    figure; imshow(I_T);
    title('Secondary processing of Image in MATLAB');
    
%% RADON TRANSFORM
% Here the image is essentially first run through a Radon transform using
% the radon() function in MATLAB. Then the image is 'filtered' by
% thresholding out all the values that are less than the maximum value of
% the Radon transform. The inverse radon transform is then taken of that
% thresholded Radon transform using the iradon() function in MATLAB.

[R, Xp] = radon(I_T);
figure; imagesc(0:179, Xp, R); C = colorbar; title("Radon Transform");
Lim = C.Limits; Lim = Lim(2);
Thres = Lim/2;
R1 = R.*(R>Thres);
figure; imagesc(0:179, Xp, R); colorbar; title("Thresholded Radon Transform");
test = iradon(R1, 0:179, 'linear', 'none');
figure; imagesc(test); colorbar; title("Inverse Radon Transform");

%% HOUGH TRANSFORM
% Here the image is essentially ran through the funtions provided by MATLAB
% to perform a hough transform to identify lines in the image. These
% functions are hough(), houghpeaks(), and houghlines().

BW = I_T;
[H, theta, rho] = hough(BW);
P = houghpeaks(H, 100);
showHoughLines(BW, theta, rho, P);
title("Lines from Hough Transform");

%% RADON AND HOUGH TRANSFORM COMBINATION ATTEMPT
% Here is an attempt at combining the two transforms together by first
% summing all values of the processed image, the image of the inverse radon
% transform, and the image of the detected lines from the hough transform.
% Then the image values are normalized to be in uint8 data.
figure; imshow(imread('/Users/Anuj/Desktop/combine_out.png'));
title('Combined Image of Processed Image, Radon Image, and Hough Image');
figure; imshow(imread('/Users/Anuj/Desktop/combine_out copy.png'));
title('Thresholded Image of Combined Image');