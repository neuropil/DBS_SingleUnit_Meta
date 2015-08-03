%% Event Times from AO preprocessed data Spike Time from Offline Sorter
% CASE from 07/08/2015
% Recording data 00077

% Load raw spike information sampling frequency
cd('Y:\RawSortedSpikeData\SNr_CNS_SpikeFiles')
load('07082015_srg1_set1_a50_00077_1.mat');

%%

% Load raw TTL information time stamps and frequency
cd('Y:\PreProcessEphysData\07_08_2015')
load('AbvTrgt_50_00077.mat','ttlInfo','mer')

%% Load Eyelink data

cd('Y:\EyeLink_Data')
load('DJ_07082015.mat')

trialDuration = PDS.timing.trialend(~isnan(PDS.timing.trialend));

%% TTL times from AO

% TTL time stamps
ttlTimes = ttlInfo.ttlTimesUp;
% Extract real time stamp index for TTL
dtemp = diff(ttlInfo.ttl_up)/(ttlInfo.ttl_sf*1000);
% TTL time stamps with duration greater than 5.5 seconds
ttRealInd1 = dtemp > 0.4 & dtemp < 1;
% TTL times
ttlTimes2use = ttlTimes(ttRealInd1);

%% Offline Sorter data

% Cluster ID vector
cluster = adc001(:,2);
% Time stamp 
timestamps = adc001(:,3);
% Cluster 1 index 
cluster1ts = timestamps(cluster == 1);
% Set Spike Timestamps with respect to AO start time
spkTimes = mer.timeStart + cluster1ts;
% Number of trials for cluster 1
numtrials1 = sum(ttRealInd1);

%% Extract Spikes for each trial

% Cell Array of trial Spikes by trial number
trialSpks = cell(1,numtrials1);
for i = 1:numtrials1
    % Get spike indices by Trial time borders
    trialspkInd = spkTimes >= ttlTimes2use(i) & spkTimes <= ttlTimes2use(i) + trialDuration(i);
    % Get spikes times
    actSpkTimes = spkTimes(trialspkInd);
    
    if numel(actSpkTimes) == 0
        continue
    else
        trialSpks{i} = actSpkTimes - ttlTimes2use(i);
    end

end

%%

figure;
subplot(2,1,1);
botY = 0;
topY = 1;

% Trial Points
fixPointOn = PDS.timing.fpon(~isnan(PDS.timing.fpon(:,1)),1);
motionOn = PDS.timing.motionon(~isnan(PDS.timing.motionon(:,1)),1);
targetOn = PDS.timing.targon(~isnan(PDS.timing.targon(:,1)),1);

for ni = 1:numtrials1
    
    tsPikes = trialSpks{ni};
    
    if isempty(tsPikes);
        botY = topY;
        topY = topY + 1;
        continue
    end
    
    botS = repmat(botY,1,length(tsPikes));
    topS = repmat(topY,1,length(tsPikes));
    
    % Spikes
    line([tsPikes' ; tsPikes'], [botS ; topS],'LineStyle','-','Color','k','LineWidth',0.75)
    
    % Trial Events
    
    % Fixation Point
    line([fixPointOn(ni) ; fixPointOn(ni)], [botS ; topS],'LineStyle','-','Color','r','LineWidth',1)
    % Motion On
    line([motionOn(ni) ; motionOn(ni)], [botS ; topS],'LineStyle','-','Color','g','LineWidth',1)
    % Target On
    line([targetOn(ni) ; targetOn(ni)], [botS ; topS],'LineStyle','-','Color','b','LineWidth',1)
    
    botY = topY;
    topY = topY + 1;
    
end

meanFix = round(mean(fixPointOn),2);
meanMot = round(mean(motionOn),2);
meanTar = round(mean(targetOn),2);

ylim([0 topY - 0.5]);
xlim([0 max(trialDuration)]);
title('Raster of Spikes during RMDT trials');
xlabel('Time (s)')
ylabel('Trial #')
xtickIDS = [meanFix,meanMot,meanTar,0,...
    round(max(trialDuration)/2), round(max(trialDuration))];
[xTickVals,xTickInds] = sort(xtickIDS);
set(gca,'XTick',xTickVals)

meanNames = {'Fixation','Motion','Target'};
xtickStr = cell(1,length(xtickIDS));

xtickStr(ismember(xTickInds,[1 2 3])) = meanNames;
nums2convert = num2cell(xTickVals(~ismember(xTickInds,[1 2 3])));
convertNums = cellfun(@(x) num2str(x), nums2convert,'UniformOutput',false);
xtickStr(~ismember(xTickInds,[1 2 3])) = convertNums;

set(gca,'XTickLabel',xtickStr)
set(gca,'YTick',[1 round(botY/2) botY])

edges = 0:0.1:round(max(trialDuration));
peth = zeros(length(edges)-1,numtrials1);

for jj = 1:numtrials1
    histCs = histcounts(trialSpks{1,jj},edges)./0.1;
    peth(:,jj) = histCs;
end

peth = peth';

meanFR = mean(peth);
maxFR = round(max(meanFR));

subplot(2,1,2);

barH = bar(meanFR);
barH.FaceColor = 'black';

set(gca,'YTick',[1 round(maxFR/2) maxFR]);
set(gca,'YLim',[0 maxFR]);
ylabel('Mean FR (Hz)');
xlim([0 length(peth)])
set(gca,'XTick',[0 40 80]);
set(gca,'XTickLabel',[0 round(max(trialDuration)/2) round(max(trialDuration))]);
xlabel('Time (s)')
title('PSTH')


%% Eye Link data

cd('Y:\EyeLink_Data')
load('DJ_07082015.mat')
