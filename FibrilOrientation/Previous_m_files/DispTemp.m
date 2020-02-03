if(1)
    for i=1:256
       fprintf(strcat(string(i), '\t'));
    end
    fprintf('\n');
    
    for i=1:256
        fprintf(strcat(string(HIST(i)), '\t'));
    end
    fprintf('\n');
    
    for i=1:256
        fprintf(strcat(string(CDF(i)), '\t'));
    end
    fprintf('\n');
    
    for i=1:256
        fprintf(strcat(string(NORMFUNC(i)), '\t'));
    end
    fprintf('\n');
end