PROCESSED = ...
    imread('/Users/Anuj/Desktop/Current_Work/OSL_NEU/MonomerImageProcessing/Outputs/OutMAT1.png');
[R, Xp] = radon(PROCESSED);

%% PROCESS TRY 1
iR = iradon(R, 1:size(RADON,2), 'linear', 'none');
iR_img = uint8(255.*normalize(iR, 'range'));
HIST = getHistogram(iR_img);

figure; imshow(iR_img);
figure; plot(HIST);

dy = diff(HIST);
max_index = (find(dy == max(dy))) - 1;

BW = im2bw(iR_img, (max_index/255));
figure; imshow(BW);

%% Process Relative Idea
R2 = R.*(R>10000);
test = iradon(R2, 0:179, 'linear', 'none');
figure; imagesc(test); colorbar;
figure; imshow(uint8(255.*normalize(test, 'range')));

%% Process TRY 2
figure; imagesc(0:179, Xp, R); C = colorbar;
Lim = C.Limits; Lim = Lim(2);
Thres = Lim/2;
R1 = R.*(R>Thres);
test = iradon(R1, 0:179, 'linear', 'none');
figure; imagesc(test); colorbar;

%% Hough and Radon Try
