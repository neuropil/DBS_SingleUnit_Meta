function [] = removeTxtAOS2(year , driveLetter)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

mainDir = [driveLetter,'\S2_AOUnFMatlabData_S2',filesep,num2str(year)];

dateDirFs = getDirFolders(mainDir);

dsh = filesep;

for ddi = 1:length(dateDirFs)
    
    tmpDateD = [mainDir, filesep, dateDirFs{ddi}];
    
    ckSet = checkSets(tmpDateD);
    
    if ckSet
        
        setFolds2 = getDirFolders(tmpDateD);
        for setI = 1:length(setFolds2)
            tmpSet = [tmpDateD , dsh , setFolds2{setI}];
            delTxt(tmpSet)
        end
        
    else
        delTxt(tmpDateD)
        
    end
    
    
end

end





%%%% GETTEXTNAMES FUNCTION
function [outTxtNames] = getTxtNames(mainDir)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
cd(mainDir)
getCons = dir('*.txt');
outTxtNames = {getCons.name};

end


%%%% GETMATNAMES FUNCTION
function [outMatNames] = getMatNames(mainDir,matflag)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

cd(mainDir)

if matflag
    getCons = dir('*.mat');
else
    getCons = [dir('*.mat'); dir('*.txt')];
end

outMatNames = {getCons.name};

end


%%%% CHECKSETS FUNCTION
function checkSet = checkSets(DIRloc)

[outMatNames] = getMatNames(DIRloc,1);

if isempty(outMatNames)
    checkSet = 1;
else
    checkSet = 0;
end

end


%%%% DELTEXT FUNCTION
function [] = delTxt(tmpDIR)

    outTxtNames = getTxtNames(tmpDIR);
    outTxtNames = outTxtNames(~ismember(outTxtNames,{'lfp_yes.txt','NOAO.txt'}));
    
    if isempty(outTxtNames)
        disp('Files have already been removed!')
        return
    else
        cd(tmpDIR)
        
        for di = 1:length(outTxtNames)
            delTmp = outTxtNames{di};
            delete(delTmp)
        end
        
    end

end