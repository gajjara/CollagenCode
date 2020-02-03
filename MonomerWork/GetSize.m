function GetSize(obj)
    props = properties(obj);
    size = 0;
    
    for i = 1:length(props)
        currentProperty = getfield(obj, char(props(i)));
        s = whos('currentProperty');
        size = size + s.bytes;
    end
    
    fprintf('Size of inputted object is: ');
    fprintf('%d', size);
    fprintf(' Bytes\n');
    

end