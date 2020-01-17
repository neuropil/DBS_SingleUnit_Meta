function [] = postAOCleanUp(study,year,surgDATE)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

dsh = filesep;

cur_Dir = ['W:\S4_AO_ProcMatlabData_S4',dsh,num2str(year),dsh,surgDATE];

switch study
    case 'AT-IO'
        % Keep only 2 EMG and 1 Accelerometer
        % Keep MER mLFP and LFP
        % Keep TTL
        
        % # 2 DELETE FILES from S3
        cd(cur_Dir)
        ckSet = checkSets(cur_Dir);
        
        % Loop through cases
        % Use Matfile to find relevant files
        % Load file
        % Find present files
        % Overwrite and Save
        % Use Matfile to clear file variables
        
        
    case 'ET-DK'
        % Keep only 7 EMG and 1 Accelerometer
        % Keep MER mLFP and LFP
        % Keep TTL
        
        cd(cur_Dir)
        ckSet = checkSets(cur_Dir);
        
        
        if ckSet
            setMatDir = getDirFolders(cur_Dir);
            for setI = 1:length(setMatDir)
                tmpSET = [];
                
                
            end
        else
            satList = getMatNames(curDIR);
            
        end
        
        
end








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