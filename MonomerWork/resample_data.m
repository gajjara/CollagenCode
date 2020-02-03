%% TRAPNI Trapezoidal numerical integration of y over x
%
%  SYNTAX
%  resampled_data = resample(y, xi, xf);
%
%  y is the data to be resampled, xi is the variable y is with respect to,
%  xf is the
%
%  resampled_data is the resampled data of y dx from x(1) to x(end).
%  x need not be regularly spaced.
%
function resample_data=resample_data(y, xi, xf)
resample_data = zeros(size(xf));
test = find((xi(2)<xf)&(xi(end-1)>xf));
resample_data(test) = linterp(xi,y,xf(test));
