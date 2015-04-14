function Relabel_AO_Depth_v03
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
%     POLoc = 'Y:\PreProcessEphysData';
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
    
    fprintf('Folder %d out of %d folders \n',fdir, length(foldernamesFinal));
    
    % Concatenates DBS drive name with unique folder name
    dateLoc = strcat(AOLoc,'\',foldernamesFinal{fdir});
    cd(dateLoc)
    
    fprintf('Checking folder %s \n',foldernamesFinal{fdir});
    
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
                cd(preProLoc);
                allFilesL = dir('*.txt');
                allFilesLn = {allFilesL.name};
                
                if ~isempty(allFilesLn) && ismember('ProcessDoneFinal.txt',allFilesLn)
                    continue
                else
                    for tsfI = 1:length(toSaveFiles)
                        
                       [~] = CleanPackData(toSaveFiles{tsfI}, lfpBool, preProLoc);
                        
                    end
                    save('ProcessDoneFinal.txt')
                end
                
            end
            
        end % End of Date loop for Sets

        
        
    else % it does not have sets
        
        dai = nan;
        % Detemine if files need to be renamed and rename them
        [preProLoc, lfpBool, toSaveFiles] = RenameCheckLFP(dateLoc, dai, diractual);
        
        if isnan(lfpBool) && isnan(toSaveFiles)
            continue
        else
            
            % If not complete, cycle through each recording in the
            % Session
            cd(preProLoc);
            allFilesL = dir('*.txt');
            allFilesLn = {allFilesL.name};
            if ~isempty(allFilesLn) && ismember('ProcessDoneFinal.txt',allFilesLn)
                continue
            else
                
                for tsfI = 1:length(toSaveFiles)
                    
                     [~] = CleanPackData(toSaveFiles{tsfI}, lfpBool, preProLoc);
                    
                end
                save('ProcessDoneFinal.txt')
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
    
    % ADD 'n' to '-'
    negFiles = cellfun(@(x) strcmp(x(1),'-'),depthFiles);
    negFnames = depthFiles(negFiles);
    for nii = 1:length(negFnames)
        newName = ['n',negFnames{nii}(2:end)];
        movefile(negFnames{nii},newName)
    end
    % Regenerate depthFiles
    depthFilesA_1 = dir('*.mat');
    depthFiles = {depthFilesA_1.name};
    
    % ADD TTL vectors to main file if file has TTL
    
    % 1. loop through all files
    % 2. load list of fields in matfile
    % 3. cellfun to look for C1
    % 4. Get list of depths
    % 5. Run through function to create TTLU and TTLD
    % 5b. Create separate function to do this
    
    ttlChecklist = cell(length(depthFiles),1);
    ttlCc = 1;
    for ttlfi = 1:length(depthFiles)
        
        tTLMatobj = matfile(depthFiles{ttlfi});
        tTLMatinfo = whos(tTLMatobj);
        tTLNames = {tTLMatinfo.name};
        
        ttlCheck = cellfun(@(x) ~isempty(strfind(x,'C1_DI00')), tTLNames);
        
        if sum(ttlCheck) ~= 0;
            ttlChecklist{ttlCc} = depthFiles{ttlfi};
            ttlCc = ttlCc + 1;

        else

            continue
        end

    end
    
    ttlChecklist = ttlChecklist(cellfun(@(x) ~isempty(x), ttlChecklist));
    
    % Create table to determine if pair or not 
    for tv1 = 1:length(ttlChecklist)
        
        Add_TTL_Vecs(ttlChecklist{tv1})
        
    end

    fiExtInd = cellfun(@(x) length(x) > 10, depthFiles);
    numExts = sum(fiExtInd);
    % Get actual names, so index can be dynamic in for loop
    fiExtFnames = depthFiles(fiExtInd);
    % Depth files with extensions '001' can signify one of two things:
    % 1) An extended recording from the same depth (i.e. continuous recording)
    % 2) A repeated pass through when the electrode was driven up or down
    % over that region a second time
    % TO distinguish the difference subtract the TimeBegin (of extension
    % '001') from the TimeEnd of the original file. If the difference far
    % exceeds the sampling frequency (i.e. either greater than ~80
    % uSeconds), then it is likely a repass. Encode as previously :
    % increase micron integer by 1.
    
    % NEED TO FIX LOAD AND SAVE NEGATIVE FILES
    
    %%% REPLACE '-' with 'n' ***********************
    fprintf('%d extension files to check\n',numExts);
    for fiiT = 1:numExts
        

        extF = fiExtFnames{fiiT};
        if strcmp(extF(1),'n')
            findOrig = extF([1:6,length(extF)-3:end]);
        else
            findOrig = extF([1:5,length(extF)-3:end]);
        end
        
        % Get varnames of Ext file
        extMatobj = matfile(extF);
        extMatinfo = whos(extMatobj);
        extMatNames = {extMatinfo.name};
        
        fprintf('Loading extension file %s \n',extF);
        load(extF);
        % Rename extF files
        combFstruct = struct;
        newExtNames = cellfun(@(x) strcat(x,'_ext'), extMatNames, 'UniformOutput', false);
        newOrgNames = cellfun(@(x) strcat(x,'_org'), extMatNames, 'UniformOutput', false);
        for exE = 1:length(extMatNames)
            combFstruct.(extMatNames{exE}) = [];
            combFstruct.(newOrgNames{exE}) = [];
            combFstruct.(newExtNames{exE}) = eval(extMatNames{exE});
        end
        
        % Load Oringial depth file and add to struct
        fprintf('Loading original file %s \n',findOrig);
        
        try
            load(findOrig);
        catch
            notFound = 1;
            startInt = 1;
            while notFound
                
                if length(findOrig) == 10
                    newName = strcat(findOrig(1:5),...
                        num2str(str2double(findOrig(6)) + startInt),...
                        findOrig(7:10));
                else
                    newName = strcat(findOrig(1:4),...
                        num2str(str2double(findOrig(5)) + startInt),...
                        findOrig(6:9));
                end
                
                if ismember(newName,depthFiles)
                    findOrig = newName;
                    notFound = 0;
                else
                    startInt = startInt + 1;
                end

            end
            load(findOrig);
        end
            
        for exO = 1:length(newOrgNames)
            combFstruct.(newOrgNames{exO}) = eval(extMatNames{exO});
        end
        
        % Determine if files should be stitched or not
        timeSepdiff = combFstruct.CElectrode1_TimeBegin_ext - combFstruct.CElectrode1_TimeEnd_org;
        timeSampled = (1/(combFstruct.CElectrode1_KHz_org*1000)) + (1/100000);
        % Time between files is greater than sampling frequency than DO NOT combine
        if timeSepdiff > timeSampled
            combineFlag = 0;
        else
            combineFlag = 1;
        end
        
        % Set up combine code
        if combineFlag
            
            % Cycle through each variable name in struct
            for exC = 1:length(extMatNames)
                % Get name and variable element number
                tempExName = newOrgNames{exC};
                tempExType = numel(combFstruct.(newOrgNames{exC}));
                % Check size of variable
                if tempExType == 1;
                    % Check whether Time or Other stable Value
                    if ~isempty(strfind(tempExName,'Time')) % if == 1 then has to do with Time
                        % Check if Begin or End
                        if ~isempty(strfind(tempExName,'Begin'))
                            combFstruct.(extMatNames{exC}) = combFstruct.(newOrgNames{exC});
                        else % It is the Time End
                            combFstruct.(extMatNames{exC}) = combFstruct.(newExtNames{exC});
                        end
                    else % Is a static variable
                        combFstruct.(extMatNames{exC}) = combFstruct.(newOrgNames{exC});
                    end
                else % Is Spike or LFP voltage trace
                    
                    combFstruct.(extMatNames{exC}) = [combFstruct.(newOrgNames{exC}),combFstruct.(newExtNames{exC})];

                end
                % Overwrite workspace OrgVal with new OrgVal for final save
                clear(extMatNames{exC})
                eval(sprintf('%s = %s;', extMatNames{exC}, 'combFstruct.(extMatNames{exC})'));
            end
        else
            continue
        end
        
        % Add ttl index names to extMatNames
        % Save new raw data file and delete EXT file
        save(findOrig,extMatNames{:})
        % Remove from depthFiles
        depthFiles(ismember(depthFiles,fiExtFnames{fiiT})) = [];
        % Delete extraneous ext file
        delete(extF);
        
        fprintf('Completed # %d extension file \n',fiiT);

    end
    
    
    
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
            
            if ~strcmp(curFname(1),'n'); % CHANGED *********************
                abDSName{atCount,1} = 'AbvTrgt';
                
                abParts = strsplit(depthFiles{fii},'.');
                tempDepth = abParts{1};
                
                if length(tempDepth) > 6
                    stRempDepth = tempDepth(1:5);
                    newabTempDepth1 = num2str(str2double(stRempDepth) + abVCount);
                    % pad with zeros
                    if length(newabTempDepth1) ~= 5
                        curLen = length(newabTempDepth1);
                        numZeros = 5 - curLen;
                        zeroPad = repmat('0',1,numZeros);
                        newabTempDepth2 = [zeroPad , newabTempDepth1];
                    else
                        newabTempDepth2 = newabTempDepth1;
                    end
                    abDSDepthNum(atCount,1) = str2double(newabTempDepth2);
                    abDSDepthAct{atCount,1} = newabTempDepth2;
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
                    blDSDepthNum(btCount,1) = str2double(newblTempDepth2(2:end)); %  CHECK
                    blDSDepthAct{btCount,1} = ['-',newblTempDepth2];              %  CHECK
                    blVCount = blVCount + 1;
                else
                    blDSDepthNum(btCount,1) = abs(str2double(tempDepth(2:end)));
                    blDSDepthAct{btCount,1} = ['-',tempDepth(2:end)];
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
%     blDSOrigName = flipud(blDSOrigName);
    
    % Below Target
    blwTable = table(blDSDepthNum,blDSName,blDSDepthAct,blDSNum,blDSOrigName);
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
        
        fprintf('Copying %s \n',alltempFname);
        
        copyfile(alltempFname,allnewFname);
        
    end
 
    
else
    
    allFilesL = dir('*.txt');
    allFilesLn = {allFilesL.name};
    
    if ~isempty(allFilesLn) && ismember('RMd_files.txt',allFilesLn)
        return
    else
        if ~exist(newLoc,'dir')
            mkdir(newLoc)
        end
        
        simCheck = isequal(GetDirFileList(newLoc),GetDirFileList(oldLoc));
        
        if ~simCheck
            
            for allLi = 1:length(depthFiles)
                
                alltempFname = depthFiles{allLi};
                allnewFname = [newLoc,'\',depthFiles{allLi}];
                
                fprintf('Saving %s \n',alltempFname);
                
                copyfile(alltempFname,allnewFname);
                
            end
            
        else
            return
        end
    end
end % End of DoneTag Boole
end % End of function


%% CleanPackData Function

function [ProcDone] = CleanPackData(recDname, LFPcheck, preProLoc)
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

% 1. Do a matfile check
% 2. Load in files separately 

matAll = matfile(recDname);
matFns = who(matAll);

% load(recDname)

% dNchkL = whos;
% dNchkN = {dNchkL.name};

if ismember('ProcDone',matFns)
    ProcDone = nan;
    return
else
    
    mer = struct;
    lfp = struct;
    
    if LFPcheck
        
        load(recDname,'CElectrode1_KHz')
        load(recDname,'CElectrode1_TimeBegin')
        load(recDname,'CElectrode1_TimeEnd')
        load(recDname,'CLFP1_KHz')
        load(recDname,'CLFP1_TimeBegin')
        load(recDname,'CLFP1_TimeEnd')
                                
        mer.sampFreqHz = CElectrode1_KHz*1000;
        mer.timeStart = CElectrode1_TimeBegin;
        mer.timeEnd = CElectrode1_TimeEnd;
        lfp.sampFreqHz = CLFP1_KHz*1000;
        lfp.timeStart = CLFP1_TimeBegin;
        lfp.timeEnd = CLFP1_TimeEnd;

        ProcDone = 1;
        
        if exist('C1_DI001_Up','var')
            
            load(recDname,'C1_DI001_Up')
            load(recDname,'C1_DI001_Down')
            load(recDname,'C1_DI001_KHz')
            load(recDname,'C1_DI001_TimeBegin')
            load(recDname,'C1_DI001_TimeEnd')
            load(recDname,'TTL_sp_UP')
            load(recDname,'TTL_sp_DN')
            
            ttlInfo.ttl_up = C1_DI001_Up;
            ttlInfo.ttl_dn = C1_DI001_Down;
            ttlInfo.ttl_sf = C1_DI001_KHz;
            ttlInfo.ttlTimeBegin = C1_DI001_TimeBegin;
            ttlInfo.ttlTimeEnd = C1_DI001_TimeEnd;
            ttlInfo.ttlTimesUp = TTL_sp_UP;
            ttlInfo.ttlTimesDn = TTL_sp_DN;
            
            fprintf('Saving %s \n',recDname);
            
            load(recDname,'CElectrode1')
%             load(recDname,'CElectrode2')
%             load(recDname,'CElectrode3')
            load(recDname,'CLFP1')
%             load(recDname,'CLFP2')
%             load(recDname,'CLFP3')
                                
            save(recDname,...
                'mer','lfp','ttlInfo',...
                'ProcDone','-append');
                
        else
            
            fprintf('Saving %s \n',recDname);
            
            load(recDname,'CElectrode1')
%             load(recDname,'CElectrode2')
%             load(recDname,'CElectrode3')
            load(recDname,'CLFP1')
%             load(recDname,'CLFP2')
%             load(recDname,'CLFP3')
            
            save(recDname,...
                'mer','lfp',...
                'ProcDone','-append');
            
            ProcDone = 1;
            
        end
        
    else
        
        load(recDname,'CElectrode1_KHz')
        load(recDname,'CElectrode1_TimeBegin')
        load(recDname,'CElectrode1_TimeEnd')
        
        mer.sampFreqHz = CElectrode1_KHz*1000;
        mer.timeStart = CElectrode1_TimeBegin;
        mer.timeEnd = CElectrode1_TimeEnd;
        
        ProcDone = 1;
        
        if exist('C1_DI001_Up','var')
            
            load(recDname,'C1_DI001_Up')
            load(recDname,'C1_DI001_Down')
            load(recDname,'C1_DI001_KHz')
            load(recDname,'C1_DI001_TimeBegin')
            load(recDname,'C1_DI001_TimeEnd')
            load(recDname,'TTL_sp_UP')
            load(recDname,'TTL_sp_DN')
            
            ttlInfo.ttl_up = C1_DI001_Up;
            ttlInfo.ttl_dn = C1_DI001_Down;
            ttlInfo.ttl_sf = C1_DI001_KHz;
            ttlInfo.ttlTimeBegin = C1_DI001_TimeBegin;
            ttlInfo.ttlTimeEnd = C1_DI001_TimeEnd;
            ttlInfo.ttlTimesUp = TTL_sp_UP;
            ttlInfo.ttlTimesDn = TTL_sp_DN;
            
            fprintf('Saving %s \n',recDname);
            
            load(recDname,'CElectrode1')
%             load(recDname,'CElectrode2')
%             load(recDname,'CElectrode3')
            load(recDname,'CLFP1')
%             load(recDname,'CLFP2')
%             load(recDname,'CLFP3')
            
            save(recDname,...
                'mer','ttlInfo','ProcDone','-append');
            
        else
            
            fprintf('Saving %s \n',recDname);
            
            load(recDname,'CElectrode1')
%             load(recDname,'CElectrode2')
%             load(recDname,'CElectrode3')
            load(recDname,'CLFP1')
%             load(recDname,'CLFP2')
%             load(recDname,'CLFP3')
            
            save(recDname,...
                'mer','ProcDone','-append');
            
        end
        
    end
    
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
    
    allFilesL = dir('*.txt');
    allFilesLn = {allFilesL.name};
    
    if ~isempty(allFilesLn) && ismember('ProcessDoneFinal.txt',allFilesLn)
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

allFilesL = dir('*.txt');
allFilesLn = {allFilesL.name};

if ~isempty(allFilesLn) && ismember('RMd_files.txt',allFilesLn)
    toSaveFiles = GetDirFileList(newLoc);
    lfpBool = LFPtest(newLoc);
    return
else
    
    toProcNames = GetDirFileList(newLoc);
    lfpBool = LFPtest(newLoc);
    toSaveFiles = cell(length(toProcNames),1);
    sfcount = 1;
    
    cd(newLoc)
    for pfi = 1:length(toProcNames)
        
        tempDepthFile = toProcNames{pfi};
        try
            load(tempDepthFile)
        catch
            load(tempDepthFile,'CElectrode1_KHz')
            load(tempDepthFile,'CElectrode1')
        end
        tempSfreq = CElectrode1_KHz * 1000;
        tempRecTime = numel(CElectrode1)/tempSfreq;
        
        if tempRecTime >= 10
            fprintf('Saving and transfering new file %s \n',toProcNames{pfi});
            toSaveFiles{sfcount,1} = tempDepthFile;
            sfcount = sfcount + 1;
            
        else
            delete(tempDepthFile)
        end
        
    end
    
    % Remove files that are not to be saved
    emptyInd = cellfun(@(x) ~isempty(x), toSaveFiles);
    toSaveFiles = toSaveFiles(emptyInd,:);
    save('RMd_files.txt')
    cd(tempdateLoc)
    save('RMd_files.txt')
    cd(newLoc)
end



end % END of function


%% SomeOther Function

function [] = Add_TTL_Vecs(ttlInput)

% lVarNames = Get_ListOfVars(ttlInput);

load(ttlInput)
block = build_block_AO(C1_DI001_Down,...
    C1_DI001_Up,...
    C1_DI001_TimeBegin,...
    C1_DI001_KHz);


[toAddTTL_UP, toAddTTL_DN] = Get_ttl_Times_AO(block);

TTL_sp_UP = toAddTTL_UP; %#ok<NASGU>
TTL_sp_DN = toAddTTL_DN; %#ok<NASGU>

save(ttlInput,'TTL_sp_UP','-append')
save(ttlInput,'TTL_sp_DN','-append')

% clearvars(lVarNames{:})
            

end
