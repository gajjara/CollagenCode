function phantom_img = generate_fibril_phantom()
    I = imread('/Users/Anuj/Desktop/Fibril_Phantom_Noiseless.png');
    if(isequal(I(:,:,1), I(:,:,2), I(:,:,3)))
        I = I(:,:,1);
    end
    J = imnoise(I, 'gaussian', 0.7);
    H = imnoise(J, 'poisson');
    K = imnoise(H, 'speckle');
    L = imnoise(K, 'salt & pepper');
    phantom_img = L;
end