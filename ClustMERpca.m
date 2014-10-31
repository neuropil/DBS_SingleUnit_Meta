function [clusterStruct] = ClustMERpca(wavePCs)
% ClustMERpca - Runs the cluster evaluation and cluster analysis using pca
%   Detailed explanation goes here

testdata = wavePCs(:,1:3);

evalTests = {'CalinskiHarabasz','DaviesBouldin','Silhouette'};
evalCname = cell(3,1);
evalResult = struct;
for evI = 1:3
    evalCname{evI} = evalTests{evI};
    evalResult.(evalTests{evI}) = evalclusters(testdata,'kmeans',evalTests{evI},'KList',1:6); % or 'kmeans'
end

[clustIdeal, clustTestInd] = min([evalResult.CalinskiHarabasz.OptimalK,...
                                  evalResult.DaviesBouldin.OptimalK,...
                                  evalResult.Silhouette.OptimalK]);
                              
options = statset('MaxIter',1000);
clusterObj = fitgmdist(testdata(:,1:2),clustIdeal,'Options',options);

%%%%
% scatter(testdata(:,1),testdata(:,2),10,'.');hold on
% ezcontour(@(x,y)pdf(clusterObj,[x y]),[-10000 20000],[-2500 2000]);

tempTD = testdata(:,1:2);
clustID = cluster(clusterObj,tempTD);

clusterStruct.ClustAlg = evalTests{clustTestInd};
clusterStruct.pcaRaw = testdata;
clusterStruct.ClustNum = clustIdeal;
clusterStruct.ClusterObject = clusterObj;
clusterStruct.ClustIndex = clustID;



end

