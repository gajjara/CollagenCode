function [gaborfilters, x] = generate_gabor_filters(l,coefficents)
%GENERATE_GABOR_FILTERS Summary of this function goes here
%   Detailed explanation goes here

x = -round(l/2):1:round(l/2);
gaborfilters = zeros(length(coefficents), length(x));
alpha = 0:90;

counter = 1;
for c = coefficents
    for a = alpha
        gaborfilters(counter,:) = (-(x./c).^2)*cos(a*pi/180);
        counter = counter + 1;
    end
end
end