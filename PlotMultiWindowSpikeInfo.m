%% First run spikeDebugNOwv

[clustStruct, waveStruct, fileInfo, debug] = SpikeClusterMetaExtract();

cd('Y:\MatlabDebugTemp');
save('ClusterDebug.mat','clustStruct', 'waveStruct', 'fileInfo', 'debug')

%%
edit NeuroDBS_DB_beta_v01.m
edit SpikeClustProfiler.m

%% Select a specific trace to analyze

SpikeClustProfiler(waveStruct, clustStruct, 3, fileInfo(3,:));



%%

for i = 1:length(clustStruct)
    
    
   SpikeClustProfiler(waveStruct, clustStruct, i, fileInfo(i,:)); 
   pause
   close all
    
end

%%

cd('Y:\MatlabDebugTemp');
load('ClusterDebug.mat')


%% Spike Plot look-through

reInspect = zeros(length(clustStruct),1);
for i = 1:length(clustStruct)
    
   spkWavForms =  waveStruct{i,1}.spkWaveforms;
   PlotSpikeOverlay(spkWavForms, 1)
   disp(num2str(i))
   pause
   
   if strcmp(get(gcf,'CurrentCharacter'),'y')
       reInspect(i) = 1;
   end
   
   close all
    
end

%% Recheck spike extract with REINSPECT group



fileLoc = 'Y:\PreProcessEphysData\06_19_2014';
eleNames = fileInfo(logical(reInspect),:);
mNames = unique(fileInfo(logical(reInspect),1));

eleOut = EleIDextract(eleNames);

[re_Clust, re_Wave, re_FI, re_debug] = SpikeClusterMetaExtract(fileLoc, mNames, eleOut, 1);

%%
cd('Y:\MatlabDebugTemp');
save('ClusterDebugRE.mat','re_Clust', 're_Wave', 're_FI', 're_debug')

%% GET NEURO_DBS working

sessNum = '06_19_2014';
depthNum = 'AbvTrgt_43_03320.mat';
eleNum = 'CElectrode1';

[CellInfo] = NeuroDBS_DB_beta_v01(sessNum, depthNum, eleNum);



%% Extract waveform data







%%


load fisheriris
[cidx2,cmeans2] = kmeans(meas,2,'dist','sqeuclidean');
[silh2,h] = silhouette(meas,cidx2,'sqeuclidean');
