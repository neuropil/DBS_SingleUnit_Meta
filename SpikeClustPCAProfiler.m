function [] = SpikeClustPCAProfiler(plotInStruct)

voltTrace = plotInStruct.vt;
sampFreq = plotInStruct.sf;
clustID = plotInStruct.ci;
waveForms = plotInStruct.wf;
waveIndex = plotInStruct.wi;
spkIndex = plotInStruct.si;

sampMERFreq = sampFreq*1000;
timeAx = linspace(0,length(voltTrace)/(sampMERFreq),length(voltTrace));

%% Panel Setup

p = panel();
p.pack('h', 2);
p(1).pack({3/4 []})
p(2).pack({1/3 1/3 1/3})

p.select('all');

% set margins
p.de.margin = 3;
p(1).margintop = 30;
p(2).marginright = 20;
p.margin = [6 6 2 2];


%% Plot 1
p(1,1).select();
set(gca, 'XTick', [], 'YTick', []);
set(gca, 'XLim', [0 timeAx(length(timeAx))]);
plot(timeAx, voltTrace,'k')
hold on

spkWaves = waveForms;
spkInds = waveIndex;
numClus = max(clustID);

% Add overlay
for clusI = 1:numClus
    clusIndex = find(clustID == clusI);
    colors = {'r','c','g','m'};
    hold on
    for numS = 1:size(spkWaves(clustID == clusI,:),1)
        hold on
        tempSpkNum = clusIndex(numS);
        
        
        tempRaw = voltTrace(spkInds(tempSpkNum,:));
        tempTime = timeAx(spkInds(tempSpkNum,:));
        plot(tempTime,tempRaw,strcat(colors{clusI},'-'),'LineWidth',0.25);
        hold on
        
        
    end
end

% Plot 2
p(1,2).select();

set(gca,'YTick', []);
set(gca,'XTick',[0 timeAx(length(timeAx))/2 timeAx(length(timeAx))],...
        'XTickLabel',[0 timeAx(length(timeAx))/2 timeAx(length(timeAx))],...
        'XLim',[0 timeAx(length(timeAx))],...
        'YLim',[-0.5 numClus + 0.5]);
% For loop for time points

startY = 0;
endY = 1;
for clusI2 = 1:numClus
    
    clusIndex = clustID == clusI2;
    cluSpkInd = spkIndex(clusIndex);
    
    for timI = 1:sum(clusIndex)
        
        line([timeAx(cluSpkInd(timI)) timeAx(cluSpkInd(timI))],[startY endY],'Color',colors{clusI2},'LineWidth',0.1);
        hold on
        
    end
    
    startY = startY + 1;
    endY = endY + 1;
end


% Plot 3
p(2,1).select();
set(gca, 'xtick', [], 'ytick', []);

% X axis values 
tempLen = size(waveForms,2) + 5;
for clusI3 = 1:numClus
    
    clusWaves = waveForms(clustID == clusI3,:);
    for i = 1:size(clusWaves,1)
        
        y = clusWaves(i,:);
        
        if clusI3 == 1
            x = 1:1:length(clusWaves(1,:));
        else
            x = tempLen:1:length(clusWaves(1,:)) + tempLen - 1;
            
        end
        patchline(x,y,'linestyle','-','edgecolor',colors{clusI3},'linewidth',1,'edgealpha',0.1);
        hold on
        
    end
    if clusI3 ~= 1
        tempLen = tempLen + tempLen;
    end
end


% Plot 4 BrayCurtis Scatter plot
p(2,2).select();
set(gca, 'xtick', [], 'ytick', []);

BrayCurtis;





% Plot 5
p(2,3).select();
set(gca, 'xtick', [], 'ytick', []);

for clusI4 = 1:numClus
    clusWavesC = waveForms(clustID == clusI4,:);
    aveWave = mean(clusWavesC);
    stdWave = std(clusWavesC);
    plusWave = aveWave + stdWave;
    minsWave = aveWave - stdWave;
    
    hold on
    patchline(1:1:length(aveWave),aveWave,'linestyle','-','edgecolor',colors{clusI4},'linewidth',3,'edgealpha',0.5);
    patchline(1:1:length(plusWave),plusWave,'linestyle','--','edgecolor',colors{clusI4},'linewidth',1,'edgealpha',0.5);
    patchline(1:1:length(minsWave),minsWave,'linestyle','--','edgecolor',colors{clusI4},'linewidth',1,'edgealpha',0.5);

end




% 1. BrayCurtis scatter bar plot with new color map
% 2. Violin plots for braycurtis
% 3. gscatter with plot3d
% 4. Separate waveform transparent
% 5. Overlay waveform average







% tempTD = testdata(:,1:2);
% clustID = cluster(clusterObj,tempTD);
% 
% clustAll = struct;
% plotIDots = {'r.','g.','b.','k.','m.'};
% plotILines = {'r-','g-','b-','k-','m-'};
% colors = 'rgbkm';
% for cli = 1:max(clustID)
%     
%     clustAll.(strcat('clust',num2str(cli))) = tempTD(clustID == cli,:);
%     figure(1);
%     hold on
%     scatter(clustAll.(strcat('clust',num2str(cli)))(:,1),...
%         clustAll.(strcat('clust',num2str(cli)))(:,2),...
%         100,...
%         plotIDots{cli});
%     
%     figure(2);
%     hold on
%     plot(waveForms(clustID == cli,:)',plotILines{cli})
%     
%     figure(3);
%     tempWavs = waveForms(clustID == cli,:);
%     for wavi = 1:size(tempWavs,1)
%         
%         y = tempWavs(wavi,:);
%         x = 1:1:length(tempWavs(1,:));
%         
%         patchline(x,y,'linestyle','-','edgecolor',colors(cli),'linewidth',1,'edgealpha',0.1);
%         hold on
%         
%     end
%     
%     
% end
% 
% ptsymb = {'bs','r^','md','go','c+'};
% for i = 1:max(clustID)
%     clust = find(clustID == i);
%     plot3(testdata(clust,1), testdata(clust,2), testdata(clust,3), ptsymb{i});
%     hold on
% end
% hold off
% xlabel('Sepal Length');
% ylabel('Sepal Width');
% zlabel('Petal Length');
% view(-137,10);
% grid on



