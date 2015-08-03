function [ ] = DeleteNonSpikeExprFiles(expType)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


if expType 
    expFold = 'E:\DBS_Spike_Analysis_Plenary\P50_Data\RawNeurophysiology\';
    cd(expFold)
else
    expFold = 'E:\DBS_Spike_Analysis_Plenary\SNr_EyeTrack\RawNeurophysiology\';
    cd(expFold)
end

% Get folder list
rawFold1 = dir;
rawFold1 = rawFold1(3,end);
rawFoldNa = {rawFold1.name};

for rfi = 1:length(rawFoldNa)
    
    % CD to each folder
    tempFold = rawFoldNa{rfi};
    tempDir = strcat(expFold,tempFold);
    cd(tempDir)
    
    [checkFlag] = checkDone(tempDir);
    
    if checkFlag
        continue
    end
    
    % Get file list of depths
    rawList1 = dir('*.mat');
    rawListNa = {rawList1.name};
    
    % Determine which files to delete
    for rli = 1:length(rawListNa)
        
        tempFname = rawListNa{rli};
%         load(tempFname)
        
        tTLMatobj = matfile(tempFname);
        tTLMatinfo = whos(tTLMatobj);
        tTLNames = {tTLMatinfo.name};
        
        % Check for TTL file names
        ttlCheck = cellfun(@(x) ~isempty(strfind(x,'C1_DI00')), tTLNames);
        
        if any(ttlCheck)
            continue
        else
           delete(tempFname) 
        end

    end
    
    save('Done.txt')
    
end


end % End of main function


function [checkFlag] = checkDone(fileLoc)

cd(fileLoc);

fileListtxt = dir('*.txt');

fileCheck = {fileListtxt.name};


if isempty(fileCheck)
    checkFlag = 0;
else
    checkFlag = 1;
end






end

