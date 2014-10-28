function PlotSpikeOverlay(spkWavForms, boolControl)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


% Create push button

if boolControl
    
    uicontrol('Style', 'pushbutton', 'String', 'Close',...
        'Position', [10 10 50 20],...
        'Callback', 'close');
    
end

for i = 1:size(spkWavForms,1)
    
    y = spkWavForms(i,:);
    x = 1:1:length(spkWavForms(1,:));
    
    patchline(x,y,'linestyle','-','edgecolor','k','linewidth',1,'edgealpha',0.1);
    hold on
    
end







end

