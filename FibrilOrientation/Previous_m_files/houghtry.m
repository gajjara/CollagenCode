%video = VideoWriter('/Users/Anuj/Desktop/hough_try.mp4');
%open(video);

BW = imread( ...
    '/Users/Anuj/Desktop/Current_Work/OSL_NEU/MonomerImageProcessing/Outputs/OutMAT1.png');
for i = 1:floor(norm(size(BW)))
[H, theta, rho] = hough(BW, 'RhoResolution', i);

%for i=1:floor(norm(size(BW)))
    P = houghpeaks(H, floor(norm(size(BW))));
    lines = houghlines(BW, theta, rho, P);
    
    slines(i) = size(lines, 2);
    disp(i);
    figure(1), imshow(BW), hold on, title(i);
    
    max_len = 0; for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
        
        % Plot beginnings and ends of lines
        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
        
        % Determine the endpoints of the longest line segment len =
        len = norm(lines(k).point1 - lines(k).point2); if ( len > max_len)
            max_len = len; xy_long = xy;
        end
    end % highlight the longest line segment
    plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');
    
    %F = getframe(gcf);
    %[X, MAP] = frame2im(F);

    %writeVideo(video, X);
end

%close(video);