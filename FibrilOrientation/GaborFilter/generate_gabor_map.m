function map = generate_gabor_map(filter,x,l)
%GENERATE_GABOR_MAP Summary of this function goes here
%   Detailed explanation goes here
middle = int8(l/2 + 1);
gabor = [];
gabor(2,:) = filter;
gabor(1,:) = x;
gabor = round(gabor);

map = zeros(size(gabor,2), size(gabor,2));

for i = 1:size(gabor,2)
    temp = gabor(2,i) + middle;
    if(temp > 0)
         map((gabor(1,i) + middle), temp) = 1;
    end
end

end

