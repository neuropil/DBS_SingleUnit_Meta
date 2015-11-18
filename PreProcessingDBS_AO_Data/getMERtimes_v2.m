function merTimes = getMERtimes_v2()
%% Start with AlphaOmega Folder

% TO ADD
% Surgeon ID
% Neurology ID
% Research Study
% HaGuide Study
% More than one set
% Date - Change over time?


AOLoc = 'Y:\AlphaOmegaMatlabData';
cd(AOLoc)

% Get list of folders

dirF = dir;
foldernamesTemp = {dirF.name};
foldernamesFinal = foldernamesTemp(~cellfun(@(x) strcmp('.',x(1)),foldernamesTemp));


%% Cycle through folders

foldCount = 1;
merTimes = zeros(length(foldernamesFinal),1);
for fi = 1:length(foldernamesFinal)
    
    dateLoc = strcat(AOLoc,'\',foldernamesFinal{fi});
    cd(dateLoc)
    
    diractualFile = cellstr(ls);
    diractual = diractualFile(cellfun(@(x) ~strcmp('.',x(1)), diractualFile));
    dirDateFiles = dir('*.mat');
    
    testfile = diractual{1};
    
    
    if strcmp(testfile,'Set1') && isempty(dirDateFiles);
        
        tempTimes = zeros(length(diractual),1);
        for dai = 1:length(diractual)
            
            tempDir = strcat(dateLoc,'\Set',num2str(dai));
            cd(tempDir)
            % Get Depth names
            depthSt = dir('*.mat');
            depthS = {depthSt.name};

            [timeSTART,timeEND] = getTopfile(depthS);
  
            tempTimes(dai) = round((timeEND - timeSTART)/60,2); % IN MINUTES

        end % End of Date loop for Sets
        
        allSets = sum(tempTimes);
        merTimes(foldCount,1) = allSets; % IN MINUTES
        foldCount = foldCount + 1;
        
    else
        
        tempDir = dateLoc;
        cd(tempDir)
        % Get Depth names
        depthSt = dir('*.mat');
        depthS = {depthSt.name};
        
        [timeSTART,timeEND] = getTopfile(depthS);
        
        merTimes(foldCount,1) = round((timeEND - timeSTART)/60,2); % IN MINUTES
        
        foldCount = foldCount + 1;

    end
    
    fprintf('Folder %d of %d DONE!! \n',fi,length(foldernamesFinal))
    
end


end % END OF FUNCTION



function [timeSTART,timeEND] = getTopfile(depthS)




abvNs = depthS(cellfun(@(x) strcmp(x(1:3),'Abv'), depthS, 'UniformOutput', true));
abvVCells = cellfun(@(x) strsplit(x,'_'), abvNs, 'UniformOutput', false);
abvVals = cellfun(@(x) str2double(x{2}), abvVCells);
[~,abvIND] = sort(abvVals);

% Resort Abv
abvNs2 = abvNs(abvIND);

% Get Top Abv
topDepth = abvNs2{1};

topMatfile = matfile(topDepth);
topMatInfo = whos(topMatfile);
topNames = {topMatInfo.name};

noORmgHyphsA = cellfun(@(x) strsplit(x,'_'), topNames, 'UniformOutput', false);
noORmgA = cellfun(@(x) x{1}, noORmgHyphsA, 'UniformOutput', false);

if ismember('CSPK',noORmgA)
    
%     spk1 = cellfun(@(x) strcmp(x,'CSPK'), noORmgA);
%     spk1ind = find(spk1,1,'first');
    
    load(topDepth,'CSPK_01_TimeBegin')
    
    timeSTART = CSPK_01_TimeBegin;
    
    if timeSTART/60 > 17;
        topDepth = abvNs2{2};
        load(topDepth,'CSPK_01_TimeBegin')
        timeSTART = CSPK_01_TimeBegin;
    end
    
    
else
    
    load(topDepth,'CElectrode1_TimeBegin')
    
    timeSTART = CElectrode1_TimeBegin;

    if timeSTART/60 > 17;
        topDepth = abvNs2{2};
        load(topDepth,'CElectrode1_TimeBegin')
        timeSTART = CElectrode1_TimeBegin;
    end
    
end

% Find Blw
blwNs = depthS(cellfun(@(x) strcmp(x(1:3),'Blw'), depthS, 'UniformOutput', true));

if isempty(blwNs)
    
    % Get Bot Abv
    botDepth = abvNs2{end - 1};
    
    botMatfile = matfile(botDepth);
    botMatInfo = whos(botMatfile);
    botNames = {botMatInfo.name};
    
    noORmgHyphsB = cellfun(@(x) strsplit(x,'_'), botNames, 'UniformOutput', false);
    noORmgB = cellfun(@(x) x{1}, noORmgHyphsB, 'UniformOutput', false);
    
    if ismember('CSPK',noORmgB)
        
%         spk1 = cellfun(@(x) strcmp(x,'CSPK'), noORmgB);
%         spk1ind = find(spk1,1,'first');
        
        load(botDepth,'CSPK_01_TimeEnd')
        
        timeEND = CSPK_01_TimeEnd;
        
    else
        
        load(botDepth,'CElectrode1_TimeEnd')
        
        timeEND = CElectrode1_TimeEnd;
        
    end
    
elseif numel(blwNs) == 1
    
    % Get Bot Abv
    botDepth = abvNs2{end};
    
    botMatfile = matfile(botDepth);
    botMatInfo = whos(botMatfile);
    botNames = {botMatInfo.name};
    
    noORmgHyphsB = cellfun(@(x) strsplit(x,'_'), botNames, 'UniformOutput', false);
    noORmgB = cellfun(@(x) x{1}, noORmgHyphsB, 'UniformOutput', false);
    
    if ismember('CSPK',noORmgB)
        
%         spk1 = cellfun(@(x) strcmp(x,'CSPK'), noORmgB);
%         spk1ind = find(spk1,1,'first');
        
        load(botDepth,'CSPK_01_TimeEnd')
        
        timeEND = CSPK_01_TimeEnd;
        
    else
        
        load(botDepth,'CElectrode1_TimeEnd')
        
        timeEND = CElectrode1_TimeEnd;
        
    end
    
else
    
    blwVCells = cellfun(@(x) strsplit(x,'_'), blwNs, 'UniformOutput', false);
    blwVals = cellfun(@(x) str2double(x{2}), blwVCells);
    [~,blwIND] = sort(blwVals);
    
    % Resort Abv
    blwNs2 = blwNs(blwIND);
    
    % Get Top Abv
    botDepth = blwNs2{end - 1};
    
    botMatfile = matfile(botDepth);
    botMatInfo = whos(botMatfile);
    botNames = {botMatInfo.name};
    
    noORmgHyphsB = cellfun(@(x) strsplit(x,'_'), botNames, 'UniformOutput', false);
    noORmgB = cellfun(@(x) x{1}, noORmgHyphsB, 'UniformOutput', false);
    
    if ismember('CSPK',noORmgB)
        
%         spk1 = cellfun(@(x) strcmp(x,'CSPK'), noORmgB);
%         spk1ind = find(spk1,1,'first');
        
        load(botDepth,'CSPK_01_TimeEnd')
        
        timeEND = CSPK_01_TimeEnd;
        
    else
        
        load(botDepth,'CElectrode1_TimeEnd')
        
        timeEND = CElectrode1_TimeEnd;
        
    end
    
end

end


