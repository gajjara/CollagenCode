%%
I = imread('/Users/Anuj/Desktop/OSL_NEU/FibrilOrientation/FibrilJava.png');


%% Calculate Maps

l = 10; % pixels (will adjust for real size)
coefficents = 5:0.1:10;
[gaborbois,x] = generate_gabor_filters(l,coefficents);

%% Generate Maps
counter = 1;

maps = zeros(4*size(gaborbois,1), (l + 1), (l + 1));
for k = 1:size(gaborbois,1)
    maps(counter, :, :) = generate_gabor_map(gaborbois(k,:), x,l);
    counter = counter + 1;
    maps(counter, :, :) = generate_gabor_map(-gaborbois(k,:), x, l);
    counter = counter + 1;
    maps(counter, :, :) = generate_gabor_map(x, gaborbois(k,:), l);
    counter = counter + 1;
    maps(counter, :, :) = generate_gabor_map(x, -gaborbois(k,:), l);
    counter = counter + 1;
end

%% Show Maps
for i = 1:size(maps, 1)
    figure(1); imagesc(reshape(maps(i,:,:), size(maps(i,:,:), 2), [])');
    title(string(i));
end

%% Apply Maps
region = [(l + 1) (l + 1)];
mapping = [];


%% Gabor using internal MATLAB func

for i = 2:50
    gaborArray = gabor(i, 0:90);
    gaborMag = imgaborfilt(I, gaborArray);
    for j = 1:size(gaborMag, 3)
        s = s + gaborMag(:,:,i);
    end
    figure(1); imagesc(s.*double(I)); title(string(i));
end
