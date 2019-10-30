function [] = resetS3_S4_crash(year , surgDATE)
%THIS function will reset a failed transfer to S4
% 1. Deletes WHOLE FOLDER from date from year in S4
% 2. Deletes ONLY FILES from date from year in S3
% 3. RE-COPIES raw files from S2 to S3

dsh = filesep;

S2_dir = ['X:\S2_AOUnFMatlabData_S2',dsh,num2str(year),dsh,surgDATE];
S3_dir = ['X:\S3_AO_MatlabData_S3',dsh,num2str(year),dsh,surgDATE];
S4_dir = ['X:\S4_AO_ProcMatlabData_S4',dsh,num2str(year),dsh,surgDATE];

% # 1 DELETE WHOLE FOLDER from S4
[status, ~, ~] = rmdir(S4_dir, 's');
if status
    disp('File S4 removed!')
    disp('STEP 1 DONE!')
else
    disp('ERROR')
end

% # 2 DELETE FILES from S3
cd(S3_dir)
s3MatNs = getMatNames(S3_dir);
for s3i = 1:length(s3MatNs)
    
    s3DtmpN = s3MatNs{s3i};
    s3DtmpD = [S3_dir , dsh , s3DtmpN];
    delete(s3DtmpD);
    
    if exist('RMd_files.txt','file')
        delete('RMd_files.txt')
    end
    
    if exist('ttlDONE.txt','file')
        delete('ttlDONE.txt')
    end
    
end
disp('STEP 2 DONE!')



% # 3
cd(S2_dir)
s2MatNs = getMatNames(S2_dir);

for s23i = 1:length(s2MatNs)
    
    s2tmp = s2MatNs{s23i};
    s2tmpD = [S2_dir , dsh , s2tmp];
    s3tmpD = [S3_dir , dsh , s2tmp];
    
    copyfile(s2tmpD , s3tmpD);
    
end
disp('STEP 3 DONE!')

end





function [outMatNames] = getMatNames(mainDir)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

cd(mainDir)
getCons = dir('*.mat');
outMatNames = {getCons.name};


end