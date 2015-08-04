function [] = SNr_DM_SpikeAnalysis_v01(eleFile,date,AOfile,eyeLink)


%% To do

% 1). Fix PSTH cut off


%% Event Times from AO preprocessed data Spike Time from Offline Sorter

%%%%%%%%%%%%%%%%%%%%%%% CASE 1 from 07/08/2015
% Recording data 00077

% Electrode Example 1: 07082015_srg1_set1_a50_00077_1.mat
% Electrode Example 2: 07082015_srg1_set1_a50_00077_2.mat
% Electrode Example 3: 07082015_srg1_set1_a50_00077_3.mat




%%%%%%%%%%%%%%%%%%%%%% CASE 2 from 07/30/2015
% Recording data 

% Electrode Example 1: 
% Electrode Example 2:
% Electrode Example 3:



% Load raw spike information sampling frequency
cd('Y:\RawSortedSpikeData\SNr_CNS_SpikeFiles')
load(eleFile,'adc001');

%%

%%%%%%%%%%%%%%%%%%%%%%% CASE 1 from 07/08/2015
% Date Example 1: 07_08_2015
% TTL Example 1:AbvTrgt_50_00077.mat

%%%%%%%%%%%%%%%%%%%%%% CASE 2 from 07/30/2015
% Date Example 1: 07_30_2015
% TTL Example 1: 

% Load raw TTL information time stamps and frequency
dateLoc = strcat('Y:\PreProcessEphysData\',date);
cd(dateLoc)
load(AOfile,'ttlInfo','mer')

%% Load Eyelink data

%%%%%%%%%%%%%%%%%%%%%%% CASE 1 from 07/08/2015
% EyeLink Example 1: DJ07082015.mat


%%%%%%%%%%%%%%%%%%%%%% CASE 2 from 07/30/2015
% EyeLink Example 1: DJ07302015.mat

cd('Y:\EyeLink_Data')

load(eyeLink)

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
clusterS = adc001(:,2); %#ok<NODEF>
% Time stamps 
timestamps = adc001(:,3);
% Cluster indices
numClusts = max(clusterS);
allClusts = struct;
for clI = 1:numClusts
   tempClusInd = clusterS == clI;
   allClusts.(strcat('clust',num2str(clI))).index = tempClusInd;
   tempClusTimes = timestamps(tempClusInd);
   allClusts.(strcat('clust',num2str(clI))).clustTimes = tempClusTimes;
   % Set Spike Timestamps with respect to AO start time
   allClusts.(strcat('clust',num2str(clI))).spkTimes = mer.timeStart + tempClusTimes;
end

% Number of trials 
numtrials = sum(ttRealInd1);

%% Extract Spikes for each trial

% Cell Array of trial Spikes by trial number
for cli2 = 1:numClusts
    
    tempSpkTimes = allClusts.(strcat('clust',num2str(cli2))).spkTimes;
    trialSpks = cell(1,numtrials);
    for i = 1:numtrials
        % Get spike indices by Trial time borders
        trialspkInd = tempSpkTimes >= ttlTimes2use(i) &...
            tempSpkTimes <= ttlTimes2use(i) + trialDuration(i);
        % Get spikes times
        actSpkTimes = tempSpkTimes(trialspkInd);
        
        if numel(actSpkTimes) == 0
            continue
        else
            trialSpks{i} = actSpkTimes - ttlTimes2use(i);
        end
    end
    
    allClusts.(strcat('clust',num2str(cli2))).trialSpikes = trialSpks;

end

%%

% Trial Points
fixPointOn = PDS.timing.fpon(~isnan(PDS.timing.fpon(:,1)),1);
motionOn = PDS.timing.motionon(~isnan(PDS.timing.motionon(:,1)),1);
targetOn = PDS.timing.targon(~isnan(PDS.timing.targon(:,1)),1);


for clustI3 = 1:numClusts
    
    tempSpkTimes = allClusts.(strcat('clust',num2str(clustI3))).trialSpikes;
    
    figure;
    subplot(2,1,1);
    botY = 0;
    topY = 1;
    
    for ni = 1:numtrials
        
        tsPikes = allClusts.(strcat('clust',num2str(clustI3))).trialSpikes{ni};
        
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
    
    edges = 0:0.25:round(max(trialDuration));
    peth = nan(length(edges),numtrials);
    
    for jj = 1:numtrials
        histCs = histcounts(tempSpkTimes{1,jj},edges)./0.25;
        peth(histCs~=0,jj) = histCs(histCs~=0);
    end
    
    peth = peth';
    
    meanFR = nanmean(peth);
    meanFR(isnan(meanFR)) = 0;
%     stdFR = nanstd(peth);
%     upSTDfr = meanFR + stdFR;
%     dnSTDfr = meanFR - stdFR;
    maxFR = round(max(meanFR));
    
    subplot(2,1,2);
    hold on
    plot(edges,meanFR,'k');
%     plot(edges,upSTDfr,'r');
%     plot(edges,dnSTDfr,'r');
%     barH = bar(meanFR);
%     barH.FaceColor = 'black';


    set(gca,'YTick',[0 round(maxFR/2) maxFR]);
    set(gca,'YLim',[0 maxFR]);
    ylabel('Mean FR (Hz)');
    xlim([0 8])
    set(gca,'XTick',[0 round(length(histCs)/2) length(histCs)]);
    set(gca,'XTickLabel',[0 round(max(trialDuration)/2) round(max(trialDuration))]);
    xlabel('Time (s)')
    title('PSTH')
    
    
end


end

