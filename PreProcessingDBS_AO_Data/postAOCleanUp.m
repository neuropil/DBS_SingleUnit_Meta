function [] = postAOCleanUp(study,year,surgDATE,driveLETTER)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

dsh = filesep;

cur_Dir = [driveLETTER,'\S4_AO_ProcMatlabData_S4',dsh,num2str(year),dsh,surgDATE];

switch study
    case 'AT-IO'
        % Keep only 2 EMG and 1 Accelerometer
        % Keep MER mLFP and LFP
        % Keep TTL
        
        % # 2 DELETE FILES from S3
%         cd(cur_Dir)
%         ckSet = checkSets(cur_Dir);
        
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
                tmpSET = [cur_Dir , dsh , setMatDir{setI}];
                toTList = getMatNames(tmpSET , 1);
                runFrefine(toTList , study)
            end
        else
            toTList = getMatNames(cur_Dir , 1);
            runFrefine(toTList , study)
            
        end
        
        
    case 'DLC_SB'
        
        cd(cur_Dir)
        ckSet = checkSets(cur_Dir);
        
        if ckSet
            setMatDir = getDirFolders(cur_Dir);
            for setI = 1:length(setMatDir)
                tmpSET = [cur_Dir , dsh , setMatDir{setI}];
                toTList = getMatNames(tmpSET , 1);
                runFrefine(toTList , study)
            end
        else
            toTList = getMatNames(cur_Dir , 1);
            runFrefine(toTList , study)
            
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



%%%% MATFileNAMES FUNCTION
function mFileI = getMatfile(matName)

tmpInfo = matfile(matName);
wInfo = whos(tmpInfo);
mFileI = {wInfo.name};

end



%%%% REMOVE list 
function [remFinal , keepFinal] = remvIndex(fldList , expType)

switch expType
    case 'ET-DK' % MAY NEED To MODIFY for ACCEL
        keepList = {'CEMG','CSPK','CLFP','CMacro','ProcDone','accel','emg','lfp','mLFP','mer','ttlInfo'};
        keepIndex = contains(fldList,keepList);
        listK1 = fldList(keepIndex);
        listR1 = fldList(~keepIndex);
        % Remove unnecessary EMG
        emgLIST = listK1(contains(listK1,'CEMG'));
        nonEmgList = listK1(~contains(listK1,'CEMG'));
        emgKeepI = cellfun(@(x) str2double(x(end-1:end)) <= 7, emgLIST);
        emgKeep = emgLIST(emgKeepI);
        emgRem = emgLIST(~emgKeepI);
        keepFinal = [emgKeep , nonEmgList];
        remFinal = [emgRem ,listR1];
        % FUTURE Remove unnecessary ACCEL
    case 'DLC_SB'
        keepList = {'CEMG','CSPK','CLFP','CMacro','ProcDone','accel','emg','lfp','mLFP','mer','ttlInfo'};
        keepIndex = contains(fldList,keepList);
        listK1 = fldList(keepIndex);
        listR1 = fldList(~keepIndex);
        % Remove unnecessary EMG
        emgLIST = listK1(contains(listK1,'CEMG'));
        nonEmgList = listK1(~contains(listK1,'CEMG'));
        emgKeepI = cellfun(@(x) str2double(x(end-1:end)) <= 4, emgLIST);
        emgKeep = emgLIST(emgKeepI);
        emgRem = emgLIST(~emgKeepI);
        keepFinal = [emgKeep , nonEmgList];
        remFinal = [emgRem ,listR1];
        
end
end


%%%% LOOP through and CLEAN files
function [] = runFrefine(toTList , study)

numFiles = length(toTList);
for ti = 1:length(toTList)
    tmpMat = toTList{ti};
    tmpMfN = getMatfile(tmpMat);
    [remFinal , ~] = remvIndex(tmpMfN , study);
    % Load
    allDat = load(tmpMat);
    % Resave with new list
    newDat = rmfield(allDat,remFinal);
    save(tmpMat,'-struct','newDat')
    % Clear all
    clearvars allDat
    disp([num2str(ti) , ' out of ' , num2str(numFiles), ' done!'])
end



end






