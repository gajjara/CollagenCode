%ProcessSum
%% Read Image and Radon and Inverse Radon transform
%I_O = imread('/Users/Anuj/Desktop/Current_Work/OSL_NEU/MonomerImageProcessing/Outputs/OutJava1.jpeg');
%I_P = imread('/Users/Anuj/Desktop/Current_Work/OSL_NEU/MonomerImageProcessing/Outputs/OutMAT1.png');
%if(isequal(I_O(:,:,1), I_O(:,:,2), I_O(:,:,3))) I_O = I_O(:,:,1); end

R = radon(I_P);
[R, Xp] = radon(I_P);
figure; imagesc(0:179, Xp, R); C = colorbar;
Lim = C.Limits; Lim = Lim(2); %Thres = Lim/2;
Thres = (5/9)*Lim;
R1 = R.*(R>Thres);
IR = iradon(R1, 0:179, 'linear', 'none');
figure; imagesc(IR); colorbar;
BW = I_P;

%% Get and show Lines
[H, theta, rho] = hough(BW);
maxn = floor(norm(size(BW)));
npeaks_peak = zeros(1, maxn);
for i = 1:maxn
    npeaks_peak(i) = length(houghpeaks(H, i));
end
npeaks = min(find(max(npeaks_peak) == npeaks_peak));
P = houghpeaks(H, npeaks);
lines = showHoughLines(BW, theta, rho, P);

%% Get Lines onto Image
figure; imshow(I_P);
hold on;
for i = 1:length(lines)
    xy = [lines(i).point1; lines(i).point2];
    L = line(xy(:,1),xy(:,2), 'Color', 'white', 'LineWidth', 2);
end
F = getframe;
X = F.cdata;
X = X(1:512, 1:512, :);

%% Combine Images
I1 = I_P;
I2 = IR(1:512,1:512);
I3 = X;
COMBINED = 5*double(I1)/27 + 9*double(I2)/27 + 13*double(I3)/27;
COMBINED_IMG = uint8(255.*normalize(COMBINED, 'range'));
figure; imshow(COMBINED_IMG);
