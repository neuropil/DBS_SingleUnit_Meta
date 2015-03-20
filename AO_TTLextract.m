%% Figure out how many files where experimental files

cd('Y:\PreProcessEphysData\02_26_2015')

fdir = dir('*.mat');
tabdir = struct2table(fdir);
fileNames = tabdir.name;

expFiles = cell(length(fileNames),1);
expFNum = 0;
expCount = 1;
for fi = 1:length(fileNames)
    
    filefront = fileNames{fi}(1);
    if strcmp(filefront,'-')
        continue
    else
        load(fileNames{fi})
    end
    
    if exist('C1_DI001_Up','var')
        expFiles{expCount} = fileNames{fi};
        expFNum = expFNum + 1;
        expCount = expCount + 1;
    else
        clearvars -except fileNames expFiles expFNum expCount
        continue
    end
        
    clearvars -except fileNames expFiles expFNum expCount

end

% Clean of exp fnames

expFiles = expFiles(cellfun(@(x) ~isempty(x), expFiles));

%%

load('AbvTrgt_23_11008.mat')



% Total Recording time
totalRecordTime = (timeEnd - timeStart)/60; % in minutes

% Duration of time before first Timestamp
expToffset = (ttlInfo.ttlTimeBegin - timeStart)/60; % in minutes

% Total experimental time
totalExptime = totalRecordTime - expToffset; % in minutes


timeVec = linspace(1,length(CElectrode1),length(CElectrode1)); % 
timeVecSF = timeVec*sampFreqMER*1000;


%% 


% Index start of timestamp

roundVal = 100000;
expToffSF = expToffset*ttlInfo.ttl_sf*1000;

zeroTimeVecSF = 1:1:length(CElectrode1);
zeroTimeVec = zeroTimeVecSF/(sampFreqMER*1000);
zeroTimeVR = round(zeroTimeVec*roundVal)/roundVal;

timeStampVecSF = ttlInfo.ttl_up + expToffSF;
timeStampVec = timeStampVecSF/(ttlInfo.ttl_sf*1000);
timeStampVR = round(timeStampVec*roundVal)/roundVal;

tsIndex = zeros(length(timeStampVR),1);
for tsI = 1:length(timeStampVR)
    
    ts = timeStampVR(tsI);
    
    if isempty(find(ismember(zeroTimeVR,ts),1))
        [~, tsIndex(tsI)] = min(abs(zeroTimeVR - ts));
    else
        tsIndex(tsI) = find(ismember(zeroTimeVR,ts));
    end
 
end

%%

ttlInfo.ttlTimeBegin*sampFreqMER*1000 + ttlInfo.ttl_up(1)

% Start raw index value for beginning of stiched trace.

