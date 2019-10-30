function [] = removeTxtAOS2(year)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here


mainDir = ['X:\S2_AOUnFMatlabData_S2',filesep,num2str(year)];


dateDirFs = getDirFolders(mainDir);

for ddi = 1:length(dateDirFs)
    
    tmpDateD = [mainDir, filesep, dateDirFs{ddi}];
    
    outTxtNames = getTxtNames(tmpDateD);
    
    if isempty(outTxtNames)
        disp('Files have already been removed!')
        continue
    else
        cd(tmpDateD)
        
        for di = 1:length(outTxtNames)
            delTmp = outTxtNames{di};
            delete(delTmp)
        end
        
    end
    
end

end






function [outTxtNames] = getTxtNames(mainDir)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

cd(mainDir)
getCons = dir('*.txt');
outTxtNames = {getCons.name};


end