function [] = spikeProfiler_JAT2(waveStruct, clustStruct, rowNum, fileInfo)

f = figure(1);
strBuild = [];
if iscell(fileInfo)
    for si = 1:length(fileInfo)
        if si > 1
            strBuild = [strBuild '_' fileInfo{si}];
        else
            strBuild = fileInfo{si};
        end
    end
    figName = strBuild;
else
    figName = fileInfo;
end

load(fileInfo{1})

tempSpk = eval(fileInfo{2});
sampR = CElectrode1_KHz*1000;
timeAx = linspace(0,length(tempSpk)/(sampR),length(tempSpk));

%% (a) Prepare data
spikeNumVec = size(waveStruct{rowNum}.spkWaveforms,1);





%% (b)

p = panel();
p.pack({3/4 []}, {3/4 []});

%% (c)

p.select('all');

% set margins
p.de.margin = 3;
p(1).margintop = 30;
p(2).marginright = 20;
p.margin = [6 6 2 2];

% Plot 1
p(1,1).select();
set(gca, 'XTick', [], 'YTick', []);
set(gca, 'XLim', [0 timeAx(length(timeAx))]);
plot(timeAx, tempSpk,'k')
hold on

spkWaves = waveStruct{rowNum}.spkWaveforms;
spkInds = waveStruct{rowNum}.spkWaveIndices;
numClus = length(clustStruct{rowNum});

% Add overlay
for clusI = 1:numClus
    clusIndex = clustStruct{rowNum,1}{clusI,1}.cIndex;
    colors = {'r','b','g'};
    hold on
    for numS = 1:size(spkWaves(clusIndex,:),1)
        hold on
        tempSpkNum = clusIndex(numS);
        
        
        tempRaw = tempSpk(spkInds(tempSpkNum,:));
        tempTime = timeAx(spkInds(tempSpkNum,:));
        plot(tempTime,tempRaw,strcat(colors{clusI},'-'),'LineWidth',0.25);
        hold on
        
        
    end
end

% Plot 2
p(2,1).select();

set(gca,'YTick', []);
set(gca,'XTick',[0 timeAx(length(timeAx))/2 timeAx(length(timeAx))],...
        'XTickLabel',[0 timeAx(length(timeAx))/2 timeAx(length(timeAx))],...
        'XLim',[0 timeAx(length(timeAx))],...
        'YLim',[-0.5 numClus + 0.5]);
% For loop for time points

spkInd = waveStruct{rowNum}.spkIndex;

startY = 0;
endY = 1;
for clusI2 = 1:numClus
    
    clusIndex = spkInd(clustStruct{rowNum,1}{clusI2,1}.cIndex);
    
    for timI = 1:length(clusIndex)
        
        line([timeAx(clusIndex(timI)) timeAx(clusIndex(timI))],[startY endY],'Color',colors{clusI2},'LineWidth',0.1);
        hold on
        
    end
    
    startY = startY + 1;
    endY = endY + 1;
end


% Plot 3
p(1,2).select();
set(gca, 'xtick', [], 'ytick', []);

waveformMat = waveStruct{rowNum}.spkWaveforms;
for clusI3 = 1:numClus
    
    clusWaves = waveformMat(clustStruct{rowNum,1}{clusI3,1}.cIndex,:);
    for i = 1:size(clusWaves,1)
        
        y = clusWaves(i,:);
        x = 1:1:length(clusWaves(1,:));
        
%         xflip = [x(1 : end - 1) fliplr(x)];
%         yflip = [y(1 : end - 1) fliplr(y)];
        
%         patch(xflip, yflip, colors{clusI3}, 'EdgeAlpha', 0.05, 'FaceColor', colors{clusI3});
        patchline(x,y,'linestyle','-','edgecolor',colors{clusI3},'linewidth',1,'edgealpha',0.1);
        hold on
        
    end
    
end
xlabel(num2str(spikeNumVec))

% Plot 4
p(2,2).select();
set(gca, 'xtick', [], 'ytick', []);


% for i = 1:length(waveformMat)
%      hold on
%      x = 1:1:length(waveformMat(1,:));
%      y = waveformMat(i,:);
%      c = y;
%     
%     
%      multiColorLine(x,y,c)
%     
%     
%     
% end


set(gca, 'Color', [0.8 0.8 0.8]);
set(gca, 'Visible', 'off');

% for spki = 1:length()


