% Assume a row X column where row represents unique waveforms and columns
% equate different sampling points

function autoSomatic(waveForms)

[numWaves, numSmpPnts] = size(waveForms);

% Moving derivative

numKpoints = numSmpPnts - 2;
kPoints = 2:1:numSmpPnts - 1;

fstDir = zeros(numWaves,length(kPoints));
scdDir = zeros(numWaves,length(kPoints));

for wi = 1:numWaves
    
    tempWave = waveForms(wi,:);
    
    for ki = 1:numKpoints
        
        tempSeg = tempWave(kPoints(ki) - 1:kPoints(ki) + 1);
        fstDir(wi, ki) = mean(firstDer(tempSeg));
        scdDir(wi, ki) = mean(secondDer(tempSeg));
        
    end
    
end

% Calculate G curvature components
M = 10;
movAveF = zeros(numWaves,length(linspace(1,numKpoints,M)));
movAveS = zeros(numWaves,length(linspace(1,numKpoints,M)));

for wii = 1:numWaves
    tempF = fstDir(wii,:);
    tempS = scdDir(wii,:);
    
    start = 1;
    stop = M;
    for avi = 1:length(linspace(1,numKpoints,M))
        movAveF(wii, avi) = mean(tempF(start:stop));
        movAveS(wii, avi) = mean(tempS(start:stop));
        start = stop + 1;
        stop = stop + M;
    end
    
end



%% 1. Concatenate curvature values tempF and tempS

allData = [movAveF , movAveS];


%% 2. Normalize

ndataset = zeros(size(allData));

for di = 1:size(allData,2)
    tempCol = allData(:,di);
    % val - min(x) / max(x) - min(x)
    ndataset(:,di) = (tempCol - min(tempCol)) / (max(tempCol) - min(tempCol));
end



%% 3. PCA
% Exclude any PC values that < 0.5 variance

[coeff,score,latent] = pca(ndataset);


%% 4. 
opts = statset('Display','final');
[idx,C] = kmeans(score(:,1:3),2,'Distance','cityblock',...
    'Replicates',5,'Options',opts);

figure;
plot(score(idx==1,1),score(idx==1,2),'r.','MarkerSize',12)
hold on
plot(score(idx==2,1),score(idx==2,2),'b.','MarkerSize',12)
plot(C(:,1),C(:,2),'kx',...
     'MarkerSize',15,'LineWidth',3)
legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
title 'Cluster Assignments and Centroids'
hold off


plot(waveForms(idx == 1,:)','r')
hold on
plot(waveForms(idx == 2,:)','b')

plot3(score(:,1),score(:,2),score(:,3),'.')

end % END of main function




function FD = firstDer(s)
FD = zeros(length(s),1);
for n = 2:length(s)
    FD(n) = s(n) - s(n - 1);
end

end % END of firstDer


function SD = secondDer(s)
SD = zeros(length(s),1);
for n2 = 2:length(s)
    SD(n2) = s(n2) - s(n2 - 1);
end

end % END of secondDer











