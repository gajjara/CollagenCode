% houghtry2
[H, theta, rho] = hough(BW);
maxn = floor(norm(size(BW)));

npeaks_peak = zeros(1, maxn);
for i = 1:maxn
    npeaks_peak(i) = length(houghpeaks(H, i));
end
npeaks = min(find(max(npeaks_peak) == npeaks_peak));
P = houghpeaks(H, npeaks);

showHoughLines(BW, theta, rho, P);

