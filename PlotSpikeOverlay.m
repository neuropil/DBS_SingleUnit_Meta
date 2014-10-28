function PlotSpikeOverlay(spkWavForms)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here



for i = 1:size(spkWavForms,1)
    
    y = spkWavForms(i,:);
    x = 1:1:length(spkWavForms(1,:));

    patchline(x,y,'linestyle','-','edgecolor','k','linewidth',1,'edgealpha',0.1);
    hold on
    
end
    





end

