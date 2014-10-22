%% First run spikeDebugNOwv

[waveStruct, fileInfo, debug] = SpikeClusterMetaExtract();

%% Select a specific trace to analyze

SpikeClustProfiler(waveStruct, 3, fileInfo(3,:));

