%%
I = imread('/Users/Anuj/Desktop/OSL_NEU/MonomerOrientation/GT_Finaldata_tiff/Dialution3_015_0LUTsT1C1.tif');

%% Region
Iregion1 = I(274:282, 1039:1049);
Iregion2 = I(477:485, 696:708);
Iregion3 = I(444:454,400:410);

%% Gabor Attempt
wavelength = 6;
orientation = mygabor(Iregion3, wavelecngth);