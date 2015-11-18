function merTimes = getMERtimes()
%% Start with AlphaOmega Folder

AOLoc = 'Y:\AlphaOmegaMatlabData';
cd(AOLoc)

% Get list of folders

dirF = dir;
foldernamesTemp = {dirF.name};
foldernamesFinal = foldernamesTemp(~cellfun(@(x) strcmp('.',x(1)),foldernamesTemp));


%% Cycle through folders

foldCount = 1;
merTimes = zeros(500,1);
for fi = 1:length(foldernamesFinal)
    
    dateLoc = strcat(AOLoc,'\',foldernamesFinal{fi});
    cd(dateLoc)
    
    diractualFile = cellstr(ls);
    diractual = diractualFile(cellfun(@(x) ~strcmp('.',x(1)), diractualFile));
    dirDateFiles = dir('*.mat');
    
    testfile = diractual{1};
    
    if strcmp(testfile,'Set1') && isempty(dirDateFiles);
        
        for dai = 1:length(diractual)
            
            tempDir = strcat(dateLoc,'\Set',num2str(dai));
            cd(tempDir)
            % Get Depth names
            depthSt = dir('*.mat');
            depthS = {depthSt.name};
            
            
            timeSTART = getTopfile(depthS);
            
            
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
                    
                    spk1 = cellfun(@(x) strcmp(x,'CSPK'), noORmgB);
                    spk1ind = find(spk1,1,'first');
                    
                    load(topNames{spk1ind},'CSPK_01_TimeEnd')
                    
                    timeEND = CSPK_01_TimeEnd;
                    
                else
                    
                    spk1 = cellfun(@(x) strcmp(x,'CElectrode1'), noORmgB);
                    spk1ind = find(spk1,1,'first');
                    
                    load(topNames{spk1ind},'CElectrode1_TimeEnd')
                    
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
                    
                    spk1 = cellfun(@(x) strcmp(x,'CSPK'), noORmgB);
                    spk1ind = find(spk1,1,'first');
                    
                    load(topNames{spk1ind},'CSPK_01_TimeEnd')
                    
                    timeEND = CSPK_01_TimeEnd;
                    
                else
                    
                    spk1 = cellfun(@(x) strcmp(x,'CElectrode1'), noORmgB);
                    spk1ind = find(spk1,1,'first');
                    
                    load(topNames{spk1ind},'CElectrode1_TimeEnd')
                    
                    timeEND = CElectrode1_TimeEnd;
                    
                end
                
            end
            
            merTimes(foldCount,1) = timeEND - timeSTART;
            foldCount = foldCount + 1;
            
        end % End of Date loop for Sets
        
    else
        
        tempDir = dateLoc;
        cd(tempDir)
        % Get Depth names
        depthSt = dir('*.mat');
        depthS = {depthSt.name};
        
        % Find Abv
        timeSTART = getTopfile(depthS);
        
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
                
                spk1 = cellfun(@(x) strcmp(x,'CSPK'), noORmgB);
                spk1ind = find(spk1,1,'first');
                
                load(topNames{spk1ind},'CSPK_01_TimeEnd')
                
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
                
                spk1 = cellfun(@(x) strcmp(x,'CSPK'), noORmgB);
                spk1ind = find(spk1,1,'first');
                
                load(topNames{spk1ind},'CSPK_01_TimeEnd')
                
                timeEND = CSPK_01_TimeEnd;
                
            else
                
                spk1 = cellfun(@(x) strcmp(x,'CElectrode1'), noORmgB);
                spk1ind = find(spk1,1,'first');
                
                load(topNames{spk1ind},'CElectrode1_TimeEnd')
                
                timeEND = CElectrode1_TimeEnd;
                
            end
            
        end
        
        merTimes(foldCount,1) = round((timeEND - timeSTART)/60,2); % IN MINUTES
        foldCount = foldCount + 1;

    end
    
end



end % END OF FUNCTION



function timeSTART = getTopfile(depthS)

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
    
    spk1 = cellfun(@(x) strcmp(x,'CSPK'), noORmgA);
    spk1ind = find(spk1,1,'first');
    
    load(topNames{spk1ind},'CSPK_01_TimeBegin')
    
    timeSTART = CSPK_01_TimeBegin;
    
else
    
    load(topDepth,'CElectrode1_TimeBegin')
    
    timeSTART = CElectrode1_TimeBegin;
    
end
            
end


function timeEND = getBotfile(depthS)






end