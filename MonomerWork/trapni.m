%% TRAPNI Trapezoidal numerical integration of y over x
%
%  SUNTAX
%  integral=trapni(y,x);
%
%  y is the integrand, x is the variable of integration
%
%  integral is the integral of y dx from x(1) to x(end).
%  x need not be regularly spaced.
%
% by Chuck DiMarzio
%    Northeastestern University 
%    March 2010
%
%
%  !! This file may be copied, used, or modified for educational and
%  !! research purposes provided that this header information is not
%  !! removed or altered, and provided that the book is cited in 
%  !! publications, as DiMarzio, Charles A., Optics for Engineers, 
%  !! CRC Press, Boca Raton, FL, 2011.
%  !! http://www.crcpress.com
%  !! Other distribution is prohibited without permission.
%
%
function trapni=trapni(y,x)
trapni=(-sum(y(1:end-1).*x(1:end-1))...
        -sum(y(2:end).*x(1:end-1))...
        +sum(y(1:end-1).*x(2:end))...
        +sum(y(2:end).*x(2:end)))/2;
