function PlotSpikeOverlay(spkWavForms)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here



for i = 1:size(spkWavForms,1)
    
    y = spkWavForms(i,:);
    x = 1:1:length(spkWavForms(1,:));
    
    %         xflip = [x(1 : end - 1) fliplr(x)];
    %         yflip = [y(1 : end - 1) fliplr(y)];
    
    %         patch(xflip, yflip, colors{clusI3}, 'EdgeAlpha', 0.05, 'FaceColor', colors{clusI3});
    patchline(x,y,'linestyle','-','edgecolor','k','linewidth',1,'edgealpha',0.1);
    hold on
    
end
    





end

