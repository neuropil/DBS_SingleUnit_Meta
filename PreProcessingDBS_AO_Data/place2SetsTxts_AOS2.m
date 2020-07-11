function [] = place2SetsTxts_AOS2(year , driveLetter)
%place2SetsTxts_AOS2
% Configure set folders and ADD text files NOAO and lfp_yes

removeTxtAOS2(year , driveLetter)

name = getenv('COMPUTERNAME');

if strcmp(name,'DESKTOP-95LU6PO')
    mainDir = [driveLetter,'\RAWDBSmer\S2_AOUnFMatlabData_S2',filesep,num2str(year)];
else
    mainDir = [driveLetter,'\S2_AOUnFMatlabData_S2',filesep,num2str(year)];
end

dateDirFs = getDirFolders(mainDir);


% CD to year
% Loop through dates
% If L or R
% ADD NOAO and lfp_yes
% If greater than 1 then create Set folders


for ddi = 1:length(dateDirFs)
    
    tmpDateD = [mainDir, filesep, dateDirFs{ddi}];
    
    ckSet = checkSets(tmpDateD);
    outMatNames = getMatNames(tmpDateD,1);
    
    if ckSet
        continue
    else
        setNUMS = unique(cellfun(@(x) str2double(x(3)), outMatNames));
        numSETS = numel(setNUMS);
        
        
        if numSETS == 1
            if year >= 2017
                save('lfp_yes.txt')
                save('NOAO.txt')
            end
            continue
        else
            % Create SETS and add TXTS
            for ssi = 1:numSETS
                
                setNid = setNUMS(ssi);
                
                newSetdir = [tmpDateD , filesep , 'Set' , num2str(setNid)];
                if ~exist(newSetdir,'dir')
                    mkdir(newSetdir)
                end
                
                curSetlist = getSetList(outMatNames,setNid);
                
                for ci = 1:length(curSetlist)

                    sourc = [tmpDateD , filesep , curSetlist{ci}];
                    dest = [newSetdir , filesep , curSetlist{ci}];
                    movefile(sourc,dest)

                end
                
                if year >= 2017
                    lfpTxt = [newSetdir , filesep , 'lfp_yes.txt'];
                    NOAOTxt = [newSetdir , filesep , 'NOAO.txt'];
                    save(lfpTxt)
                    save(NOAOTxt)
                end
            end
        end
    end
end






end % End of function










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




function [curLIST] = getSetList(MatNames,setNum)

setNumList = cellfun(@(x) str2double(x(3)), MatNames);
setNumLog = ismember(setNumList,setNum);
curLIST = MatNames(setNumLog);

end


function checkSet = checkSets(DIRloc)

[outMatNames] = getMatNames(DIRloc,1);

if isempty(outMatNames)
    checkSet = 1;
else
    checkSet = 0;
end

end


