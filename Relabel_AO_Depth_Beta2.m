function Relabel_AO_Depth_Beta2

% To add
% 1. Refine structure ; come up with generic sort name for depth
% 2. Add mm distance
% 3. Delete struct elements that are not relevant
% 4. Add Function details


if exist('Y:\','dir')
    AOLoc = 'Y:\AlphaOmegaMatlabData';
    cd(AOLoc)
    dirfolders = dir;
    foldernamesTemp = {dirfolders.name};
    foldernamesFinal = foldernamesTemp(~cellfun(@(x) strcmp('.',x(1)),foldernamesTemp));
else
    warndlg('Check for Y:\DBS Drive');
end

% Loop through Recording Directory

for fdir = 1:length(foldernamesFinal)
    
    dateLoc = strcat(AOLoc,'\',foldernamesFinal{fdir});
    cd(dateLoc)
    
    % Check for Sets
    diractualFile = cellstr(ls);
    diractual = diractualFile(3:end);
    testfile = diractual{1};
    
    dirDateFiles = dir('*.mat');
    
    if strcmp(testfile,'Set1') && isempty(dirDateFiles);
        
        for dai = 1:length(diractual)
            
            [lfpBool, toSaveFiles] = runSomething(dateLoc, dai, diractual);
            
            if isnan(lfpBool) && isnan(toSaveFiles)
                continue
            else
                
                for tsfI = 1:length(toSaveFiles)
                    
                    [~, ~, ~, ~] = CleanPackData(toSaveFiles{tsfI},lfpBool,preProLoc);
                    
                end
                
            end
            
        end % End of Date loop for Sets
        
    else % it does not have sets
        
        dai = nan;
        [lfpBool, toSaveFiles] = runSomething(dateLoc, dai, diractual);

        if isnan(lfpBool) && isnan(toSaveFiles)
            continue
        else
            
            for tsfI = 1:length(toSaveFiles)
                
                [~, ~, ~, ~] = CleanPackData(toSaveFiles{tsfI},lfpBool,preProLoc);
                
            end
        end
        
        
    end % End of test for Sets
end

end % End of main function

%% RENAME_FILE FUNCTION

function [newLoc] = rename_file(depthFiles,actFileDir,doneTag)

newLoc = strcat('Y:\PreProcessEphysData\',actFileDir);

if doneTag == 0
    
    abDSName = cell(length(depthFiles),1);
    abDSDepthAct = cell(length(depthFiles),1);
    abDSDepthNum = nan(length(depthFiles),1);
    abDSNum = nan(length(depthFiles),1);
    
    blDSName = cell(length(depthFiles),1);
    blDSDepthAct = cell(length(depthFiles),1);
    blDSDepthNum = nan(length(depthFiles),1);
    blDSNum = nan(length(depthFiles),1);
    
    atCount = 1;
    btCount = 1;
    for fii = 1:length(depthFiles)
        curFname = depthFiles{fii};
        if ~strcmp(curFname(1),'-');
            abDSName{atCount,1} = 'AbvTrgt';
            
            abParts = strsplit(depthFiles{fii},'.');
            tempDepth = abParts{1};
            
            if length(tempDepth) > 6
                stRempDepth = tempDepth(1:5);
                abDSDepthNum(atCount,1) = str2double(stRempDepth) + 1;
            else
                abDSDepthNum(atCount,1) = str2double(tempDepth);
            end
            
            abDSDepthNum(atCount,1) = str2double(tempDepth);
            abDSDepthAct{atCount,1} = tempDepth;
            abDSNum(atCount,1) = atCount;
            atCount = atCount + 1;
        else
            blDSName{btCount,1} = 'BlwTrgt';
            
            blParts = strsplit(depthFiles{fii},'.');
            tempDepth = blParts{1};
            
            if length(tempDepth) > 6
                stRempDepth = tempDepth(2:6);
                blDSDepthNum(btCount,1) = abs(str2double(stRempDepth) + 1);
                
            else
                blDSDepthNum(btCount,1) = abs(str2double(tempDepth));
            end
            
            blDSDepthAct{btCount,1} = tempDepth;
            blDSNum(btCount,1) = btCount;
            btCount = btCount + 1;
        end
    end
    
    abDSName = abDSName(cellfun(@(x) ~isempty(x), abDSName));
    abDSDepthAct = abDSDepthAct(cellfun(@(x) ~isempty(x), abDSDepthAct));
    abDSDepthNum = abDSDepthNum(~isnan(abDSDepthNum));
    abDSNum = abDSNum(~isnan(abDSNum));
    
    % Above Target
    abvTable = table(abDSDepthNum,abDSName,abDSDepthAct,abDSNum);
    [abvOutT,~] = sortrows(abvTable,'abDSDepthNum','descend');
    
    for abi = 1:height(abvOutT)
        
        abtempFname = [abvOutT.abDSDepthAct{abi},'.mat'];
        abnewFname = [abvOutT.abDSName{abi},'_',num2str(abi),'_',abvOutT.abDSDepthAct{abi},'.mat'];
        movefile(abtempFname,abnewFname);
        
    end
    
    blDSName = blDSName(cellfun(@(x) ~isempty(x), blDSName));
    blDSDepthAct = blDSDepthAct(cellfun(@(x) ~isempty(x), blDSDepthAct));
    blDSDepthNum = blDSDepthNum(~isnan(blDSDepthNum));
    blDSNum = blDSNum(~isnan(blDSNum));
    
    % Below Target
    blwTable = table(blDSDepthNum,blDSName,blDSDepthAct,blDSNum);
    [blwOutT,~] = sortrows(blwTable,'blDSDepthNum');
    
    for bli = 1:height(blwOutT)
        
        bltempFname = [blwOutT.blDSDepthAct{bli},'.mat'];
        blnewFname = [blwOutT.blDSName{bli},'_',num2str(bli),'_',blwOutT.blDSDepthAct{bli},'.mat'];
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
    
    
    for allLi = 1:length(depthFiles)
        
        alltempFname = depthFiles{allLi};
        allnewFname = [newLoc,'\',depthFiles{allLi}];
        
        if ~exist(newLoc,'dir')
            mkdir(newLoc)
        end
        
        copyfile(alltempFname,allnewFname);
        
    end
    
end



end


%% CleanPackData Function

function [sampFreqMER, sampFreqLFP, timeStart, ProcDone] = CleanPackData(recDname, LFPcheck, preProLoc)

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

function [lfpBool, toSaveFiles] = runSomething(dateLoc, dai, diractual)

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

% RECYCLE THROUGH PREPROCESSED FOLDER deleting unnecessary
% files CONSIDER MAKING NEW FUNCTION


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

% HERE IS WHERE FUNCTION to REMOVE will go

emptyInd = cellfun(@(x) ~isempty(x), toSaveFiles);
toSaveFiles = toSaveFiles(emptyInd,:);



end

