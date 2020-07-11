function [] = preSetAOC_folds(year , driveLetter)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


name = getenv('COMPUTERNAME');


if strcmp(name,'DESKTOP-95LU6PO')
    s1DIR = [driveLetter,'\RAWDBSmer\S1_AORawData_S1',filesep,num2str(year)];
    s2DIR = [driveLetter,'\RAWDBSmer\S2_AOUnFMatlabData_S2',filesep,num2str(year)];
else
    s1DIR = [driveLetter,'\S1_AORawData_S1',filesep,num2str(year)];
    s2DIR = [driveLetter,'\S2_AOUnFMatlabData_S2',filesep,num2str(year)];
end

s1dirFds = getDirFolders(s1DIR);
s2dirFds = getDirFolders(s2DIR);

createList = s1dirFds(~ismember(s1dirFds,s2dirFds));

for ci = 1:length(createList)
 
    tmpCN = createList{ci};
    tmpND = [s2DIR , filesep , tmpCN];
    if ~exist(tmpND, 'dir')
        mkdir(tmpND)
    end

end

end

