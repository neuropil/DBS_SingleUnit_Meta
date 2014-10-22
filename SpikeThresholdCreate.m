function [SpkCrStruct] = SpikeThresholdCreate(rawSpkData, handles, thrMethod)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% TO DO

% 0. Make Profiler
% 0a. cluster_spikeData.m and wave_features_jat.m
% 1. RUN SPIKE CLUSTER alogrithm
% 2. Figure out how to analyze ISI and IFR and Fano factor

% CHECK testcases

% Calculate POS values
% Calculate MEAN, SD, SE, MEDIAN, IQR, ConInt

voltLength = numel(rawSpkData);
sampRate = handles.params.sr;
numSecs = voltLength/sampRate;

fracSec = round((round(numSecs)/60)*100)/100;

detect = handles.params.detection;
handles.sampleRate = handles.params.sr;
stdmin = handles.params.stdmin;
% stdmax = handles.params.stdmax;
% peak_ref = handles.params.ref;
fmin_detect = handles.params.detect_fmin;
fmax_detect = handles.params.detect_fmax;

% HIGH-PASS FILTER OF THE DATA
[b,a] = ellip(2,0.1,40,[fmin_detect fmax_detect]*2/handles.sampleRate);
spikeDetectFilterRaw = filtfilt(b,a,rawSpkData);

%%%%%%%%%%%% Mean and SD
% SPIKE THRESHOLD

if strcmp(detect,'pos')
    
    ave_spikeDthr = mean(spikeDetectFilterRaw(spikeDetectFilterRaw > 0));
    std_spikeDthr = std(spikeDetectFilterRaw(spikeDetectFilterRaw > 0));
    spikeFthresh = ave_spikeDthr + (3*std_spikeDthr);
    
    % Moving Average
    % Get size of 100ms block based on sampling frequency
    sizeOfBlock = round(sampRate*fracSec);
    numOfBlock = floor(voltLength/sizeOfBlock);
    trailBlock = mod(voltLength,sizeOfBlock);
    % Use smooth function
    
    startB = 1;
    stopB = sizeOfBlock;
    blockBounds = zeros(numOfBlock + 1,2);
    movAvSpk = zeros(numOfBlock + 1,1);
    meanAll = zeros(numOfBlock + 1,1);
    for bbi = 1:numOfBlock + 1
        
        if bbi == numOfBlock + 1;
            
            blockBounds(bbi,1) = startB;
            blockBounds(bbi,2) = startB + trailBlock;
            
            spikeBlock = spikeDetectFilterRaw(blockBounds(bbi,1):blockBounds(bbi,2));
            
            meanTemp = mean(spikeBlock(spikeBlock > 0));
            sdTemp = std(spikeBlock(spikeBlock > 0));
            
            noiseSTDdet = median(abs(spikeBlock(spikeBlock > 0))) / 0.6667;
            
            iqrD = iqr(abs(spikeBlock(spikeBlock > 0)));
            Q3D = quantile(abs(spikeBlock(spikeBlock > 0)), 0.75);
            
            switch thrMethod
                
                case '6sig'
                    movAvSpk(bbi) = meanTemp + (6*sdTemp);
                case '3sig'
                    movAvSpk(bbi) = meanTemp + (3*sdTemp);
                case 'iqrOutlie'
                    movAvSpk(bbi) = Q3D + (1.5*iqrD);
                case 'WaveClus'
                    movAvSpk(bbi) = stdmin * noiseSTDdet;
                case 'Min9sig'
                    movAvSpk(bbi) = meanTemp + (4*sdTemp);
                    meanAll(bbi) = meanTemp;
            end
            
        else

            blockBounds(bbi,1) = startB;
            blockBounds(bbi,2) = stopB;
            
            spikeBlock = spikeDetectFilterRaw(startB:stopB);
            
            meanTemp = mean(spikeBlock(spikeBlock > 0));
            sdTemp = std(spikeBlock(spikeBlock > 0));
            
            noiseSTDdet = median(abs(spikeBlock(spikeBlock > 0))) / 0.6667;
            
            iqrD = iqr(abs(spikeBlock(spikeBlock > 0)));
            Q3D = quantile(abs(spikeBlock(spikeBlock > 0)), 0.75);
            
            switch thrMethod
                
                case '6sig'
                    movAvSpk(bbi) = meanTemp + (6*sdTemp);
                case '3sig'
                    movAvSpk(bbi) = meanTemp + (3*sdTemp);
                case 'iqrOutlie'
                    movAvSpk(bbi) = Q3D + (1.5*iqrD);
                case 'WaveClus'
                    movAvSpk(bbi) = stdmin * noiseSTDdet;
                case 'Min9sig'
                    movAvSpk(bbi) = meanTemp + (4*sdTemp);
                    meanAll(bbi) = meanTemp;
            end
            
            startB = stopB;
            stopB = stopB + sizeOfBlock;
            
        end
        
        % CHECK if each succeeding AVE line is greater than double
        % proceeding
        if bbi > 1
            if movAvSpk(bbi) > movAvSpk(bbi-1) + (movAvSpk(bbi-1)*0.25)
                movAvSpk(bbi) = sum([movAvSpk(bbi),movAvSpk(bbi-1)])/2.5;
            end
        end
        
    end
    
    % Fix ends of moving average
    movAvSpk(1) = movAvSpk(2); % Gets rid of 100ms of zeros
    meanAll(1) = meanAll(2);
    movAvSpk(length(movAvSpk)) = movAvSpk(length(movAvSpk) - 1);
    meanAll(length(meanAll)) = meanAll(length(meanAll) - 1);
    
else
    
    ave_spikeDthr = mean(abs(spikeDetectFilterRaw));
    std_spikeDthr = std(abs(spikeDetectFilterRaw));
    spikeFthresh = ave_spikeDthr + (3*std_spikeDthr);
    % thresh_artif = stdmax * noise_std_sorted;
end


if strcmp(thrMethod,'Min9sig')
    
    minIndex = find(meanAll == min(meanAll),1,'first');
    min9Sig = movAvSpk(minIndex);
    movAvSpk = repmat(min9Sig,length(meanAll),1);
    
end

SpkCrStruct.MoveAverage = movAvSpk;
SpkCrStruct.SpikeThAverage = spikeFthresh;
SpkCrStruct.FracSecUsed = fracSec;
SpkCrStruct.ThrMethod = thrMethod;
SpkCrStruct.BlBounds = blockBounds;
SpkCrStruct.Filtered = spikeDetectFilterRaw;
SpkCrStruct.AveThresh = mean(movAvSpk);







