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
s3FoldNs = getDirFolders(S3_dir);

for s2i = 1:length(s2FoldNs)
    tmpS2dir = s2FoldNs{s2i};
    
    if ismember(tmpS2dir,s3FoldNs)
        continue
    else
        % Make S3 directory
        mkdir([S3_dir , dsh , tmpS2dir]);
        % Transfer txt and mat files by set
        % 1. Loop through Sets
        ckSet = checkSets([S2_dir , dsh , tmpS2dir]);
        
        if ckSet
            
            
        else
            
            
        end
    end
end


end % END OF FUNCTION




function checkSet = checkSets(DIRloc)


 = getDirFolders(DIRloc);





end



