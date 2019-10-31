function [] = initializeS2_S3(year)
% COPY raw s2 files over to s3
% COPY NOAO and lfp file over to s3
% CHECKS
% 1. IF S3 does not exist MOVE S3 over
% 2. IF S3 exists skip


dsh = filesep;

S2_dir = ['X:\S2_AOUnFMatlabData_S2',dsh,num2str(year)];
S3_dir = ['X:\S3_AO_MatlabData_S3',dsh,num2str(year)];

% Get S2 DIR list
s2FoldNs = getDirFolders(S2_dir);
if ~exist(S3_dir,'dir')
    mkdir(S3_dir)
    s3FoldNs = getDirFolders(S3_dir);
else
    s3FoldNs = getDirFolders(S3_dir);
end

for s2i = 1:length(s2FoldNs)
    tmpS2dir = s2FoldNs{s2i};
    
    if ismember(tmpS2dir,s3FoldNs)
        continue
    else
        % Make S3 directory
        newS3dirD = [S3_dir , dsh , tmpS2dir];
        mkdir(newS3dirD);
        % Transfer txt and mat files by set
        % 1. Loop through Sets
        curDIR = [S2_dir , dsh , tmpS2dir];
        ckSet = checkSets(curDIR);
        
        if ckSet
            % get set folders
            setFolds = getDirFolders(curDIR);
            for setI = 1:length(setFolds)
                tmpSEt = [curDIR , dsh , setFolds{setI}];
                newS3dirS = [newS3dirD , dsh , setFolds{setI}];
                mkdir(newS3dirS)
                s2matS = getMatNames(tmpSEt);
                for mmi = 1:length(s2matS)
                    
                    sourcF = [tmpSEt , dsh , s2matS{mmi}];
                    destF = [newS3dirS , dsh , s2matS{mmi}];
                    copyfile(sourcF , destF);
                    
                end
            end
        else
            s2matS = getMatNames(curDIR);
            for mmi = 1:length(s2matS)
                
                sourcF = [curDIR , dsh , s2matS{mmi}];
                destF = [newS3dirD , dsh , s2matS{mmi}];
                copyfile(sourcF , destF);
                
            end
        end
    end
end


end % END OF FUNCTION




function checkSet = checkSets(DIRloc)


[outMatNames] = getMatNames(DIRloc);

if isempty(outMatNames)
    checkSet = 1;
else
    checkSet = 0;
end



end



function [outMatNames] = getMatNames(mainDir)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

cd(mainDir)
getCons = [dir('*.mat'); dir('*.txt')];
outMatNames = {getCons.name};


end


