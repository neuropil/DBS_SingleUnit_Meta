function [clusterIndex, nclusters, clusterAll] = GetClusterIndexWVT(clustOUT, treeOUT, spkIndex, spkWaveforms, ipermut, handles)



clu_aux = zeros(size(clustOUT,1),length(spkIndex)) + 1000;
for i = 1:length(ipermut)
    clu_aux(:, ipermut(i) + 2) = clustOUT(:, i + 2);
end
clu_aux(:,1:2) = clustOUT(:,1:2);
clustOUT = clu_aux; clear clu_aux

temperClus = find_temp_jat(treeOUT, handles);

if size(clustOUT,2)-2 < size(spkWaveforms,1);
    clusterIndex = clustOUT(temperClus(end),3:end)+1;
    if ~exist('ipermut','var')
        clusterIndex = [clusterIndex(:)' zeros(1,size(spkWaveforms,1)-handles.params.max_spk)];
    end
else
    clusterIndex = clustOUT(temperClus(end),3:end) + 1;
end

% Defines nclusters
cluster_sizes = [];
for i=1:handles.params.max_clus                                    
    eval(['cluster_sizes = [cluster_sizes length(find(clusterIndex==' num2str(i) '))];'])
end

nclusters = length(find(cluster_sizes(:) >= handles.params.min_clus));
clusterIndex(clusterIndex > nclusters) = 0;

clusNums = unique(clusterIndex);

% Defines classes
clusterAll = cell(length(clusNums),1);
clustInfo = struct;
for i = 1:length(clusNums)
    
    targetNum = clusNums(i);
    clustInfo.cNum = targetNum;
    clustInfo.cIndex = find(clusterIndex == targetNum);
    clusterAll{i} = clustInfo;
    
end









end

