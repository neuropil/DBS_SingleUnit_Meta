function [] = SNr_DM_SpikeAnalysis_v02(cell_Number)


%%

dbaseLoc = 'Y:\HumanNeuronDB';
cd(dbaseLoc)

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



%%

%%%%%%%%%%%%%%%%%%%%%%% CASE 1 from 07/08/2015
% Date Example 1: 07_08_2015
% TTL Example 1:AbvTrgt_50_00077.mat

%%%%%%%%%%%%%%%%%%%%%% CASE 2 from 07/30/2015
% Date Example 1: 07_30_2015
% TTL Example 1: 

% Load raw TTL information time stamps and frequency


%% Load Eyelink data

%%%%%%%%%%%%%%%%%%%%%%% CASE 1 from 07/08/2015
% EyeLink Example 1: DJ07082015.mat


%%%%%%%%%%%%%%%%%%%%%% CASE 2 from 07/30/2015
% EyeLink Example 1: DJ07302015.mat


%% Load Data
load(cell_Number)

%%
behData = humanStruct.behInfo;
ttlInfo = humanStruct.ttlInfo;
spkEvs = humanStruct.spikeEvents;
mer = humanStruct.merInfo; 

trialDuration = behData.PDS.timing.trialend(~isnan(behData.PDS.timing.trialend));

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

% Spike times from Offline sorter (i.e. tempClusInd) are arbitrarily relative to 0

% mer.timeStart is the start of the clock relative to that recording depth
% start



% Cluster ID vector
clusterS = spkEvs(:,2); 
% Time stamps 
timestamps = spkEvs(:,3);
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
fixPointOn = behData.PDS.timing.fpon(~isnan(behData.PDS.timing.fpon(:,1)),1);
motionOn = behData.PDS.timing.motionon(~isnan(behData.PDS.timing.motionon(:,1)),1);
targetOn = behData.PDS.timing.targon(~isnan(behData.PDS.timing.targon(:,1)),1);

%%

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
    
%     window = 0.25;
%     maxTime = max(trialDuration);
%     binNum = ceil(maxTime/window);
%     
%     binData = zeros(numtrials,binNum);
% 
%     for tII = 1:numtrials
%         startWin = 0;
%         endWin = window;
%         
%         for bI = 1:binNum
%             tempTrial = tempSpkTimes{1,numtrials};
%             
%             spikeNums = tempTrial >= startWin & tempTrial <= endWin;
%             
%             binData(tII,bI) = sum(spikeNums);
%             
%             startWin = startWin + window;
%             endWin = endWin + window;
%             
%         end
%     end
%     
%     meanFR = mean(binData)/window;
%     stdFR = std(binData)/window;
%     semFR = (stdFR / sqrt(numtrials))/window;
%     upFR = meanFR + semFR;
%     dnFR = meanFR - semFR;
%     
%     time = linspace(0,maxTime,binNum);
%     subplot(2,1,2);
%     hold on
%     plot(time,meanFR,'k');
%     hold on
%     plot(time,upFR,'r');
%     plot(time,dnFR,'r');
%     xlim([0 floor(maxTime)]);
    
    
    edges = 0:0.2:floor(max(trialDuration));
    peth = nan(length(edges),numtrials);
    
    for jj = 1:numtrials
        histCs = histcounts(tempSpkTimes{1,jj},edges)./0.2;
        peth(histCs~=0,jj) = histCs(histCs~=0);
    end
      
    meanFR = nanmean(peth,2);
    
    stdPETH = peth';
    stdFR = nanstd(stdPETH); %#ok<UDIM>
    meanFR2plot = meanFR(~isnan(meanFR));
    edges2plot = edges(~isnan(meanFR));
    std2plot = stdFR(~isnan(meanFR));
    
    semFR = transpose(std2plot/sqrt(numtrials));
    upSEM = meanFR2plot + semFR;
    dnSEM = meanFR2plot - semFR;
%     stdFR = nanstd(peth);
%     upSTDfr = meanFR + stdFR;
%     dnSTDfr = meanFR - stdFR;
    maxFR = round(max(upSEM));
    
    subplot(2,1,2);
    hold on
    plot(edges2plot,meanFR2plot,'k');
    plot(edges2plot,upSEM,'r');
    plot(edges2plot,dnSEM,'r');
%     barH = bar(meanFR);
%     barH.FaceColor = 'black';


    set(gca,'YTick',[0 round(maxFR/2,2) maxFR]);
    set(gca,'YLim',[0 maxFR]);
    
    ylabel('Mean FR (Hz)');
    xlim([0 edges2plot(length(edges2plot))])
    set(gca,'XTick',[0 round(edges2plot(length(edges2plot))/2,2) edges2plot(length(edges2plot))]);
    set(gca,'XTickLabel',xtickStr);
    xlabel('Time (s)')
    title('PSTH')
    
    
end


end

