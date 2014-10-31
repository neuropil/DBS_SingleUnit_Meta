function [] = MultiClusOverlayPlot(plotInStruct, bcClustInd)

voltTrace = plotInStruct.vt;
sampFreq = plotInStruct.sf;
clustID = plotInStruct.ci;
waveForms = plotInStruct.wf;
waveIndex = plotInStruct.wi;

if nargin == 1;
    bcClustInd = {};
    numClus = max(clustID);
else
    numClus = length(bcClustInd);
end

sampMERFreq = sampFreq*1000;
timeAx = linspace(0,length(voltTrace)/(sampMERFreq),length(voltTrace));

figure;
set(gca, 'XTick', [], 'YTick', []);
set(gca, 'XLim', [0 timeAx(length(timeAx))]);
plot(timeAx, voltTrace,'k')
hold on

spkWaves = waveForms;
spkInds = waveIndex;

if isempty(bcClustInd)
    clusTag = 0;
else
    clusTag = 1;
end

cMap = colormap('jet');
colors = cMap(round(linspace(1,64,numClus)),:);

% Add overlay
for clusI = 1:numClus
    
    switch clusTag
        case 0
            clusIndex = find(clustID == clusI);
            maxWave = size(spkWaves(clustID == clusI,:),1);
        case 1
            clusIndex = bcClustInd{clusI};
            maxWave = length(clusIndex);
    end

    hold on
    
    for numS = 1:maxWave
        hold on
        tempSpkNum = clusIndex(numS);
        
        
        tempRaw = voltTrace(spkInds(tempSpkNum,:));
        tempTime = timeAx(spkInds(tempSpkNum,:));
        plot(tempTime,tempRaw,'Color',colors(clusI,:),'LineWidth',0.25);
        hold on
        
        
    end
end


figure;
for clusI = 1:numClus
    
    subplot(5,5,clusI);
    
    switch clusTag
        case 0
            clusIndex = find(clustID == clusI);

        case 1
            clusIndex = bcClustInd{clusI};

    end
    
    spkWavForms = waveForms(clusIndex,:);
    
    for i = 1:numel(clusIndex);
        
        y = spkWavForms(i,:);
        x = 1:1:length(spkWavForms(1,:));
        
        patchline(x,y,'linestyle','-','edgecolor',colors(clusI,:),'linewidth',1,'edgealpha',0.5);
        hold on
        
    end

end





end

