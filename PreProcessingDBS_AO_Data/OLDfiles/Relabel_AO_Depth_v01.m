function Relabel_AO_Depth_v01
% RELABEL_AO_DEPTH VERSION 0.1
% This function will cycle through Recording days, rename and repack files
% based on pertient data. 
% Defaults: 
% 1. Will only store recording files that have recording times longer than 10s
% 2. Will delete non-used LFP recordings based on CV
% 3. Will only store Electrode1 and LFP1 sampling frequency.
% 4. Currently no inputs or outputs to main function

% Check for access to DBS Data Drive on local computer
if exist('Y:\','dir')
    AOLoc = 'Y:\AlphaOmegaMatlabData';
    cd(AOLoc)
    dirfolders = dir;
    foldernamesTemp = {dirfolders.name};
    foldernamesFinal = foldernamesTemp(~cellfun(@(x) strcmp('.',x(1)),foldernamesTemp));
else
    warndlg('Check for Y:\DBS Drive'); % NEED to Obtain access to Drive
end

% Loop through available recording days, differentiate between days that
% had more than one set of trajectories denoted by 'Set'

for fdir = 1:length(foldernamesFinal)
    
    % Concatenates DBS drive name with unique folder name
    dateLoc = strcat(AOLoc,'\',foldernamesFinal{fdir});
    cd(dateLoc)
    
    % Check for multiple sets of trajectories 'Set'
    diractualFile = cellstr(ls);
    diractual = diractualFile(cellfun(@(x) ~strcmp('.',x(1)), diractualFile));
    testfile = diractual{1};
    dirDateFiles = dir('*.mat');
    
    % If there are Sets, then cycle through each Set   
    if strcmp(testfile,'Set1') && isempty(dirDateFiles);
        % Loop through each Set
        for dai = 1:length(diractual)
            % Detemine if files need to be renamed and rename them
            [preProLoc, lfpBool, toSaveFiles] = RenameCheckLFP(dateLoc, dai, diractual);
            % Skip recording day if already complete
            if isnan(lfpBool) && isnan(toSaveFiles)
                continue
            else
                % If not complete, cycle through each recording in the
                % Session
                for tsfI = 1:length(toSaveFiles)
                    
                    [~, ~, ~, ~] = CleanPackData(toSaveFiles{tsfI}, lfpBool, preProLoc);
                    
                end
                
            end
            
        end % End of Date loop for Sets
        
    else % it does not have sets
        
        dai = nan;
        [preProLoc, lfpBool, toSaveFiles] = RenameCheckLFP(dateLoc, dai, diractual);

        if isnan(lfpBool) && isnan(toSaveFiles)
            continue
        else
            
            for tsfI = 1:length(toSaveFiles)
                
                [~, ~, ~, ~] = CleanPackData(toSaveFiles{tsfI}, lfpBool, preProLoc);
                
            end
        end
        
    end % End of test for Sets
end

end % End of main function

%% RENAME_FILE FUNCTION

function [newLoc] = rename_file(depthFiles, actFileDir, doneTag)
% RENAME_FILE
% Performs renaming of recording files. Takes in raw depths and returns
% either 'Above Target' or 'Below Target' precursor.

% Inputs:
% 1. depthFiles = CELL ARRAY of recording depth file names
% 2. actFileDir = STRING of folder directory
% 3. doneTag = BOOLEAN indicating whether renaming can be skipped

% Outputs:
% 1. newLoc = Directory for renamed files to be transferred.

oldLoc = pwd;
newLoc = strcat('Y:\PreProcessEphysData\',actFileDir);

if doneTag == 0
    
    abDSName = cell(length(depthFiles),1);
    abDSDepthAct = cell(length(depthFiles),1);
    abDSOrigName = cell(length(depthFiles),1);
    abDSDepthNum = nan(length(depthFiles),1);
    abDSNum = nan(length(depthFiles),1);
    % For half finished files
    abFinishNum = nan(length(depthFiles),1);
    abFcount = 1;
    %
    
    blDSName = cell(length(depthFiles),1);
    blDSDepthAct = cell(length(depthFiles),1);
    blDSOrigName = cell(length(depthFiles),1);
    blDSDepthNum = nan(length(depthFiles),1);
    blDSNum = nan(length(depthFiles),1);
    
    atCount = 1;
    btCount = 1;
    abVCount = 1;
    blVCount = 1;
    for fii = 1:length(depthFiles)
        curFname = depthFiles{fii};
        
        % If already modified skip
        if ~isempty(strfind(curFname,'Trgt'));
            
            % Only Above targets considered NEED to update
            abF_parts = strsplit(curFname,'_');
            abFinishNum(abFcount) = str2double(abF_parts{2});
            abFcount = abFcount + 1;
            
            continue
        else
            
            if ~strcmp(curFname(1),'-');
                abDSName{atCount,1} = 'AbvTrgt';
                
                abParts = strsplit(depthFiles{fii},'.');
                tempDepth = abParts{1};
                
                if length(tempDepth) > 6
                    stRempDepth = tempDepth(1:5);
                    newabTempDepth = num2str(str2double(stRempDepth) + abVCount);
                    abDSDepthNum(atCount,1) = str2double(newabTempDepth);
                    abDSDepthAct{atCount,1} = newabTempDepth;
                    abVCount = abVCount + 1;
                else
                    abDSDepthNum(atCount,1) = str2double(tempDepth);
                    abDSDepthAct{atCount,1} = tempDepth;
                end
                
                abDSOrigName{atCount,1} = curFname;
                
                abDSNum(atCount,1) = atCount;
                atCount = atCount + 1;
            else
                blDSName{btCount,1} = 'BlwTrgt';
                
                blParts = strsplit(depthFiles{fii},'.');
                tempDepth = blParts{1};
                
                if length(tempDepth) > 6
                    stRempDepth = tempDepth(2:6);
                    newblTempDepth1 = num2str(abs(str2double(stRempDepth) + blVCount));
                    % pad with zeros
                    if length(newblTempDepth1) ~= 5
                        curLen = length(newblTempDepth1);
                        numZeros = 5 - curLen;
                        zeroPad = repmat('0',1,numZeros);
                        newblTempDepth2 = [zeroPad , newblTempDepth1];
                    else
                        newblTempDepth2 = newblTempDepth1;
                    end
                    blDSDepthNum(btCount,1) = str2double(newblTempDepth2);
                    blDSDepthAct{btCount,1} = ['-',newblTempDepth2];
                    blVCount = blVCount + 1;
                else
                    blDSDepthNum(btCount,1) = abs(str2double(tempDepth));
                    blDSDepthAct{btCount,1} = tempDepth;
                end
                
                blDSOrigName{btCount,1} = curFname;

                blDSNum(btCount,1) = btCount;
                btCount = btCount + 1;
            end
            
        end
        
    end
    
    % Also only exists for Above Target MUST update for below target
    if any(~isnan(abFinishNum))
        abFinishNum = abFinishNum(~isnan(abFinishNum));
        maxVal = max(abFinishNum);
        newStart = maxVal + 1;
        abDSNum = flipud((newStart:1:newStart + (length(abDSNum(~isnan(abDSNum))) - 1))');
    else
        abDSNum = abDSNum(~isnan(abDSNum));
    end
    
    abDSName = abDSName(cellfun(@(x) ~isempty(x), abDSName));
    abDSDepthAct = abDSDepthAct(cellfun(@(x) ~isempty(x), abDSDepthAct));
    abDSDepthNum = abDSDepthNum(~isnan(abDSDepthNum));
    abDSOrigName = abDSOrigName(cellfun(@(x) ~isempty(x), abDSOrigName));
    abDSOrigName = flipud(abDSOrigName);
    
    % Above Target
    abvTable = table(abDSDepthNum,abDSName,abDSDepthAct,abDSNum);
    [abvOutT,~] = sortrows(abvTable,'abDSDepthNum','descend');
    
    for abi = 1:height(abvOutT)
        
        abtempFname = abDSOrigName{abi};
        abnewFname = [abvOutT.abDSName{abi},'_',num2str(abi),'_',abvOutT.abDSDepthAct{abi},'.mat'];
        movefile(abtempFname,abnewFname);
        
    end
    
    blDSName = blDSName(cellfun(@(x) ~isempty(x), blDSName));
    blDSDepthAct = blDSDepthAct(cellfun(@(x) ~isempty(x), blDSDepthAct));
    blDSDepthNum = blDSDepthNum(~isnan(blDSDepthNum));
    blDSNum = blDSNum(~isnan(blDSNum));
    blDSOrigName = blDSOrigName(cellfun(@(x) ~isempty(x), blDSOrigName));
    blDSOrigName = flipud(blDSOrigName);
    
    % Below Target
    blwTable = table(blDSDepthNum,blDSName,blDSDepthAct,blDSNum);
    [blwOutT,~] = sortrows(blwTable,'blDSDepthNum');
    
    for bli = 1:height(blwOutT)
        
        bltempFname = blDSOrigName{bli};
        blnewFname = [blwOutT.blDSName{bli},'_',num2str(bli),'_',blwOutT.blDSDepthAct{bli}(2:end),'.mat'];
        movefile(bltempFname,blnewFname);
        
    end
    
    curLocDir = pwd;
    newFnames = GetDirFileList(curLocDir);
    
    for allLi = 1:length(newFnames)
        
        alltempFname = newFnames{allLi};
        allnewFname = [newLoc,'\',newFnames{allLi}];
        
        if ~exist(newLoc,'dir')
            mkdir(newLoc)
        end
        
        copyfile(alltempFname,allnewFname);
        
    end
 
    
else
    
    if ~exist(newLoc,'dir')
        mkdir(newLoc)
    end
    
    simCheck = isequal(GetDirFileList(newLoc),GetDirFileList(oldLoc));
    
    if ~simCheck
        
        for allLi = 1:length(depthFiles)
            
            alltempFname = depthFiles{allLi};
            allnewFname = [newLoc,'\',depthFiles{allLi}];
            
            copyfile(alltempFname,allnewFname);
            
        end
        
    else
        return
    end
    
end % End of DoneTag Boole
end % End of function


%% CleanPackData Function

function [sampFreqMER, sampFreqLFP, timeStart, ProcDone] = CleanPackData(recDname, LFPcheck, preProLoc)
% CLEANPACKDATA
% Performs repacking of recording files. Removes unnecessary files created by 
% AlphaOmega system. Resaves in duplicate directory with fewer files.

% Inputs:
% 1. recDname = STRING of recording day to be assessed and packed
% 2. LFPcheck = BOOLEAN indicating whether LFP data needs to be saved
% 3. preProLoc = STRING of Preprocessed directory (duplicate of original)

% Outputs:
% 1. sampFreqMER = DOUBLE of Single Unit sampling frequency
% 2. sampFreqLFP = DOUBLE of LFP sampling frequency
% 3. timeStart = DOUBLE of relative start of recording (relative to start
% of surgery
% 4. ProcDone = BOOLEAN to indicate that preprocessing was performed

cd(preProLoc)

load(recDname)

if LFPcheck
    
    sampFreqMER = CElectrode1_KHz;
    sampFreqLFP = CLFP1_KHz;
    timeStart = CElectrode1_TimeBegin;
    ProcDone = 1;
    save(recDname,'CElectrode1','CElectrode2','CElectrode3',...
        'sampFreqMER','sampFreqLFP','timeStart','ProcDone',...
        'CLFP1','CLFP2','CLFP3');
    
else
    
    sampFreqMER = CElectrode1_KHz;
    sampFreqLFP = NaN;
    timeStart = CElectrode1_TimeBegin;
    ProcDone = 1;
    save(recDname,'CElectrode1','CElectrode2','CElectrode3',...
        'sampFreqMER','timeStart','ProcDone');
    
end

end


%% SomeOther Function

function [newLoc, lfpBool, toSaveFiles] = RenameCheckLFP(dateLoc, dai, diractual)
% RENAMECHECKLFP
% Rename files if necessary, determine whether LFPs were recorded and
% determine whether file should be saved based on recording time length

% Inputs:
% 1. dateLoc = STRING of folder directory location
% 2. dai = BOOLEAN indicating which SET to use
% 3. diractual = STRING in case of SETs used to store folder directory 

% Outputs:
% 1. newLoc = STRING of directory for renamed files to be transferred.
% 2. lfpBool = BOOLEAN indicating whether LFP data needs to be saved
% 3. toSaveFiles = CELL ARRAY of recording files that should be preserved


if isnan(dai)
    tempdateLoc = dateLoc;
else
    tempdateLoc = strcat(dateLoc,'\',diractual{dai});
end

cd(tempdateLoc)

depthFilesA_1 = dir('*.mat');
depthFiles = {depthFilesA_1.name};

testFileA = depthFiles{1};

actFileDir = strrep(tempdateLoc, 'Y:\AlphaOmegaMatlabData\', '');

preProLoc = ['Y:\PreProcessEphysData\' , actFileDir];

if exist(preProLoc,'dir')
    
    cd(preProLoc)
    testPreNames = GetDirFileList(preProLoc);
    testPfile = testPreNames{1};
    load(testPfile)
    if exist('ProcDone','var');
        newLoc = nan;
        toSaveFiles = nan;
        lfpBool = nan;
        return
    end
    cd(tempdateLoc)
end

if strcmp(regexp(testFileA,'Trgt','match'),'Trgt')
    doneTag = 1;
    newLoc = rename_file(depthFiles, actFileDir, doneTag);
else
    doneTag = 0;
    newLoc = rename_file(depthFiles, actFileDir, doneTag);
end % End of determine whether already done


cd(newLoc)

toProcNames = GetDirFileList(newLoc);
[~, lfpBool] = LFPtest(newLoc);
toSaveFiles = cell(length(toProcNames),1);
sfcount = 1;

for pfi = 1:length(toProcNames)
    
    tempDepthFile = toProcNames{pfi};
    load(tempDepthFile)
    
    tempSfreq = CElectrode1_KHz * 1000;
    tempRecTime = numel(CElectrode1)/tempSfreq;
    
    if tempRecTime >= 10
        
        toSaveFiles{sfcount,1} = tempDepthFile;   
        sfcount = sfcount + 1;
        
    else
        delete(tempDepthFile)
    end

end

% Remove files that are not to be saved
emptyInd = cellfun(@(x) ~isempty(x), toSaveFiles);
toSaveFiles = toSaveFiles(emptyInd,:);

end % END of function



