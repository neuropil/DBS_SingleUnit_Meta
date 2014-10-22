function [detectStruct] = spikeThreshold_filter_beta(rawSpkData, handles, spikePlot, userThresh)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% TO DO

% 0. Make Profiler
% 0a. cluster_spikeData.m and wave_features_jat.m
% 1. RUN SPIKE CLUSTER alogrithm
% 2. Figure out how to analyze ISI and IFR and Fano factor

if nargin == 3
    threshUse = 0; % Use default method
else
    threshUse = 1;
end

% CHECK testcases

voltLength = numel(rawSpkData);
sampRate = handles.params.sr;
detect = handles.params.detection;
handles.sampleRate = handles.params.sr;
stdmin = handles.params.stdmin;
% stdmax = handles.params.stdmax;
% peak_ref = handles.params.ref;
fmin_detect = handles.params.detect_fmin;
fmax_detect = handles.params.detect_fmax;
fmin_sort = handles.params.sort_fmin;
fmax_sort = handles.params.sort_fmax;

% HIGH-PASS FILTER OF THE DATA
[b,a] = ellip(2,0.1,40,[fmin_detect fmax_detect]*2/handles.sampleRate);
spike_detect_filter = filtfilt(b,a,rawSpkData);
[b,a] = ellip(2,0.1,40,[fmin_sort fmax_sort]*2/handles.sampleRate);
artifact_filter = filtfilt(b,a,rawSpkData);


%%%%%%%%%%%% Mean and SD
% SPIKE THRESHOLD

if strcmp(detect,'pos')
    
    ave_spikeDthr = mean(spike_detect_filter(spike_detect_filter > 0));
    std_spikeDthr = std(spike_detect_filter(spike_detect_filter > 0));
    spikeFthresh = ave_spikeDthr + (3*std_spikeDthr);
    
    % Moving Average
    % Get size of 100ms block based on sampling frequency
    sizeOfBlock = round(sampRate/10);
    numOfBlock = floor(voltLength/sizeOfBlock);
    trailBlock = mod(voltLength,sizeOfBlock);
    % Use smooth function
    
    startB = 1;
    stopB = sizeOfBlock;
    blockBounds = zeros(numOfBlock + 1,2);
    movAvSpk = zeros(numOfBlock + 1,1);
    for bbi = 1:numOfBlock + 1
        
        if bbi == numOfBlock + 1;
            
            blockBounds(bbi,1) = startB;
            blockBounds(bbi,2) = startB + trailBlock;
            
            spikeBlock = spike_detect_filter(blockBounds(bbi,1):blockBounds(bbi,2));
            
            meanTemp = mean(spikeBlock(spikeBlock > 0));
            sdTemp = std(spikeBlock(spikeBlock > 0));
            if threshUse
                movAvSpk(bbi) = userThresh;
            else
                movAvSpk(bbi) = meanTemp + (3*sdTemp);
            end
            
        else
        
        blockBounds(bbi,1) = startB;
        blockBounds(bbi,2) = stopB;
        
        spikeBlock = spike_detect_filter(startB:stopB);
        
        meanTemp = mean(spikeBlock(spikeBlock > 0));
        sdTemp = std(spikeBlock(spikeBlock > 0));
        
        if threshUse
            movAvSpk(bbi) = userThresh;
        else
            movAvSpk(bbi) = meanTemp + (3*sdTemp);
        end
        
        startB = stopB;
        stopB = stopB + sizeOfBlock;
        
        end
        
    end
        
    % movingAve = smooth(X,block,'rloess')
    
    % Fix ends of moving average
    movAvSpk(1) = movAvSpk(2);
    movAvSpk(length(movAvSpk)) = movAvSpk(length(movAvSpk) - 1);
    
else
    
    ave_spikeDthr = mean(abs(spike_detect_filter));
    std_spikeDthr = std(abs(spike_detect_filter));
    spikeFthresh = ave_spikeDthr + (3*std_spikeDthr);
    % thresh_artif = stdmax * noise_std_sorted;
end


% NOISE THRESHOLD
aveN = mean(abs(artifact_filter));
stdN = std(abs(artifact_filter));
% threN = aveN + (2*stdN);
zScores = abs((abs(artifact_filter) - aveN)/stdN);
artifactIndex = zScores >= 17;

noise_std_detect = median(abs(spike_detect_filter)) / 0.6667; % x 1.5
threshSpikeWVc = stdmin * noise_std_detect; 

if abs(spikeFthresh - threshSpikeWVc) >= 750
     spkThresh2use = (spikeFthresh + threshSpikeWVc)/2;
else
     spkThresh2use = spikeFthresh;
end

% Replace artifact voltages with zeros
spikeDF_woA = spike_detect_filter;
spikeDF_woA(artifactIndex) = 0;

% All Noise no spike check
minBorder = ave_spikeDthr + (7*std_spikeDthr);
maxBorder = ave_spikeDthr + (15*std_spikeDthr);

bordXindex = spike_detect_filter > minBorder & spike_detect_filter < maxBorder;

if sum(bordXindex) == 0
    detectStruct = nan;
    return
end

% NOT USED - 9/29/2014 - JAT
% %%%%%%%%%%%% Median and IQR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % SPIKE THRESHOLD
% iqrD = iqr(abs(xf_detect));
% Q3D = quantile(abs(xf_detect), 0.75);
% outLieD = Q3D + (1.5*iqrD);
% % NOISE THRESHOLD
% iqrN = iqr(abs(xf));
% Q3N = quantile(abs(xf), 0.75);
% outLieN = Q3N + (1.5*iqrN);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


timePreWindow = handles.params.w_pre;
timePostWindow = handles.params.w_post;
% peak_ref = handles.params.ref;

isiBuffer = round(handles.sampleRate/1000) + round(round(handles.sampleRate/1000)/2);
rawNumInd = 1:1:length(spikeDF_woA);

spikeNumber = 0;
if spikePlot
    figure;
end

switch detect
    case 'pos'
%         thrXIndex_shft = find(spikeDF_woA(timePreWindow + 2:length(spike_detect_filter) - timePostWindow - 2) > spkThresh2use) + timePreWindow + 1; 
        
        %%%%%% NEW CODE
        thIndS = 1;
        thIndE = 0;
        thrXIndex_shft = nan(1,length(spikeDF_woA));
        for movI = 1:length(movAvSpk)
            
            spkBlock = spikeDF_woA(blockBounds(movI,1):blockBounds(movI,2));
            rawNBlock = rawNumInd(blockBounds(movI,1):blockBounds(movI,2));
            
            tempSpkIndex = find(spkBlock(timePreWindow + 2:length(spkBlock) - timePostWindow - 2) > movAvSpk(movI)) + timePreWindow + 1;
            
            thIndE = thIndE + length(tempSpkIndex);
            
            if isempty(tempSpkIndex)
                thIndS = thIndE + 1;
                continue
            else
                thrXIndex_shft(thIndS:thIndE) = rawNBlock(tempSpkIndex);
            end
            thIndS = thIndE + 1;
            
        end
        
        

    case 'neg'
        thrXIndex_shft = find(spikeDF_woA(timePreWindow + 2:length(spikeDF_woA) - timePostWindow - 2) < - spkThresh2use) + timePreWindow + 1; % use pos
    case 'both'
        thrXIndex_shft = find(abs(spikeDF_woA(timePreWindow + 2:length(spikeDF_woA) - timePostWindow - 2)) > spkThresh2use) + timePreWindow+1; % use both pos and neg
end

%%%%%%%%
thrXIndex_shft = thrXIndex_shft(~isnan(thrXIndex_shft));


threshXInd_all = spikeDF_woA > spkThresh2use;

tempXindex = 0;
index = nan(1,length(thrXIndex_shft));
for i = 1:length(thrXIndex_shft)
    if thrXIndex_shft(i) >= tempXindex + round(isiBuffer/2) && spikeDF_woA(thrXIndex_shft(i)) ~= 0
        [~ , relXindex] = max(spikeDF_woA(thrXIndex_shft(i):thrXIndex_shft(i) + floor(isiBuffer/2) - 1)); %introduces alignment

            spikeNumber = spikeNumber + 1;
            index(spikeNumber) = relXindex + thrXIndex_shft(i) - 1;
%             tempWaveF = spikeDF_woA(thrXIndex_shft(i) - timePreWindow + 1:thrXIndex_shft(i) + timePostWindow);
%             waveforms(spikeNumber,:) = tempWaveF;
            tempXindex = index(spikeNumber);
    end
end


% Clear off NaNs
index = index(~isnan(index));

% SPIKE SORTING (with or without interpolation)
spikeWindow = timePreWindow + timePostWindow; % number of points in spike window
waveforms = zeros(spikeNumber, spikeWindow + 4);
waveIndices = zeros(spikeNumber, spikeWindow);
% Adds buffer with the length of the post window
% In case spike is located on last index of window
spikeDF_woA = [spikeDF_woA zeros(1, timePostWindow)];

for spkI = 1:spikeNumber
    
    waveforms(spkI,:) = spikeDF_woA(index(spkI) - timePreWindow - 1:index(spkI) + timePostWindow + 2);
    waveIndices(spkI,:) = index(spkI) - timePreWindow:index(spkI) + timePostWindow - 1;
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






spikeIndex = index(~isnan(index));

detectStruct.rawSignal = rawSpkData;
detectStruct.signal_detect = spike_detect_filter;
detectStruct.signal_artifact = artifact_filter;
detectStruct.threDetect = spkThresh2use;
detectStruct.artIndex = artifactIndex;
detectStruct.spkIndex = spikeIndex;
detectStruct.rawThreshCross = threshXInd_all;
detectStruct.spkWaveforms =  waveforms;
detectStruct.spkWaveIndices = waveIndices;
detectStruct.FORDEBUG.detectThreshold = spkThresh2use;
detectStruct.FORDEBUG.numSpikes = numel(spikeIndex);










end

