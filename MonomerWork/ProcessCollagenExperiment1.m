folderpath = '/Users/Anuj/Desktop/CollagenExperiments_Tiff_Images/';
format = '.tif';
camera1 = ' (Andor)';
camera2 = ' (Coolsnap)';
noLUTs = '';
LUTs = ' (LUTs)';
ending = 'C1';

% Store filepaths and values for each image in array
filepaths = cell(24, 1);
mins = zeros(24,1);
maxs = zeros(24,1);
means = zeros(24, 1);
variances = zeros(24, 1);
stddeviations = zeros(24, 1);
pixelsizesx = zeros(24,1);
pixelsizesy = zeros(24,1);
datatypes = cell(24, 1);

% Counter indicating array positions
counter_arrays = 1;
% Counter for experiment number
counter_expn = 1;

% Read all files and calculate values for it
tobreak = false;
while(tobreak == false)
    expn = strcat('Exp', string(counter_expn)); 
    for i = 1:2 % Andor or Coolsnap
        if(i == 1) % Andor Image
            for j = 1:2 % LUTs or Not
                if(j == 1) % No LUTs
                    % Generate filepath
                    filepath = strcat(...
                        folderpath, expn, camera1, noLUTs, ending, format);
                    
                    % Read and process image
                    try
                        I = imread(filepath);
                        Idbl = double(I);
                        
                        filepaths{counter_arrays} = filepath;
                        mins(counter_arrays) = min(Idbl, [], 'all');
                        maxs(counter_arrays) = max(Idbl, [], 'all');
                        means(counter_arrays) = mean(mean(Idbl));
                        variances(counter_arrays) = ...
                            var(Idbl, 1, 'all', 'omitnan');
                        stddeviations(counter_arrays) = ...
                            std(Idbl, 1, 'all', 'omitnan');
                        pixelsizesx(counter_arrays) = size(I, 1);
                        pixelsizesy(counter_arrays) = size(I, 2);
                        datatypes{counter_arrays} = string(class(I));
                        
                        disp(filepath);
                    catch E % Break while loop if error occurs
                       tobreak = true;
                       %disp(E);
                       break
                    end
                    
                    % Update counter
                    counter_arrays = counter_arrays + 1;
                elseif(j == 2) % LUTs
                    % Generate filepath
                    filepath = strcat(...
                        folderpath, expn, camera1, LUTs, ending, format);
                    
                    % Read image
                    try
                        I = imread(filepath);
                        Idbl = double(I);
                        
                        filepaths{counter_arrays} = filepath;
                        mins(counter_arrays) = min(Idbl, [], 'all');
                        maxs(counter_arrays) = max(Idbl, [], 'all');
                        means(counter_arrays) = mean(mean(Idbl));
                        variances(counter_arrays) = ...
                            var(Idbl, 1, 'all', 'omitnan');
                        stddeviations(counter_arrays) = ...
                            std(Idbl, 1, 'all', 'omitnan');
                        pixelsizesx(counter_arrays) = size(I, 1);
                        pixelsizesy(counter_arrays) = size(I, 2);
                        datatypes{counter_arrays} = string(class(I));
                        
                        disp(filepath);
                    catch E % Break while loop if error occurs
                       tobreak = true;
                       %disp(E);
                       break
                    end
                    
                    % Update counter
                    counter_arrays = counter_arrays + 1;
                end
            end
        elseif(i == 2) % Coolsnap Image
            for j = 1:2 % LUTs or Not
                if(j == 1) % No LUTs
                    % Generate filepath
                    filepath = strcat(...
                        folderpath, expn, camera2, noLUTs, ending, format);
                    
                    % Read Image
                    try
                        I = imread(filepath);
                        Idbl = double(I);
                        
                        filepaths{counter_arrays} = filepath;
                        mins(counter_arrays) = min(Idbl, [], 'all');
                        maxs(counter_arrays) = max(Idbl, [], 'all');
                        means(counter_arrays) = mean(mean(Idbl));
                        variances(counter_arrays) = ...
                            var(Idbl, 1, 'all', 'omitnan');
                        stddeviations(counter_arrays) = ...
                            std(Idbl, 1, 'all', 'omitnan');
                        pixelsizesx(counter_arrays) = size(I, 1);
                        pixelsizesy(counter_arrays) = size(I, 2);
                        datatypes{counter_arrays} = string(class(I));
                        
                        disp(filepath);
                    catch E % Break while loop if error occurs
                       tobreak = true;
                       %disp(E);
                       break
                    end
                    
                    % Update counter
                    counter_arrays = counter_arrays + 1;
                elseif(j == 2) % LUTs
                    % Generate filepath
                    filepath = strcat(...
                        folderpath, expn, camera2, LUTs, ending, format);
                    
                    % Read image
                    try 
                        I = imread(filepath);
                        Idbl = double(I);
                        
                        filepaths{counter_arrays} = filepath;
                        mins(counter_arrays) = min(Idbl, [], 'all');
                        maxs(counter_arrays) = max(Idbl, [], 'all');
                        means(counter_arrays) = mean(mean(Idbl));
                        variances(counter_arrays) = ...
                            var(Idbl, 1, 'all', 'omitnan');
                        stddeviations(counter_arrays) = ...
                            std(Idbl, 1, 'all', 'omitnan');
                        pixelsizesx(counter_arrays) = size(I, 1);
                        pixelsizesy(counter_arrays) = size(I, 2);
                        datatypes{counter_arrays} = string(class(I));
                        
                        disp(filepath);
                    catch E % Break while loop if error occurs
                        tobreak = true;
                        %disp(E);
                        break
                    end
                    
                    % Update counter
                    counter_arrays = counter_arrays + 1;
                end
            end
        end
        if(tobreak == true)
            break
        end
    end
    if(tobreak == true)
        break
    end
    counter_expn = counter_expn + 1;
end

% Make table for data
T = table(filepaths, mins, maxs, means, variances, stddeviations, ...
    pixelsizesx, pixelsizesy, datatypes, ...
    'VariableNames',{'Filepath','Min', 'Max', 'Mean', 'Variance', ...
    'Standard_Deviation','Pixel_Size_X','Pixel_Size_Y','DataType'});

writetable(T, ...
    '/Users/Anuj/Documents/MATLAB/Lab_NEU/CollagenExperiments1Data.csv', ...
    'FileType', 'text', 'Delimiter', '|');
