function [] = resetS3_S4_crash(year , surgDATE , driveLetter)
%THIS function will reset a failed transfer to S4
% 1. Deletes WHOLE FOLDER from date from year in S4
% 2. Deletes ONLY FILES from date from year in S3
% 3. RE-COPIES raw files from S2 to S3
% DEAL WITH SETS!!!!!!!!!!!!!!!!!!!!!! STEP 3

dsh = filesep;

S2_dir = [driveLetter,'\S2_AOUnFMatlabData_S2',dsh,num2str(year),dsh,surgDATE];
S3_dir = [driveLetter,'\S3_AO_MatlabData_S3',dsh,num2str(year),dsh,surgDATE];
S4_dir = [driveLetter,'\S4_AO_ProcMatlabData_S4',dsh,num2str(year),dsh,surgDATE];

% # 1 DELETE WHOLE FOLDER from S4
if exist(S4_dir,'dir')
    [status, ~, ~] = rmdir(S4_dir, 's');
    if status
        disp('File S4 removed!')
        disp('STEP 1 DONE!')
    else
        disp('ERROR')
    end
end

% # 2 DELETE FILES from S3
cd(S3_dir)

ckSet = checkSets(S3_dir);

if ckSet
    setFolds = getDirFolders(S3_dir);
    for setI = 1:length(setFolds)
        tmpSEt = [S3_dir , dsh , setFolds{setI}];
        s3MatNs = getMatNames(tmpSEt,1);
        for s3i = 1:length(s3MatNs)
            s3DtmpN = s3MatNs{s3i};
            s3DtmpD = [tmpSEt , dsh , s3DtmpN];
            delete(s3DtmpD);
        end
        if exist('RMd_files.txt','file')
            delete('RMd_files.txt')
        end
        
        if exist('ttlDONE.txt','file')
            delete('ttlDONE.txt')
        end
    end
else
    s3MatNs = getMatNames(S3_dir,1);
    for s3i = 1:length(s3MatNs)
        s3DtmpN = s3MatNs{s3i};
        s3DtmpD = [S3_dir , dsh , s3DtmpN];
        delete(s3DtmpD);
    end
    if exist('RMd_files.txt','file')
        delete('RMd_files.txt')
    end
    
    if exist('ttlDONE.txt','file')
        delete('ttlDONE.txt')
    end
    
end
disp('STEP 2 DONE!')



% # 3 #####################################################################
% RE-COPIES raw files from S2 to S3
cd(S2_dir)

ckSet2 = checkSets(S2_dir);

if ckSet2
    setFolds2 = getDirFolders(S2_dir);
    for setI = 1:length(setFolds2)
        Sdir2_tmp = [S2_dir , dsh , setFolds2{setI}];
        Sdir3_tmp = [S3_dir , dsh , setFolds2{setI}];
        s2MatNs = getMatNames(Sdir2_tmp,0);
        for s23i = 1:length(s2MatNs)
            
            s2tmp = s2MatNs{s23i};
            s2tmpD = [Sdir2_tmp , dsh , s2tmp];
            s3tmpD = [Sdir3_tmp , dsh , s2tmp];
            
            copyfile(s2tmpD , s3tmpD);
        end
        
    end
else
    
    s2MatNs = getMatNames(S2_dir);
    for s23i = 1:length(s2MatNs)
        
        s2tmp = s2MatNs{s23i};
        s2tmpD = [S2_dir , dsh , s2tmp];
        s3tmpD = [S3_dir , dsh , s2tmp];
        
        copyfile(s2tmpD , s3tmpD);
        
    end
    
end
disp('STEP 3 DONE!')





end





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



function checkSet = checkSets(DIRloc)


[outMatNames] = getMatNames(DIRloc,1);

if isempty(outMatNames)
    checkSet = 1;
else
    checkSet = 0;
end



end