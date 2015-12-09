% Extract waveforms

% Raw spike data
tempSpkData = double(CElectrode1);
% Sampling Frequency
sampFreq = mer.sampFreqHz; % THIS NEEDS to CHANGE

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

% Waveform Structure
WaveIndex = tempWaves;

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
[features.WaveFitParams] = WaveFormFit_AS(tempWaves, size(tempWaves,2));

%%
plot(jat_Struct.spkWaveforms(features.WaveFitParams.noise,:)','k')
hold on
plot(jat_Struct.spkWaveforms(~features.WaveFitParams.noise,:)','r')

% normalize features

X = [features.Peak , features.Valley ,...
     features.Energy , features.WavePC1 ,...
     features.FSDE_Values.FDmin , features.FSDE_Values.SDmax ,...
     features.FSDE_Values.SDmin , features.WaveFitParams.gauss_fit_neg_width ,...
     features.WaveFitParams.gauss_fit_pos_width];


%% HOW TO DETERMINe THE best number of clusters




X1 = X(:,1:3);
eva = evalclusters(X1,'kmeans','DaviesBouldin','KList',1:7);
numClusts =  eva.OptimalK;

%%


% c = clusterdata(X1,'mahalanobis','linkage','ward','maxclust',3);
c = clusterdata(X1,'distance','chebychev','linkage','ward','maxclust',numClusts);
% Plot the data with each cluster shown in a different color.
figure
scatter3(X1(:,1),X1(:,2),X1(:,3),10,c)

%% 

filtWave = jat_Struct.spkWaveforms(~features.WaveFitParams.noise,:);
cfilt = c(~features.WaveFitParams.noise);
%%
figure;
subplot(1,2,1);
plot(filtWave(cfilt==1,:)','r')
ylim([-6000 6000]);
subplot(1,2,2);
plot(filtWave(cfilt==2,:)','g')
ylim([-6000 6000]);



