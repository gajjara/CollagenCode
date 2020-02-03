function OUTPUT = process_new(PATH)
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

figure; imshow(BW);
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
OUTPUT = uint8(255.*normalize(OUT + IN));

end