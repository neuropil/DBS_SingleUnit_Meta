function [humanStruct] = CreateHumanEphysTaskStruct(ExpType, cell_num)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

fileParts = strsplit(cell_num,{'_','.'});

spkNameCon = struct;

spkNameCon.date = fileParts{1};
spkNameCon.surgery = fileParts{2}(4);
spkNameCon.set = fileParts{3}(4);
spkNameCon.depth = fileParts{5};
spkNameCon.elect = fileParts{6};
spkNameCon.relTarg = fileParts{4}(1);
spkNameCon.relTargVal = fileParts{4}(2:end);

cellSurgInfo = SpkNameConvert_v01(spkNameCon);

ttlDir = cellSurgInfo.CDir;

switch ExpType
    
    case 'P50'
        
        behDataDir = 'Y:\P50_MatlabData';
        behName = strcat(spkNameCon.date , '_', spkNameCon.relTargVal, '_',...
            spkNameCon.depth,'.mat');
        
        % Do something first
        cd(behDataDir)
        load(behName)
        
        % Then convert to behFnames
        clicksec = str2double(export.gateparams.clicksec); %#ok<*NASGU>
        btwclicks = str2double(export.gateparams.btwnclicks);
        sets = str2double(export.gateparams.sets);
        trials = str2double(export.gateparams.trials);
        minbtwntrials = str2double(export.gateparams.minbtwntrials);
        behFnames = {'clicksec','btwclicks','sets','trials',...
                     'minbtwntrials'};
        spkDir = 'Y:\RawSortedSpikeData\P50_SpikeFiles';
        
        
    case 'SNr_Eye'
        
        behDataDir = 'Y:\EyeLink_Data';
        behName = strcat(spkNameCon.date,'.mat');
        behFnames = {'dv','PDS'};
        
        cd(behDataDir)
        load(behName)
        
        spkDir = 'Y:\RawSortedSpikeData\SNr_CNS_SpikeFiles';
end

% Get TTL data
cd(ttlDir)
load(cellSurgInfo.fName)
% Get Spike data
cd(spkDir)
load(cell_num)

merStData = struct2cell(mer);
merNames = fieldnames(mer);
ttlStData = struct2cell(ttlInfo);
ttlNames = fieldnames(ttlInfo);

for ttI = 1:length(ttlStData)
    humanStruct.ttlInfo.(ttlNames{ttI}) = ttlStData{ttI};
end

for mmI = 1:length(merStData)
    humanStruct.merInfo.(merNames{mmI}) = merStData{mmI};
end

for behI = 1:length(behFnames)
    humanStruct.behInfo.(behFnames{behI}) = eval(behFnames{behI});
end

humanStruct.rawSpike = eval(strcat('CElectrode',num2str(spkNameCon.elect)));

whoList = whos;
whoList2 = {whoList.name};
acdName = whoList2{cellfun(@(x) ~isempty(strfind(x,'adc')), whoList2)};


humanStruct.spikeEvents = eval(acdName);
humanStruct.cellname = cell_num;
humanStruct.expType = ExpType;
humanStruct.ttlDirectory = ttlDir; 

cd('Y:\HumanNeuronDB');

% date, depth, electrode

saveName = strcat(spkNameCon.date,'_',spkNameCon.depth,'_',spkNameCon.elect,'.mat');

save(saveName,'humanStruct');




end

