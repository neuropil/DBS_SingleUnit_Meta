function [detectStruct] = SpikeTimeExtract(filtSpkData, threshold, handles)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% TO DO

% 0. Make Profiler
% 0a. cluster_spikeData.m and wave_features_jat.m
% 1. RUN SPIKE CLUSTER alogrithm
% 2. Figure out how to analyze ISI and IFR and Fano factor


% CHECK testcases

detect = handles.params.detection;
handles.sampleRate = handles.params.sr;
timePreWindow = handles.params.w_pre;
timePostWindow = handles.params.w_post;

% peak_ref = handles.params.ref;

isiBuffer = round(handles.sampleRate/1000) + round(round(handles.sampleRate/1000)/2);
neg_buf = abs(handles.params.w_pre - floor(isiBuffer/2));

switch detect
    case 'pos'
        % Set up index vector with NaN - make longer than needed
        thrXIndex  = nan(1,length(filtSpkData));
        spikeNumber = 0; % Number of spikes detected
        % Extract all possible threshold crossings, use window :
        % starting prewindow + 2 of trace to postwindow - 2
        % Add prewindow + 1 to each index value shifting thresholds by
        % that value
        thrXIndex_shft = find(filtSpkData(timePreWindow + 2:length(filtSpkData) - timePostWindow - 2) > threshold) + timePreWindow + 1;
        
        % Loop through candidate spikes
        % peak_ref = refers to point in wave window that represent crossing
        
        tempXindex = 0;
        for sptI = 1:length(thrXIndex_shft)
            if thrXIndex_shft(sptI) >= tempXindex + round(isiBuffer/2) % does current index occur within the range between previous index and one half wave window
                % Get max index relative to threshold crossing
                [~, relXindex] = max((filtSpkData(thrXIndex_shft(sptI) - neg_buf:thrXIndex_shft(sptI) + floor(isiBuffer/2) - 1)));  %introduces alignment
                spikeNumber = spikeNumber + 1;
                thrXIndex(spikeNumber) = relXindex + thrXIndex_shft(sptI) - 1; % subtract 1 to account for the shift
                tempXindex = thrXIndex(spikeNumber);
            end
        end

    case 'neg'
%         thrXIndex_shft = find(filtSpkData(timePreWindow + 2:length(filtSpkData) - timePostWindow - 2) < - spkThresh2use) + timePreWindow + 1; % use pos
    case 'both'
%         thrXIndex_shft = find(abs(filtSpkData(timePreWindow + 2:length(filtSpkData) - timePostWindow - 2)) > spkThresh2use) + timePreWindow+1; % use both pos and neg
end

%%%%%%%%


% Clear off NaNs
thrXIndex = thrXIndex(~isnan(thrXIndex));

% SPIKE SORTING (with or without interpolation)
spikeWindow = timePreWindow + timePostWindow; % number of points in spike window
waveforms = zeros(spikeNumber, spikeWindow + 4);
waveIndices = zeros(spikeNumber, spikeWindow);
% Adds buffer with the length of the post window
% In case spike is located on last index of window
filtSpkData = [filtSpkData zeros(1, timePostWindow)];

for spkI = 1:spikeNumber
    
    waveforms(spkI,:) = filtSpkData(thrXIndex(spkI) - timePreWindow - 1:thrXIndex(spkI) + timePostWindow + 2);
    waveIndices(spkI,:) = thrXIndex(spkI) - timePreWindow:thrXIndex(spkI) + timePostWindow - 1;
%     waveIndices(spkI,:) = index(spkI) - timePreWindow - 1:index(spkI) + timePostWindow + 2;
    
end

% Eliminates borders that were introduced for interpolation
switch handles.params.interpolation
    case 'n'
         waveforms(:, end - 1:end) = [];
         waveforms(:, 1:2) = [];
    case 'y'
        %Does interpolation
         [~ , waveforms] = int_spikes_jat(waveforms,handles);
end


detectStruct.SpikeData = filtSpkData;
detectStruct.threDetect = threshold;
detectStruct.spkIndex = thrXIndex;
detectStruct.rawThreshCross = thrXIndex_shft;
detectStruct.spkWaveforms =  waveforms;
detectStruct.spkWaveIndices = waveIndices;
detectStruct.numSpikes = numel(thrXIndex);


end

