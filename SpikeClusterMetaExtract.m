function [clustStruct, waveStruct, fileInfo, debug] = SpikeClusterMetaExtract()
% SPIKECLUSTERMETAEXTRACT - Runs the spike extraction code on an entire
% session and creates a struct output with results. Use debugging field to
% determine if any files failed.
%
% Is run with PLOTMULTIWINDOWSPIKEINFO.m
% DOES NOT REQUIRE INPUTS or HAVE ANY DEFAULT INPUTS
%
% Dependencies:
% 1. set_parameters_AO.m
% 2. SpikeThresholdCreate.m
% 3. SpikeTimeExtract.m
% 4. ExtractWaveFeatures.m
% 5. ClusterSpikes.m
% 6. GetClusIndex_WCalg.m

% numOfspikes = vector of spike counts for all traces

% Spike Debug Script

cd('Y:\PreProcessEphysData\06_19_2014');
fileDir = dir('*.mat');
fileList = {fileDir.name};

fileIndex = randperm(length(fileList),round(length(fileList)/2));

debug = struct;
debug.fName = {};
debug.ele = {};
debug.err = {};
debugNum = 1;
eleCount = 1;
waveStruct = cell(3*round(length(fileList)/2),1);
clustStruct = cell(3*round(length(fileList)/2),1);
fileInfo = cell(3*round(length(fileList)/2),2);
for fli = 1:round(length(fileList)/2)
    

    fileName = fileList{fileIndex(fli)};
    % AbvTrgt_34_06015.mat problematic for my algorithm
    
    load(fileList{fileIndex(fli)})
    
    for ei = 1:3
        
        tempSpkData = eval(strcat('CElectrode',num2str(ei)));
        sampFreq = sampFreqMER*1000; % THIS NEEDS to CHANGE
        
        handles.datatype = 'unClustered';
        
        handles.params = set_parameters_AO(sampFreq, fileName, handles);
        
        try
            
            [thrOut] = SpikeThresholdCreate(tempSpkData, handles, 'Min9sig');
            filtSpkData = thrOut.Filtered;
            threshold = thrOut.AveThresh;
            [jat_Struct] = SpikeTimeExtract(filtSpkData, threshold, handles);
            
            % Get threshold data and spike number
            if ~isstruct(jat_Struct)
                tempStruct = nan;
                tempClust = nan;
            else
                tempStruct = jat_Struct;
                [waveFeat] = ExtractWaveFeatures(tempStruct.spkWaveforms, handles);
                [clustOUT, treeOUT, ipermut] = ClusterSpikes(waveFeat, handles);
                [~, ~, clusterAll] = GetClusIndex_WCalg(clustOUT, treeOUT, tempStruct.spkIndex, tempStruct.spkWaveforms, ipermut, handles);
                tempClust = clusterAll;
            end
            
        catch error
            
            debug.fName{debugNum,1} = fileName;
            debug.ele{debugNum,1} = strcat('CElectrode',num2str(ei));
            debug.err{debugNum,1} = error;
            tempStruct = nan;
            tempClust = nan;
            debugNum = debugNum + 1;
            
        end
        
        waveStruct{eleCount,1} = tempStruct;
        clustStruct{eleCount,1} = tempClust;
        
        
        fileInfo{eleCount,1} = fileName;
        fileInfo{eleCount,2} = strcat('CElectrode',num2str(ei));
        
        eleCount = eleCount + 1;
        
    end
    
    fprintf('File # %d out of %d done! \n',fli, round(length(fileList)/2));
    
end


