%% First run spikeDebugNOwv

[clustStruct, waveStruct, fileInfo, debug] = SpikeClusterMetaExtract();

%% Select a specific trace to analyze

SpikeClustProfiler(waveStruct, clustStruct, 3, fileInfo(3,:));



%%

for i = 1:length(clustStruct)
    
    
   SpikeClustProfiler(waveStruct, clustStruct, i, fileInfo(i,:)); 
   pause
   close all
    
end


%% Extract waveform data







%%


load fisheriris
[cidx2,cmeans2] = kmeans(meas,2,'dist','sqeuclidean');
[silh2,h] = silhouette(meas,cidx2,'sqeuclidean');
