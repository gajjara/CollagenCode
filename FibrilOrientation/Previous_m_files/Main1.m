
for i = 1:121
    str1 = "/Users/Anuj/Desktop/Current_Work/OSL_NEU/MonomerImageProcessing/Outputs/OutJava";
    str2 = string(i);
    str3 = ".png";
    strall = strcat(str1, str2, str3);
    
    str4 = "/Users/Anuj/Desktop/Current_Work/OSL_NEU/MonomerImageProcessing/Outputs/OutMAT";
    strall1 = strcat(str4, str2, str3);
    
    imwrite(Process(strall), strall1);
    
    disp(i);
    
    clear str1 str2 str3 strall str4 strall1
end
clear i;