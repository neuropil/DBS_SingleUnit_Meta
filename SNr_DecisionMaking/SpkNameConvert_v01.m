function [output] = SpkNameConvert_v01(spkRawInfo)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

rawSpkDirAll = 'Y:\PreProcessEphysData\';

cd(rawSpkDirAll)

% Modify date name
oldDate = spkRawInfo.date;
newDate = [oldDate(1:2),'_',oldDate(3:4),'_',oldDate(5:8)];

surgNum = str2double(spkRawInfo.surgery);  
setNum = str2double(spkRawInfo.set);  

% Create name alternatives based on surgery number and set
if surgNum == 1 && setNum == 1;
    output.file{1} = strcat(rawSpkDirAll,newDate);
    output.file{2} = strcat(rawSpkDirAll,newDate,'\Set1');
    output.file{3} = strcat(rawSpkDirAll,newDate,'_1');
    output.file{4} = strcat(rawSpkDirAll,newDate,'_1\Set1');
    
    fileCode(1) = exist(output.file{1},'dir');
    fileCode(2) = exist(output.file{2},'dir');
    fileCode(3) = exist(output.file{3},'dir');
    fileCode(4) = exist(output.file{4},'dir');
    
    fileCode = fileCode ~= 0;
    
    if isequal(find(fileCode),[3,4])
        output.CDir = output.file{4};
    elseif isequal(find(fileCode),[1,2])
        output.CDir = output.file{2};
    else
        output.CDir = output.file{find(fileCode == 7 | fileCode == 1)};
    end
    
elseif surgNum == 2 && setNum == 1;
    output.file{1} = strcat(rawSpkDirAll,newDate,'_2');
    output.file{2} = strcat(rawSpkDirAll,newDate,'_2\Set1');
    
    fileCode(1) = exist(output.file{1},'dir');
    fileCode(2) = exist(output.file{2},'dir');
    
    if sum(fileCode) == 2
        output.CDir = output.file{2};
    else
        output.CDir = output.file{find(fileCode == 7 | fileCode == 1)};
    end

elseif surgNum == 1 && setNum == 2;
    output.file{1} = strcat(rawSpkDirAll,newDate,'\Set2');
    output.file{2} = strcat(rawSpkDirAll,newDate,'_1\Set2');
    
    fileCode(1) = exist(output.file{1},'dir');
    fileCode(2) = exist(output.file{2},'dir');

    output.CDir = output.file{find(fileCode == 7 | fileCode == 1)};

end

% Create name alternatives based on set

% Get depth number
dep = spkRawInfo.depth;
relTar = spkRawInfo.relTarg;

if strcmp(relTar,'a')
    output.fName = strcat('AbvTrgt_',spkRawInfo.relTargVal,'_',dep,'.mat');
else
    output.fName = strcat('BlwTrgt_',spkRawInfo.relTargVal,'_',dep,'.mat');
end




end

