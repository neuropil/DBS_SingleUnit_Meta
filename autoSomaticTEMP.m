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

% normalize features

% HERE GET DATA from 


% PCA or some such dimension reduce




% Cluster 3 components that explain most variance



















% PCA - dimension reduction toolbox


% Cluster - Kmeans


% Start high - reduce n based on cluster quality metric - evalclusters


% Distance metric = eval clusters


% GUI to choose spike files

