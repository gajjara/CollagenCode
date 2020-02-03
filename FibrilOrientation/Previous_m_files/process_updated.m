function OUTPUT = process_updated(PATH)
%% Read Image
I = imread(PATH);
I = I(:,:,1); %Greyscale
%I = single(I(:,:));

%% Normalize MATLAB
I = histeq(I);
normval = 255;
norm = normval.*normalize(double(I), 'range');
I = uint8(norm);
%figure; imshow(I);

%% Threshold
OUTPUT = Threshold(I, 254);
%OUTPUT = I;
end