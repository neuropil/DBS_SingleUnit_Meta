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

features.WavePC1 = pcScores(:,1);

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
    features.Energy , features.WavePC1 ,...
    features.FSDE_Values.FDmin , features.FSDE_Values.SDmax ,...
    features.FSDE_Values.SDmin];

%% HOW TO DETERMINe THE best number of clusters

X1 = X(:,[1:3 5 7]);
eva = evalclusters(X1,'kmeans','DaviesBouldin','KList',1:6);
% eva = evalclusters(X1,'kmeans','CalinskiHarabasz','KList',1:7);

numClusts =  eva.OptimalK;

%%


% c = clusterdata(X1,'mahalanobis','linkage','ward','maxclust',3);
c = clusterdata(X1,'distance','chebychev','linkage','ward','maxclust',numClusts);
% Plot the data with each cluster shown in a different color.
figure
scatter3(X1(:,1),X1(:,2),X1(:,4),10,c)

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





