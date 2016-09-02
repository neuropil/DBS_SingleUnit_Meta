sampData = spikeDataRaw;
spkData = double(sampData);
thresh2use = 4;

thresh = round(std(double(sampData)) * thresh2use + mean(double(sampData)));
minDist = round(spkFS/1000) * 1.9;
sampLen = round(spkFS/1000);



[~,PwaveLocs] = findpeaks(double(sampData),'MinPeakHeight',thresh,...
    'MinPeakDistance',minDist);













totLen = length(1 - (sampLen/2):1 + (round(sampLen*0.8)-1));

waveForms = zeros(totLen,length(PwaveLocs));
for ai = 1:length(PwaveLocs)
    
    locP = PwaveLocs(ai);
    sampPeriod = locP - (sampLen/2):locP + (round(sampLen*0.8)-1);
    
    if any(sampPeriod > length(spkData))
        
        waveForms(:,ai) = [];
        
        break
    else
        
        waveForms(:,ai) = spkData(sampPeriod);
    end
end
%%

tempWaves = transpose(waveForms);
% Extract Features

features = struct;



% Peak
features.Peak = max(tempWaves,[],2);
% Valley
features.Valley = min(tempWaves,[],2);
% Energy
features.Energy = trapz(abs(tempWaves),2);
% Combine for WavePCA analysis


% Peak to Peak width
[~, pInd] = max(tempWaves,[],2);
[~, vInd] = min(tempWaves,[],2);

features.widthMS = (abs(pInd-vInd)/round(sampFreq))*1000;

% features.WavePC1 = pcScores(:,1);

features.FSDE_Values =...
    FSDE_Method(tempWaves);


X = [features.Peak , abs(features.Valley) ,...
    features.Energy , features.widthMS,...
    features.FSDE_Values.FDmin , features.FSDE_Values.SDmax ,...
    features.FSDE_Values.SDmin];


%%

Xa = abs(X)

normalX = bsxfun(@rdivide, Xa, max(Xa));

eva = evalclusters(normalX,'kmeans','DaviesBouldin','KList',1:10)
plot(eva)

numClusts =  eva.OptimalK;

c = clusterdata(X,'distance','euclidean','linkage','ward','maxclust',5);

clust = zeros(size(X,1),6);
for i=1:6
    clust(:,i) = kmeans(X,i,'emptyaction','singleton',...
        'replicate',5);
end


idx2 = kmeans(normalX,5,'Distance','cityblock');
idx3 = kmeans(X,3,'Distance','cityblock');
idx4 = kmeans(X,4,'Distance','cityblock');

eva2 = evalclusters(X,clust,'gap')
eva3 = evalclusters(X,idx3,'CalinskiHarabasz')
eva4 = evalclusters(X,idx4,'CalinskiHarabasz')

figure;
[silh3,h] = silhouette(normalX,idx2,'cityblock');
h = gca;
h.Children.EdgeColor = [.8 .8 1];
xlabel 'Silhouette Value';
ylabel 'Cluster';




nSpikes = size(normalX,1);

IsolDist = zeros(max(idx2),1);
Lratio = zeros(max(idx2),1);

for i = 1:max(idx2)
    
    ClusterSpikes = find(idx2 == i);
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
        [sorted order] = sort(mNoise);
        IsolDist(i) = sorted(nClusterSpikes);
    else
        IsolDist(i) = NaN;
    end
    
end



%%

for ti = 1:max(idx3 )
    plot(X(idx3  == ti,1),X(idx3 == ti,2),'.')
    hold on
end


% CHECK waveforms
cols = 'rgbkm';
nums = [1,2,5];
for ti = 1:3
    
    
    plot(mean(tempWaves(idx2 == nums(ti),:)),'Color',cols(ti))
    hold on
    ylim([-5000 5000])
    
end


%%

normalX = bsxfun(@rdivide, X, max(X));

coeff = pca(normalX');

Tdata = coeff(:,1:3);

eva = evalclusters(Tdata,'kmeans','DaviesBouldin','KList',1:10);

numClusts =  eva.OptimalK;

c = clusterdata(Tdata,'distance','euclidean','linkage','ward','maxclust',numClusts);

for ti = 1:max(c )
    plot3(Tdata(c  == ti,1),Tdata(c  == ti,2),Tdata(c  == ti,3),'.')
    hold on
end


% CHECK waveforms
cols = 'rgb';
for ti = 1:max(c )
    
    figure;
    plot(tempWaves(c == ti,:)','Color',cols(ti))
    ylim([-15000 15000])
    
end
silhouette(Tdata,c)

%%
x=tData(:,1);
y=tData(:,2);
%plot different clusters
figure
for i=1:max(clustLabel)
    hold on
    scatter(x(clustLabel==i),y(clustLabel==i),'filled');
end

plotmatrix(normalX)

%% CHECK DEBSCAN output

% Start with 0.5
% Check num clusts
% Run on several examples for normalX data

numS = 1:size(normalX,2);
combs = nchoosek(v,2);


for si = 1:(size(combs,1))
    
    tempDat = normalX(:,combs(si,:));
    
    loopCheck = 1;
    
    eps = 0.5;
    
    while loopCheck
        
        [clustLabel, varType] = dbscan(tempDat, 10, eps);
        
        numClusts = max(clustLabel);
        
        if numClusts > 1
            loopCheck = 0;
        else
            
            eps = eps - 0.05;
            
            if eps < 0
                break
            end
            
            disp(eps)
        end
        
        
    end
    
    for ti = 1:max(clustLabel)
        plot(tempDat(clustLabel == ti,1),tempDat(clustLabel == ti,2),'.')
        hold on
    end
    
    
    pause
    close all
    
    
    
    
end


%%
[C, ptsC, centres] = dbscan3(tempDat', 0.2, 20);
for ti = 1:max(ptsC)
    plot(tempDat(ptsC == ti,1),tempDat(ptsC == ti,2),'.')
    hold on
end

%%

c = clusterdata(tempDat,'distance','chebychev','linkage','ward','maxclust',2);

for ti = 1:max(c )
    plot(tempDat(c  == ti,1),tempDat(c  == ti,2),'.')
    hold on
end

%%


X = [features.Peak , abs(features.Valley) ,...
    features.Energy , features.widthMS,...
    features.FSDE_Values.FDmin , features.FSDE_Values.SDmax ,...
    features.FSDE_Values.SDmin];

X1 = X(:,[1:3 5 7]);

normalX = bsxfun(@rdivide, X, max(X));

coeff = pca(normalX');

Tdata = coeff(:,1:3);

eva = evalclusters(Tdata,'kmeans','DaviesBouldin','KList',1:8);

numClusts =  eva.OptimalK;

c = clusterdata(Tdata,'distance','euclidean','linkage','ward','maxclust',2);


for ti = 1:max(c )
    plot3(Tdata(c  == ti,1),Tdata(c  == ti,2),Tdata(c  == ti,3),'.')
    hold on
end

% CHECK waveforms
cols = 'rgb';
for ti = 1:max(c )
    
    %     figure;
    plot(tempWaves(c == ti,:)','Color',cols(ti))
    hold on
    
end






%% FINAL CODE
%%%%%%%%%%%%%%%%%% FORMALIZE

%% STEP 1 LOAD DATA
% cd('E:\Dropbox\JohnAThompson_Matlab\07_15_2015');
% load('AbvTrgt_4_19997.mat');
% spikeDataRaw = CElectrode2;

cd('Y:\PreProcessEphysData\07_15_2015');
load('AbvTrgt_37_03772.mat');
spikeDataRaw = CElectrode1;


sampData = spikeDataRaw;
spkFS = mer.sampFreqHz;

%% STEP 2 SET PEAK FIND PARAMETERS

thresh2use = 4;

thresh = round(std(double(sampData)) * thresh2use + mean(double(sampData)));
remTh = round(std(double(sampData)) * 13 + mean(double(sampData)));
minDist = round(spkFS/1000) * 1.9;
sampLen = round(spkFS/1000);




% Find positive peak points
[~,PwaveLocs] = findpeaks(double(sampData),'MinPeakHeight',thresh,...
    'MinPeakDistance',minDist);

% Find negative peak points
%   Copy all data
sampData4neg = sampData;
%   Replace all positive points with zeros
sampData4neg(sampData4neg > 0) = 0;
%   Find positive peak from negative data
[~,NwaveLocs] = findpeaks(abs(double(sampData4neg)),'MinPeakHeight',thresh,...
    'MinPeakDistance',minDist);

[~,posNoise] = findpeaks(double(sampData),'MinPeakHeight',remTh);
%                                 
[~,negNoise] = findpeaks(abs(double(sampData4neg)),'MinPeakHeight',remTh);
                                
ind2remPPks2 = ~ismember(PwaveLocs,posNoise);
PwaveLocs = PwaveLocs(ind2remPPks2);
% 
ind2remNPks2 = ~ismember(NwaveLocs,negNoise);
NwaveLocs = NwaveLocs(ind2remNPks2);
          
numViols = 0;
violInds = false(length(NwaveLocs),1);
for pi = 1:length(PwaveLocs)
   
    tmpP = PwaveLocs(pi);
    
    if any(NwaveLocs > tmpP - 12 & NwaveLocs < tmpP + 12)
        numViols = numViols + 1;
        
        violInd = NwaveLocs > tmpP - 12 & NwaveLocs < tmpP + 12;
        
        violInds(violInd) = 1;
        
    else
        continue
    end
  
end

NwaveLocs = NwaveLocs(~violInds);


%% STEP 3 EXTRACT WAVEFORMS
tic;
totLen = length(1 - (sampLen/2):1 + (round(sampLen*0.8)-1));
PwaveForms = zeros(totLen,length(PwaveLocs));
for ai = 1:length(PwaveLocs)
    
    locP = PwaveLocs(ai);
    sampPeriod = locP - (sampLen/2):locP + (round(sampLen*0.8)-1);
    
    if any(sampPeriod > length(spikeDataRaw))
        
        PwaveForms(:,ai) = [];
        
        break
    else
        PwaveForms(:,ai) = spikeDataRaw(sampPeriod);
    end
end
toc







%%

NwaveForms = zeros(totLen,length(NwaveLocs));
for ai = 1:length(NwaveLocs)
    
    locP = NwaveLocs(ai);
    sampPeriod = locP - (sampLen/2):locP + (round(sampLen*0.8)-1);
    
    if any(sampPeriod > length(spikeDataRaw))
        
        NwaveForms(:,ai) = [];
        
        break
    else
        
        NwaveForms(:,ai) = (spikeDataRaw(sampPeriod))*-1;
    end
end

waveForms = [NwaveForms , PwaveForms];

%%



    close all
    plot(waveForms,'k')
    hold on
    ylim([-8000 8000])
    









%% STEP 3 EXTRACT WAVEFORMS

totLen = length(1 - (sampLen/2):1 + (round(sampLen*0.8)-1));

waveForms = zeros(totLen,length(PwaveLocs));
for ai = 1:length(PwaveLocs)
    
    locP = PwaveLocs(ai);
    sampPeriod = locP - (sampLen/2):locP + (round(sampLen*0.8)-1);
    
    if any(sampPeriod > length(spkData))
        
        waveForms(:,ai) = [];
        
        break
    else
        
        waveForms(:,ai) = spkData(sampPeriod);
    end
end

%% STEP 4 COMPILE FEATURES

tempWaves = transpose(waveForms);

features = struct;

% Peak
features.Peak = max(tempWaves,[],2);
% Valley
features.Valley = min(tempWaves,[],2);
% Energy
features.Energy = trapz(abs(tempWaves),2);
% Combine for WavePCA analysis

% Peak to Peak width
[~, pInd] = max(tempWaves,[],2);
[~, vInd] = min(tempWaves,[],2);

features.widthMS = (abs(pInd-vInd)/round(sampFreq))*1000;

% features.WavePC1 = pcScores(:,1);

features.FSDE_Values =...
    FSDE_Method(tempWaves);

X = [features.Peak , abs(features.Valley) ,...
    features.Energy , features.widthMS,...
    features.FSDE_Values.FDmin , features.FSDE_Values.SDmax ,...
    features.FSDE_Values.SDmin];

%% STEP 5 ADJUST FEATURES

% Eliminate negative values
Xa = abs(X);

% Normalize to 0-1
normalX = bsxfun(@rdivide, Xa, max(Xa));


%% STEP 6 OBTAIN INITIAL CLUSTERS


[idxF,Cen] = kmeans(normalX,6,'Distance','cityblock',...
    'Replicates',5);

% idx2 = kmeans(normalX,5,'Distance','cityblock');

% Refine

nSpikes = size(normalX,1);

IsolDist = zeros(max(idxF),1); % > 20
Lratio = zeros(max(idxF),1); % < 0.4

for i = 1:max(idxF)
    
    ClusterSpikes = find(idxF == i);
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



if any(IsolDist < 20 | Lratio > 0.4)
    
    % Take bad cluster points and reassign two kept centroids
    % Step 1
    
    badClustInd = find(IsolDist < 20 | Lratio > 0.4);
    badClustNum = numel(badClustInd);
    
    goodCens = Cen(~(IsolDist < 20 | Lratio > 0.4),:);
    goodCenID = find(~(IsolDist < 20 | Lratio > 0.4));
    %
    badClustInfo = struct;
    for bci = 1:badClustNum
        
        bciId = badClustInd(bci);
        
        badCltPts = find(idxF == bciId);
        
        reaSSign = zeros(length(badCltPts),3);
        for reAs = 1:numel(badCltPts);
            
            tempPoint = normalX(badCltPts(reAs),:);
            reaSSign(reAs,1) = idxF(badCltPts(reAs));
            
            cenDists = zeros(3,1);
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
    
    % Copy clust id
    newidxF = idxF;
    for nci = 1:length(fieldnames(badClustInfo));
        
        bdID = badClustInd(nci);
        ptInd = badClustInfo.(strcat('bdC_', num2str(bdID))).bdPts;
        newidxF(ptInd) = badClustInfo.(strcat('bdC_', num2str(bdID))).reCls(:,3);

    end
    
end

%%%% RECALCULATE

IsolDistN = zeros(numel(goodCenID),1); % > 20
LratioN = zeros(numel(goodCenID),1); % < 0.4

for i = 1:numel(goodCenID)
    
    cID = goodCenID(i);
    
    ClusterSpikes = find(newidxF == cID);
    nClusterSpikes = length(ClusterSpikes);
    NoiseSpikes = setdiff(1:nSpikes, ClusterSpikes);
    m = mahal(normalX, normalX(ClusterSpikes,:));
    
    mCluster = m(ClusterSpikes);
    mNoise = m(NoiseSpikes);
    
    df = size(normalX,2);
    
    L = sum(1-chi2cdf(m(NoiseSpikes),df));
    LratioN(i) = L/nClusterSpikes;
    
    
    InClu = ismember(1:nSpikes, ClusterSpikes);
    if (nClusterSpikes < nSpikes/2)
        [sorted, ~] = sort(mNoise);
        IsolDistN(i) = sorted(nClusterSpikes);
    else
        IsolDistN(i) = NaN;
    end
    
end





%%



% c = clusterdata(X,'distance','euclidean','linkage','ward','maxclust',5);
% 


cols = 'rgbkm';
% nums = [1,2,5];
for ti = 1:numel(goodCenID)
    nuM = goodCenID(ti);
    
    plot(mean(tempWaves(newidxF == nuM,:)),'Color',cols(ti))
    hold on
    ylim([-5000 5000])
    
end


