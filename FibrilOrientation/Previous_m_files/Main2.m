for i = 1:121
    str1 = "/Users/Anuj/Desktop/Current_Work/OSL_NEU/MonomerImageProcessing/Outputs/OutRADON";
    str2 = string(i);
    str3 = ".png";
    strall = strcat(str1, str2, str3);
    
    str4 = "/Users/Anuj/Desktop/Current_Work/OSL_NEU/MonomerImageProcessing/Outputs/OutMAT";
    strall1 = strcat(str4, str2, str3);
    PROCESSED = imread(strall1);
    R = radon(PROCESSED);
    iR = iradon(R, 1:size(RADON,2), 'linear', 'none');
    iR_img = uint8(255.*normalize(iR, 'range'));
    HIST = getHistogram(iR_img);
    dy = diff(HIST);
    max_index = (find(dy == max(dy))) - 1;
    BW = im2bw(iR_img, (max_index/255));
    BW = uint8(255.*normalize(double(BW)));
    
    imwrite(BW, strall);
    disp(i);
    
    clear str1 str2 str3 strall str4 strall1 PROCESSED R iR iR_img HIST dy max_index BW
end
clear i;