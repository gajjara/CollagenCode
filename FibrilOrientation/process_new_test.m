%%
PATH = '/Users/Anuj/Desktop/OSL_NEU/FibrilOrientation/FibrilJava.png';

%% Input JAVA Image
I = imread(PATH);
I = I(:,:,1); %Greyscale

%% Normalize/Threshold
I = histeq(I);
normalizationval = 255;
normalization = normalizationval.*normalize(double(I), 'range');
I = uint8(normalization);
I = Threshold(I, 254);
I = double(I);

BW = I;

%% Implement Homomorphic Filter
% https://blogs.mathworks.com/steve/2013/07/10/homomorphic-filtering-part-2/
% Ilog = log(1 + I);
% M = 2*size(I, 1) + 1;
% N = 2*size(I, 2) + 1;
% sigma = std2(I);
% [X,Y] = meshgrid(1:N, 1:M);
% centerX = ceil(N/2); centerY = ceil(M/2);
% gNum = (X-centerX).^2 + (Y-centerY).^2;
% H = 1 - exp((-gNum)./(2*(sigma^2)));
% H = fftshift(H);
% alpha = 0.25; beta = 0.5;
% %Hemphasis = alpha + beta.*H;
% Hemphasis = H;
% Iout = real(ifft2(Hemphasis.*fft2(Ilog,M,N)));
% Iout = Iout(1:size(I, 1), 1:size(I, 2));
% Iout = uint8(rescale(Iout, 0, 255));
% BW = double(Iout);

%% Hough Transform
[H, theta, rho] = hough(BW);
maxn = floor(norm(size(BW)));
npeaks_peak = zeros(1, maxn);
for i = 1:maxn
    npeaks_peak(i) = length(houghpeaks(H, i));
end
npeaks = min(find(max(npeaks_peak) == npeaks_peak));
P = houghpeaks(H, npeaks);
%lines = showHoughLines(BW, theta, rho, P);
lines = houghlines(BW, theta, rho, P);

figure; imshow(uint8(BW));
hold on;
for i = 1:length(lines)
    xy = [lines(i).point1; lines(i).point2];
    L = line(xy(:,1),xy(:,2), 'Color', 'white', 'LineWidth', 2);
end
F = getframe;
X = F.cdata;
X = X(1:512, 1:512, :);

%% Combine
OUT = double(X(:,:,1));
IN = imread(PATH);
IN = double(IN(:,:,1));
OUTPUT = (OUT + IN);