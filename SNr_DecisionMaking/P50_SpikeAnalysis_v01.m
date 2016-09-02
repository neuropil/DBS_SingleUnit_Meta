function [outPut] = P50_SpikeAnalysis_v01(cell_Number)


%%

dbaseLoc = 'E:\Dropbox\JohnAThompson_Matlab\p50_neuronFiles\p50VimStructs';
cd(dbaseLoc)

%% To do

% 1). Fix PSTH cut off


%% Load Data
load(cell_Number)

%%
% behData = humanStruct.behInfo;
ttlInfo = humanStruct.ttlInfo;
spkEvs = humanStruct.spikeEvents;
mer = humanStruct.merInfo; 

%% TTL times from AO

% TTL time stamps
ttlTimes = humanStruct.ttlInfo.ttl_up;
ttlTimes = (ttlTimes - min(ttlTimes))/mer.sampFreqHz;

ttlTimes2use = ttlTimes;

%% Offline Sorter data

% Spike times from Offline sorter (i.e. tempClusInd) are arbitrarily relative to 0

% mer.timeStart is the start of the clock relative to that recording depth
% start
outPut = struct;


% Cluster ID vector
clusterS = spkEvs.clustIDS; 
% Time stamps 
timestamps = humanStruct.spikeEvents.waveforms.allWavesInfo.alllocs;
% Cluster indices
uniqueIDS = unique(clusterS);
numClusts = sum(unique(clusterS) ~= 0);
clusterID = uniqueIDS(unique(clusterS) ~= 0);
allClusts = struct;
for clI = 1:numClusts
   tempClusInd = clusterS == clusterID(clI);
   allClusts.(strcat('clust',num2str(clI))).index = tempClusInd;
   
   % Zero clusTimes
   tempClusTimes = timestamps(tempClusInd);
   tempClusTimes = (tempClusTimes - min(tempClusTimes))/mer.sampFreqHz;
   
   allClusts.(strcat('clust',num2str(clI))).clustTimes = tempClusTimes;
   % Set Spike Timestamps with respect to AO start time
   allClusts.(strcat('clust',num2str(clI))).spkTimes = ((mer.timeStart)/mer.sampFreqHz) + tempClusTimes;
end

% Number of trials 
numtrials = numel(ttlTimes2use);

%% Extract Spikes for each trial

% Trial Points
firstClick = 0.1;
secondClick = firstClick + humanStruct.behInfo.clicksec;

trialDur = secondClick + 2.8; % in secs

%%

% Cell Array of trial Spikes by trial number
for cli2 = 1:numClusts
    
    tempSpkTimes = allClusts.(strcat('clust',num2str(cli2))).spkTimes;
    trialSpks = cell(1,numtrials);
    for i = 1:numtrials
        % Get spike indices by Trial time borders
        trialspkInd = tempSpkTimes >= ttlTimes2use(i) &...
            tempSpkTimes <= ttlTimes2use(i) + trialDur;
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



%%

for clustI3 = 1:numClusts
    
    tempSpkTimes = allClusts.(strcat('clust',num2str(clustI3))).trialSpikes;
    
    figure;
    subplot(2,1,1);
    botY = 0;
    topY = 1;
    
    chSpikes = allClusts.(strcat('clust',num2str(clustI3))).trialSpikes;
    if sum(cellfun(@(x) ~isempty(x), chSpikes)) == 0
        continue
    end
    
    
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
        line([tsPikes ; tsPikes], [botS ; topS],'LineStyle','-','Color','k','LineWidth',0.5)
        
        % Trial Events
        
        % First Click
        line([firstClick ; firstClick], [botS ; topS],'LineStyle','-','Color','r','LineWidth',1)
        % Second Click
        line([secondClick ; secondClick], [botS ; topS],'LineStyle','-','Color','g','LineWidth',1)

        
        botY = topY;
        topY = topY + 1;
        
    end
    
    meanFix = firstClick;
    meanMot = secondClick;

    
    ylim([0 topY - 0.5]);
    xlim([0 trialDur]);
    title('Raster of Spikes P50 clicks');
    xlabel('Time (s)')
    ylabel('Trial #')
    xtickIDS = [meanFix,meanMot,0,...
        round(trialDur/2,2), trialDur];
    [xTickVals,xTickInds] = sort(xtickIDS);
    set(gca,'XTick',xTickVals)
    
    meanNames = {'1st Click','2nd Click'};
    xtickStr = cell(1,length(xtickIDS));
    
    xtickStr(ismember(xTickInds,[1 2])) = meanNames;
    nums2convert = num2cell(xTickVals(~ismember(xTickInds,[1 2])));
    convertNums = cellfun(@(x) num2str(x), nums2convert,'UniformOutput',false);
    xtickStr(~ismember(xTickInds,[1 2])) = convertNums;
    
    set(gca,'XTickLabel',xtickStr)
    set(gca,'YTick',[1 round(botY/2) botY])
    set(gca,'XTickLabelRotation', -45) 

    timeBin = 0.1;
    edges = 0:timeBin:trialDur;
    peth = nan(length(edges)-1,numtrials);
    xAxisPETH = linspace(0,trialDur,length(edges)-1);
    
    for jj = 1:numtrials
        fRs = histcounts(tempSpkTimes{1,jj},edges)./timeBin;
        peth(:,jj) = fRs';
    end
      
    meanFR = nanmean(peth,2);
    
    stdPETH = peth';
    stdFR = nanstd(stdPETH); %#ok<UDIM>
    meanFR2plot = meanFR(~isnan(meanFR));
%     edges2plot = edges(~isnan(meanFR));
    std2plot = stdFR(~isnan(meanFR));
    
    semFR = transpose(std2plot/sqrt(numtrials));
    upSEM = meanFR2plot + semFR;
    dnSEM = meanFR2plot - semFR;
%     stdFR = nanstd(peth);
%     upSTDfr = meanFR + stdFR;
%     dnSTDfr = meanFR - stdFR;
    maxFR = ceil(max(upSEM));
    
    subplot(2,1,2);
    hold on
    plot(xAxisPETH,meanFR2plot,'k');
    plot(xAxisPETH,upSEM,'r');
    plot(xAxisPETH,dnSEM,'r');
%     barH = bar(meanFR);
%     barH.FaceColor = 'black';


    set(gca,'YTick',[0 round(maxFR/2,2) maxFR]);
    set(gca,'YLim',[0 maxFR]);
    
    ylabel('Mean FR (Hz)');
    xlim([0 trialDur])
    set(gca,'XTick',[0 round(trialDur/2,2) trialDur]);

    xlabel('Time (s)')
    title('PSTH')
    
    [~,fName,~] = fileparts(cell_Number);
    figName = strcat(fName,'_c_',num2str(clustI3),'.jpg');
    cd('Y:\TempP50images')
    saveas(gcf,figName);
    close all
    
    outPut.(strcat('c',num2str(clustI3))).timeBin = timeBin;
    outPut.(strcat('c',num2str(clustI3))).edges = edges;
    outPut.(strcat('c',num2str(clustI3))).peth = peth;
    outPut.(strcat('c',num2str(clustI3))).xAxisPETH = xAxisPETH;
    outPut.(strcat('c',num2str(clustI3))).Name = figName;
end



end

