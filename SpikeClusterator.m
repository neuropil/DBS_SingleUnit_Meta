function [] = SpikeClusterator(rawSpikeData, sampFreq)

% Raw spike data
tempSpkData = double(rawSpikeData);
% Sampling Frequency
% sampFreq = mer.sampFreqHz; % THIS NEEDS to CHANGE

%% DETERMINE NEW PEAK FIND

% http://www.mathworks.com/help/signal/examples/peak-analysis.html


handles.params = set_parameters_AS(sampFreq);

[thrOut] = SpikeThresholdCreate(tempSpkData, handles, 'Min9sig');

filtSpkData = thrOut.Filtered;

threshold = thrOut.AveThresh;

[jat_Struct] = SpikeTimeExtract(filtSpkData, threshold, handles);

%%

plot(jat_Struct.spkWaveforms','k')

%%

% Extract Features

features = struct;

% Reduce dimensions and extract Waveforms of interest
tempWaves = jat_Struct.spkWaveforms;

% Peak
features.Peak = max(tempWaves,[],2);
% Valley
features.Valley = min(tempWaves,[],2);
% Energy
features.Energy = trapz(abs(tempWaves),2);
% Combine for WavePCA analysis
featsForPCA = horzcat(features.Peak,...
    features.Valley,...
    features.Energy);
% WavePC1
[~,pcScores,~] =...
    princomp(featsForPCA);

% Peak to Peak width
[~, pInd] = max(tempWaves,[],2);
[~, vInd] = min(tempWaves,[],2);

features.widthMS = (abs(pInd-vInd)/round(sampFreq))*1000;

% features.WavePC1 = pcScores(:,1);

features.FSDE_Values =...
    FSDE_Method(tempWaves);

%%

% Derive Gaussian fit parameters for positive and negative
% component of waveform (Felsen and Thompson method)
% [features.WaveFitParams] = WaveFormFit_AS(tempWaves, size(tempWaves,2));

%%
% plot(jat_Struct.spkWaveforms(features.WaveFitParams.noise,:)','k')
% hold on
% plot(jat_Struct.spkWaveforms(~features.WaveFitParams.noise,:)','r')

% normalize features

% X = [features.Peak , features.Valley ,...
%      features.Energy , features.WavePC1 ,...
%      features.FSDE_Values.FDmin , features.FSDE_Values.SDmax ,...
%      features.FSDE_Values.SDmin , features.WaveFitParams.gauss_fit_neg_width ,...
%      features.WaveFitParams.gauss_fit_pos_width];


X = [features.Peak , features.Valley ,...
    features.Energy ,...
    features.FSDE_Values.FDmin , features.FSDE_Values.SDmax ,...
    features.FSDE_Values.SDmin, features.widthMS];

normalX = bsxfun(@rdivide, X, max(X));


%% HOW TO DETERMINe THE best number of clusters

X1 = X(:,[1:3 5 7]);

clust = zeros(size(normalX,1),6);
for i=1:6
clust(:,i) = kmeans(normalX,i,'emptyaction','singleton',...
        'replicate',5);
end


eva1 = evalclusters(normalX,'kmeans','DaviesBouldin','KList',1:6);
eva2 = evalclusters(normalX,'gmdistribution','gap','KList',1:6);
eva3 = evalclusters(normalX,'kmeans','gap','KList',1:6);
%%
figure;
plot(eva1);
disp(eva1.OptimalK);
figure;
plot(eva2);
disp(eva2.OptimalK);
figure;
plot(eva3);
disp(eva3.OptimalK);

% numClusts =  eva1.OptimalK;

%%

Xn = normalX;
Yn = reshape(1:numel(normalX),size(normalX,1),size(normalX,2));
plotmatrix(Xn,Yn)


%%

% c = clusterdata(X1,'mahalanobis','linkage','ward','maxclust',3);
c = clusterdata(normalX,'distance','chebychev','linkage','ward','maxclust',2);
% Plot the data with each cluster shown in a different color.
figure
plot(normalX(c == 1,2),normalX(c == 1,3))

%%

filtWave = jat_Struct.spkWaveforms(~features.WaveFitParams.noise,:);
cfilt = c(~features.WaveFitParams.noise);
%%
figure;
subplot(1,4,1);
plot(filtWave(cfilt==1,:)','r')
ylim([-6000 6000]);
subplot(1,4,2);
plot(filtWave(cfilt==2,:)','g')
ylim([-6000 6000]);
subplot(1,4,3);
plot(filtWave(cfilt==3,:)','b')
ylim([-6000 6000]);
subplot(1,4,4);
plot(filtWave(cfilt==4,:)','k')
ylim([-6000 6000]);

figure;
plot(mean(filtWave(cfilt==1,:))','r-','LineWidth',2)
hold on
plot(mean(filtWave(cfilt==2,:))','g-','LineWidth',2)
plot(mean(filtWave(cfilt==3,:))','b-','LineWidth',2)
plot(mean(filtWave(cfilt==4,:))','k-','LineWidth',2)
ylim([-6000 6000]);
xlim([0 size(filtWave,2)])




%%

load fisheriris;
X = meas(:,1:2);
[n,p] = size(X);


k = 3;
Sigma = {'diagonal','full'};
nSigma = numel(Sigma);
SharedCovariance = {true,false};
SCtext = {'true','false'};
nSC = numel(SharedCovariance);
d = 500;
x1 = linspace(min(X(:,1)) - 2,max(X(:,1)) + 2,d);
x2 = linspace(min(X(:,2)) - 2,max(X(:,2)) + 2,d);
[x1grid,x2grid] = meshgrid(x1,x2);
X0 = [x1grid(:) x2grid(:)];
threshold = sqrt(chi2inv(0.99,2));
options = statset('MaxIter',1000); % Increase number of EM iterations


c = clusterdata(normalX,'distance','chebychev','linkage','ward','maxclust',3);

tData = [normalX(:,5),normalX(:,6)];
eva3 = evalclusters(tData,'kmeans','CalinskiHarabasz','KList',1:10)
plot(eva3)

plot(tData(c == 1,1),tData(c == 1,2),'r.')
hold on
plot(tData(c == 2,1),tData(c == 2,2),'b.')

