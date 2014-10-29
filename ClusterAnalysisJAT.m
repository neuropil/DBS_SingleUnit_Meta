% Classifying High-dimensional data

%% TEST DATA

% 1. RUN PCA
% 2. USE First 3 PCs as input to cluster algorithm
% 3. Run Evalclusters to determine sufficient numbers of clusters
% 4. Run Kmeans and Kmediods on Evalclusters suggestion
% 5. Run GaussianMixedModel on Evalclusters suggestion

testdata = features.WavePCs(:,1:3);

evalTests = {'CalinskiHarabasz','DaviesBouldin','Silhouette'};
evalCname = cell(3,1);
evalResult = struct;
for evI = 1:3
    evalCname{evI} = evalTests{evI};
    evalResult.(evalTests{evI}) = evalclusters(testdata,'kmeans',evalTests{evI},'KList',1:6);
end

clustIdeal = min([evalResult.CalinskiHarabasz.OptimalK,...
                  evalResult.DaviesBouldin.OptimalK,...
                  evalResult.Silhouette.OptimalK]);

[clustIndex,centerIndex,sumdist] = kmeans(testdata,clustIdeal,'Distance','cityblock',...
                       'Display','final','Replicates',10);

figure;
silhouData = silhouette(testdata,clustIndex,'city');
silhouette(testdata,clustIndex,'city')
xlabel 'Silhouette Value';
ylabel 'Cluster';
mean(silhouData)

obj = fitgmdist(testdata(:,1:2),clustIdeal);
scatter(testdata(:,1),testdata(:,2),10,'.');hold on
ezcontour(@(x,y)pdf(obj,[x y]),[-10000 20000],[-2500 2000]);

tempTD = testdata(:,1:2);
clustID = cluster(obj,tempTD);

clustAll = struct;
plotIDots = {'r.','g.','b.','k.','m.'};
plotILines = {'r-','g-','b-','k-','m-'};
colors = 'rgbkm';
for cli = 1:max(clustID)
    
    clustAll.(strcat('clust',num2str(cli))) = tempTD(clustID == cli,:);
    figure(1);
    hold on
    scatter(clustAll.(strcat('clust',num2str(cli)))(:,1),...
        clustAll.(strcat('clust',num2str(cli)))(:,2),...
        100,...
        plotIDots{cli});
    
    figure(2);
    hold on
    plot(waveForms(clustID == cli,:)',plotILines{cli})
    
    figure(3);
    tempWavs = waveForms(clustID == cli,:);
    for wavi = 1:size(tempWavs,1)
        
        y = tempWavs(wavi,:);
        x = 1:1:length(tempWavs(1,:));
        
        patchline(x,y,'linestyle','-','edgecolor',colors(cli),'linewidth',1,'edgealpha',0.1);
        hold on
        
    end
    
    
end

ptsymb = {'bs','r^','md','go','c+'};
for i = 1:2
    clust = find(clustIndex == i);
    plot3(testdata(clust,1), testdata(clust,2), testdata(clust,3), ptsymb{i});
    hold on
end
hold off
xlabel('Sepal Length');
ylabel('Sepal Width');
zlabel('Petal Length');
view(-137,10);
grid on










