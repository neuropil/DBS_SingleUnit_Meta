%% FINAL CODE
%%%%%%%%%%%%%%%%%% FORMALIZE

%% STEP 1 LOAD DATA
cd('Y:\PreProcessEphysData\07_15_2015');
load('AbvTrgt_37_03772.mat');
% spikeDataRaw = CElectrode1;
spikeDataRaw = CElectrode2;
sampData = spikeDataRaw;
spkData = double(sampData);
spkFS = mer.sampFreqHz;

%% STEP 2 SET PEAK FIND PARAMETERS

thresh2use = 5;

thresh = (round(std(double(sampData)) * thresh2use) + mean(double(sampData)));
noise = (round(std(double(sampData)) * 12) + mean(double(sampData)));
minDist = round(spkFS/1000) * 1.9;
sampLen = round(spkFS/1000);


%% STEP 3 EXTRACT WAVEFORMS

[ waveData ] = extractWaveforms_Clz_v01(spkData, thresh, noise, minDist, spkFS);

waveForms = waveData.allWaves.waves;

%% STEP 4 COMPILE FEATURES

[ xFeats ] = createSpkFeatures( waveForms, spkFS  );


%% STEP 6 OBTAIN INITIAL CLUSTERS

[metricData, clustIDn] = spkClusterQual(featData,clustID,stage);

[idxF,Cen] = kmeans(normalX,6,'Distance','cityblock',...
    'Replicates',5);

nSpikes = size(normalX,1);

IsolDist = zeros(max(idxF),1); % > 20
Lratio = zeros(max(idxF),1); % < 0.4

for i = 1:max(idxF)
    
    ClusterSpikes = find(idxF == i);
    
    if length(ClusterSpikes) < size(normalX,2)
        Lratio(i) = 0.8;
        IsolDist(i) = 5;
        continue
    end
    
    nClusterSpikes = length(ClusterSpikes);
    NoiseSpikes = setdiff(1:nSpikes, ClusterSpikes);
    m = mahal(normalX, normalX(ClusterSpikes,:));
    
    mCluster = m(ClusterSpikes);
    mNoise = m(NoiseSpikes);
    
    df = size(normalX,2);
    
    L = sum(1-chi2cdf(m(NoiseSpikes),df));
    Lratio(i) = L/nClusterSpikes;
    
    
    InClu = ismember(1:nSpikes, ClusterSpikes);
    if (nClusterSpikes < nSpikes/2)
        [sorted, ~] = sort(mNoise);
        IsolDist(i) = sorted(nClusterSpikes);
    else
        IsolDist(i) = NaN;
    end
    
end

%% STEP 7 REFINE CLUSTERS

% ClustIDs
% FeatureMatrix
% IsolationDistance
% Lratio
% ClustCents

% Take bad cluster points and reassign two kept centroids
% 1. Get index of bad clusters
% 2. For Bad Cluster do the following
%   a. Get indices for FeatureMatrix
%   b. For each point in Bad Cluster do the following
%       i. Get euclidean distance from each acceptable cluster
%       ii. Reassign cluster id to the closest acceptable cluster

clustREFINE = true;

while clustREFINE
    
    if all(IsolDist < 20 | Lratio > 0.4)
        
        wavePlotfun_Clz(waveData);
        figure;
        
        eMean = mean(sampData);
        eOneSD = std(double(sampData));
        pthre = eMean + (eOneSD*2);
        nthre = (eMean + (eOneSD*2))*-1; 
        
        midRePts = ~(sampData < pthre & sampData > nthre);

        plot(find(midRePts),...
            sampData(midRePts),...
            'Color','r')

        line([0 length(sampData2rem)],[thresh thresh],'LineStyle','--','LineWidth',2,...
            'Color','k')
        line([0 length(sampData2rem)],[thresh*-1 thresh*-1],'LineStyle','--','LineWidth',2,...
            'Color','k')
        % Remove everything but 4 SDs and up
        % Plot raw data
        % Plot upper and lower bounds of threshold
        figure;
        tWaves = transpose(waveData.allWaves.waves);
        cols = 'rgbkmc';
        % nums = [1,2,5];
        for ti = 1:max(idxF)
            
            
            
            plot(mean(tWaves(idxF == ti,:)),'Color',cols(ti))
            hold on
            ylim([-4000 4000])
            
        end

        
        
        
        disp('All clusters are bad')
        break
        
    
    elseif any(IsolDist < 20 | Lratio > 0.4)
        
        
        % Take bad cluster points and reassign two kept centroids
        % Step 1
        
        badClustInd = find(IsolDist < 20 | Lratio > 0.4);
        badClustNum = numel(badClustInd);
        
        goodCens = Cen(~(IsolDist < 20 | Lratio > 0.4),:);
        goodCenID = find(~(IsolDist < 20 | Lratio > 0.4));
        Cen = Cen(goodCenID,:);
        %
        badClustInfo = struct;
        for bci = 1:badClustNum
            
            bciId = badClustInd(bci);
            
            badCltPts = find(idxF == bciId);
            
            reaSSign = zeros(length(badCltPts),3);
            for reAs = 1:numel(badCltPts);
                
                tempPoint = normalX(badCltPts(reAs),:);
                reaSSign(reAs,1) = idxF(badCltPts(reAs));
                
                cenDists = zeros(length(goodCenID),1);
                for cens = 1:size(goodCens,1);
                    
                    compDist = [goodCens(cens,:); tempPoint];
                    
                    cenDists(cens,1) = pdist(compDist,'euclidean');
                    
                end
                
                % Find minDist - assign dist and new cluster
                [minDist,minDid] = min(cenDists);
                reaSSign(reAs,2) = minDist;
                reaSSign(reAs,3) = goodCenID(minDid);
                
            end
            
            badClustInfo.(strcat('bdC_', num2str(bciId))).bdClID = bciId;
            badClustInfo.(strcat('bdC_', num2str(bciId))).bdPts = badCltPts;
            badClustInfo.(strcat('bdC_', num2str(bciId))).reCls = reaSSign;
            
        end
        
        % Reassign cluster values
        for nci = 1:length(fieldnames(badClustInfo));
            
            bdID = badClustInd(nci);
            ptInd = badClustInfo.(strcat('bdC_', num2str(bdID))).bdPts;
            idxF(ptInd) = badClustInfo.(strcat('bdC_', num2str(bdID))).reCls(:,3);
            
        end
        
        % Recompute cluster metrics
        IsolDist = zeros(numel(goodCenID),1); % > 20
        Lratio = zeros(numel(goodCenID),1); % < 0.4
        
        for i = 1:numel(goodCenID)
            
            cID = goodCenID(i);
            
            ClusterSpikes = find(idxF == cID);
            nClusterSpikes = length(ClusterSpikes);
            NoiseSpikes = setdiff(1:nSpikes, ClusterSpikes);
            m = mahal(normalX, normalX(ClusterSpikes,:));
            
            mCluster = m(ClusterSpikes);
            mNoise = m(NoiseSpikes);
            
            df = size(normalX,2);
            
            L = sum(1-chi2cdf(m(NoiseSpikes),df));
            Lratio(i) = L/nClusterSpikes;
            
            
            %InClu = ismember(1:nSpikes, ClusterSpikes);
            if (nClusterSpikes < nSpikes/2)
                [sorted, ~] = sort(mNoise);
                IsolDist(i) = sorted(nClusterSpikes);
            else
                IsolDist(i) = 21;
            end
            
        end

        % Check whether new clusters pass muster
        if any(IsolDist < 20 | Lratio > 0.4)
            
            % Fix idxf
            presNums = unique(idxF);
            newNumsC = 1:1:length(presNums);
            for ppi = 1:length(presNums);
               
                changeIND = idxF == presNums(ppi);
                idxF(changeIND) = newNumsC(ppi);
                
            end
            clustREFINE = true;
        else
            clustREFINE = false;
        end

    else
        clustREFINE = false;
    end
    
    
end
    
    







%% CHECK RESULTS


cols = 'rgbkm';
% nums = [1,2,5];
for ti = 1:numel(goodCenID)
    nuM = goodCenID(ti);
    
    plot(mean(tempWaves(idxF == nuM,:)),'Color',cols(ti))
    hold on
    ylim([-5000 5000])
    
end



%% CHECK RESULTS Part 2

% CHECK waveforms
cols = 'gkmcr';
for ti = 1:numel(goodCenID)
    nuM = goodCenID(ti);
    %     figure;
    plot(tempWaves(idxF == nuM,:)','Color',cols(ti))
    hold on
    
end

%% TEMPLATE REFINE

tempWaves = transpose(waveForms);

nClusts = numel(unique(idxF));

cid = unique(idxF);

cInd = idxF;

corVals = zeros(size(tempWaves,1),nClusts);

%%
for ni = 1:nClusts
   
    % Create Rp, Rn and Rz from clust template
    
    cidi = cid(ni);
    
    cWaves = tempWaves(cInd == cidi,:);
    
    meanCw = mean(cWaves);
    
    template = meanCw/max(meanCw);
    
    Rp = nan(size(template));
    Rn = nan(size(template));
    
    for mi = 1:length(template);
        
        tRz = template(mi);
        
        if abs(tRz) <= 0.25
            Rp(mi) = 0.25;
            Rn(mi) = -0.25;
        elseif tRz > 0.25
            Rp(mi) = max([tRz/2, 0.25]);
            Rn(mi) = Rp(mi) - 0.25;
        else
            Rn(mi) = min([tRz/2 , -0.25]);
            Rp(mi) = Rn(mi) + 0.25;
        end
        
    end
    
    
    for ai = 1:size(tempWaves,1);
        
        tWave = tempWaves(ai,:);
        tWaveN = tWave/max(meanCw);
        
        SY = nan(1,size(tWaveN,2));
        SX = template;
        
        for ti = 1:size(tWaveN,2)
            
            yi = tWaveN(ti);
            if yi < Rp(ti) && yi > Rn(ti)
                SY(ti) = 0;
            elseif yi > Rp(ti)
                SY(ti) = 1;
            elseif yi < Rn(ti)
                SY(ti) = -1;
            end
            
            xi = template(ti);
            if xi < Rp(ti) && xi > Rn(ti)
                SX(ti) = 0;
            elseif xi > Rp(ti)
                SX(ti) = 1;
            elseif xi < Rn(ti)
                SX(ti) = -1;
            end
            
        end
        
        %------------------------------------------------------------
        % To satisfy dot prod makes indicies where both zeros equal 1
        bzInd = SY == 0 & SX == 0;
        SX(bzInd) = 1;
        SY(bzInd) = 1;
        %------------------------------------------------------------
        
        SCC = sum(SY.*SX)/length(SY);
        
        corVals(ai,ni) = SCC;
        
    end

end

%% Get corVal index
[~,corValInd] = max(corVals,[],2);
% corValInd = corVals > 0.3;

colors = 'rbgck';
corInds = cell(nClusts,1);
for ni = 1:nClusts
    
    corInd = corValInd == ni & corVals(:,ni) > 0.7;
%     exThres = corVals(corValInd == ni,ni) > 0.3;
    
    
    figure;
    plot(tempWaves(corInd,:)',colors(ni))
    ylim([min(tempWaves(:)) max(tempWaves(:))]);
%     xlim([0 handles.XLIMa]);
%     handles.(strcat('clust',num2str(ni))).XTick = [];
%     handles.(strcat('clust',num2str(ni))).YTick = [];
    
    numWaves = sum(corInd);
    
    titleStr = ['Clust ', num2str(ni) , ' = '  , num2str(numWaves)];
    title(titleStr);

    figure;
    plot(mean(tempWaves(corInd,:))',colors(ni),'LineWidth',2)
    ylim([min(tempWaves(:)) max(tempWaves(:))]);
%     xlim([0 handles.XLIMa]);
%     handles.(strcat('clust',num2str(ni))).XTick = [];
%     handles.(strcat('clust',num2str(ni))).YTick = [];
    
    corInds{ni} = corInd;
    
end

%%
figure;
for ni = 1:nClusts
    
    corInd = corValInd == ni & corVals(:,ni) > 0.75;
    plot(mean(tempWaves(corInd,:))',colors(ni),'LineWidth',2)
    hold on
    
end












%% TESTING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Test 1 Bad signal





