%%%%%%%%%%%%%%%%%%% Spike Sorting TEST Script %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NOTES/Journal

% 9/1/2014 : Script creation and layout

% 9/24/2014
% Trying to understand how the amplitude threshold code works
% Specifically how the 'int_spikes_jat' -interpolation- works
% 'int_spikes_jat' is called at the end of 'amp_detect_TEST_truncate'
% Variables have been more clearly named in 'amp_detect_TEST_truncate'

% For next time:
% Keep exploring 'amp_detect_TEST_truncate' : for loop where spikes are
% extracted
% AND 'int_spikes_jat' where interpolation occurs.
% When electrode data loaded in: check for TIME variable

% 9/26/2014 
% 1. I am happy with and understand interpolation step - int_spikes_jat.m

% 10/3/2014 
% 1. Completed spike analysis based on amplitude.
% 2. More conservative than wavClus, but still picks up a lot of noise
% 3. Completed spike profiler
% 4. Next step is to complete waveform feature extraction and cluster
% analysis
% STUCK ON CLUSTER ANALYSIS - I don't understand how to separate the
% outputs
% 5. TO DO 
% 6. Run wave clus GUI and try to interogate OUTPUT
% 
% Update : Finished initial cluster from WAVECLUS
% FUTURE : attempt PCA style clustering on waveform features
% NOTES : CHECK NeuralDatabase code for ideas
%       : WAVEFORM feature extraction
%       : KMEANS or Linear discrimination

% TO DO 10/20/2014
% 




%% Load Directory for Recording day

cd('C:\Users\John\Desktop\MERGUItest')
load('spikeTESTdata.mat')
fileName = 'spikeTESTdata.mat';

%% Spike Parameters

% Time Axes
timeAxisLONG = linspace(0,length(spikeData)/(sampleRate),length(spikeData));
shortAXISind = timeAxisLONG <= 1;
timeAxisSHORT = timeAxisLONG(timeAxisLONG <= 1);

% Data type
handles.datatype = 'unClustered';


%% TEST PLOT

plot(timeAxisSHORT,spikeData(shortAXISind))

%% To test Auditory sample

sampleRate = CElectrode1_KHz*1000;
fileName = '12507.mat';
handles.datatype = 'unClustered';
spikedata = CElectrode3;

% for plotting

plot(spikedata,'k');
hold on
plot(detectStruct.spkIndex,spikedata(detectStruct.spkIndex),'ro')


%% Set up Spike Sort parameters

handles.params = set_parameters_CSC_TEST(sampleRate, fileName, handles);

%% 9/26/2014  Get spike crossing index

% WavClus algorithm
% [spikes, thr, index] = amp_detect_TEST_truncate(spikeData, handles);


%% JAT algorithm

[detectStruct] = spikeThreshold_filter(spikedata, handles, 0);


%%  10/3/2014  Extract and Calculate Wave Features

[inspk] = wave_features_jat(detectStruct.spkWaveforms, handles); 


%% Interaction with SPC

[clustOUT, treeOUT, ipermut] = cluster_spikeData(inspk, handles);


%% Get clusters

spkIndex = detectStruct.spkIndex;
spkWaveforms = detectStruct.spkWaveforms;


[clusterIndex, nclusters, clusterAll] = GetClusterIndexWVT(clustOUT, treeOUT, spkIndex, spkWaveforms, ipermut, handles);













%% EXTRA

clu_aux = zeros(size(clustOUT,1),length(detectStruct.spkIndex)) + 1000;
for i=1:length(ipermut)
    clu_aux(:, ipermut(i) + 2) = clustOUT(:, i + 2);
end
clu_aux(:,1:2) = clustOUT(:,1:2);
clustOUT = clu_aux; clear clu_aux


temperClus = find_temp_jat(treeOUT,handles);

if size(clustOUT,2)-2 < size(detectStruct.spkWaveforms,1);
    classes = clustOUT(temperClus(end),3:end)+1;
    if ~exist('ipermut','var')
        classes = [classes(:)' zeros(1,size(detectStruct.spkWaveforms,1)-handles.params.max_spk)];
    end
else
    classes = clustOUT(temperClus(end),3:end) + 1;
end

clustering_results = []; 
clustering_results(:,1) = repmat(temperClus,length(classes),1); % original temperatures 
clustering_results(:,2) = classes'; % original classes 
clustering_results(:,3) = repmat(handles.params.min_clus,length(classes),1); % minimum number of clusters

% Defines nclusters
cluster_sizes=[];
cluster_sizes_bkup=[];
class_bkup = classes;
for i=1:handles.params.max_clus                                    
    eval(['cluster_sizes = [cluster_sizes length(find(classes==' num2str(i) '))];'])
    eval(['cluster_sizes_bkup = [cluster_sizes_bkup length(find(class_bkup==' num2str(i) '))];'])
end

nclusters_bkup = length(find(cluster_sizes(:) >= handles.params.min_clus));
class_bkup(class_bkup > nclusters_bkup) = 0;

sizemin_clus = handles.params.min_clus;

nclusters = length(find(cluster_sizes(:) >= sizemin_clus));




% Defines classes
clustered = [];
cont=0;  
for i=1:nclusters
    eval(['class_temp = find(classes==' num2str(i) ');'])
    
    cont=cont+1;
    eval(['class' num2str(cont) '= class_temp;'])
    eval(['clustered = [clustered class' num2str(cont) '];'])
    
end










