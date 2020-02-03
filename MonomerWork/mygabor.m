function angle = mygabor(Iregion,wavelength)
%MYGABOR - Summary

orientations = [-90:15:90];
g = gabor(wavelength, orientations);
outMag = imgaborfilt(Iregion, g);

where = max(outMag, [], 3) == outMag;
avgs = mean(where, [1 2]);
temp = (find(max(avgs) == avgs));
angle = orientations(temp);

figure;
subplot(2,1,1); imagesc(outMag(:,:,temp).*double(Iregion)); title("OutMag");
subplot(2,1,2); imagesc(Iregion); title(string(angle));


end