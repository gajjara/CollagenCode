function [H, theta, rho, P, lines] = HoughAll(BW);
[H, theta, rho] = hough(BW);

figure; imshow(imadjust(rescale(H)), [], ...
    'Xdata', theta, ...
    'Ydata', rho, ...
    'InitialMagnification', 'fit');
xlabel('\theta (degrees)'); 
ylabel('\rho');
axis on; axis normal; hold on; C = colormap(gca,hot);

npeaks = size(find(1 == C), 10);
P = houghpeaks(H, npeaks);
lines = houghlines(BW, theta, rho, P);
showHoughLines(BW, lines);
end

