handles.datatype = 'unClustered';

handles.params = set_parameters_CSC_TEST(sampFreq, fileName, handles);

[thrOut] = SpikeThresholdCreate(tempSpkData, handles, 'Min9sig');
filtSpkData = thrOut.Filtered;
threshold = thrOut.AveThresh;
[jat_Struct] = SpikeTimeExtract(filtSpkData, threshold, handles);

features = struct;


% Reduce dimensions and extract Waveforms of interest
tempWaves = jat_Struct.spkWaveforms;

% Waveform Structure
WaveIndex = tempWaves;

% Peak
features.Peak = max(tempWaves)';
% Valley
features.Valley = min(tempWaves)';
% Energy
features.Energy = trapz(abs(tempWaves))';
% Combine for WavePCA analysis
featsForPCA = horzcat(features.Peak,...
    features.Valley,...
    features.Energy);
% WavePC1
[~,features.WavePC1,~] =...
    princomp(featsForPCA);
% Waveform Comparison (Bray-Curtis Index)
% Keep off during dbug TAKES a while to compute 6/10/2013

%                 features.WaveSimIndex.(strcat('L',num2str(disindex(fi)))) =...
%                     BrayCurtisIndex(tempWaves,disindex(fi));


% First & Second Derivative analysis
features.FSDE_Values =...
    FSDE_Method(tempWaves');



% Derive Gaussian fit parameters for positive and negative
% component of waveform (Felsen and Thompson method)
[features.WaveFitParams, features.WaveSumDS] = WaveFormFit_SE(tempWaves);