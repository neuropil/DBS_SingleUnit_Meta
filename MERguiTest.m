function MERguiTest

ScreenSize = get(0,'screenSize');
ScreenSize = ScreenSize(3:4);

load(fullfile(fileparts(mfilename), '02075'));

hFig = figure(...
    'NumberTitle','off',...
    'Name', 'MER Analysis',...
    'Toolbar','none',...
    'Menu','none',...
    'Color','black',...
    'Units','Pixels',...
    'Position',[ScreenSize/2-[510, 340], 1000, 700], ...
    'BusyAction','cancel',...
    'Interruptible','off',...
    'Resize','off',...
    'DockControl','off');
% Construct main axes

%%

clf(hFig)

hAx = axes(...
    'Parent', hFig, ...
    'Units', 'Pixels', ...
    'Position', [25 700/2 1000-50 ((700/2)-25)], ...
    'Color', 'black', ...
    'XLim', [0 4], ...
    'YLim', [0 4], ...
    'XTick', [], ...
    'YTick', [], ...
    'XColor', 'white', ...
    'YColor', 'white', ...
    'Box', 'off', ...
    'XTickLabel', [], ...
    'YTickLabel', []);

timeAxis = linspace(0,length(CElectrode1)/(CElectrode1_KHz*1000),length(CElectrode1));

axes(hAx)
plot(timeAxis,CElectrode1,'r')
set(hAx,'Color','none')
set(hAx,'XColor','white','YColor','white')
set(hAx,'Box','off')

load(fullfile(fileparts(mfilename), 'iconData'));
%%

hToolbar = uitoolbar(...
    'Parent', hFig);
htb.hToolbarButtons(1) = uipushtool(...
    'Parent', hToolbar, ...
    'CData', new, ...
    'TooltipString', 'New game', ...
    'ClickedCallback', @newGame);
htb.hToolbarButtons(2) = uitoggletool(...
    'Parent', hToolbar, ...
    'CData', animOn, ...
    'Separator', 'on', ...
    'TooltipString', 'Animation: ON', ...
    'State', 'on', ...
    'ClickedCallback', @toggleAnimation);
htb.hToolbarButtons(3) = uitoggletool(...
    'Parent', hToolbar, ...
    'CData', eightball, ...
    'Separator', 'on', ...
    'State', 'off', ...
    'TooltipString', 'Run AI...', ...
    'ClickedCallback', @runAI);
htb.hToolbarButtons(4) = uitoggletool(...
    'Parent', hToolbar, ...
    'CData', curves, ...
    'Separator', 'on', ...
    'TooltipString', 'Show history', ...
    'State', 'off', ...
    'ClickedCallback', @toggleHistory);
htb.hToolbarButtons(5) = uipushtool(...
    'Parent', hToolbar, ...
    'CData', page_white, ...
    'TooltipString', 'Clear all scores...', ...
    'ClickedCallback', @clearScores);
htb.hToolbarButtons(6) = uipushtool(...
    'Parent', hToolbar, ...
    'CData', lightbulb, ...
    'Separator', 'on', ...
    'TooltipString', 'About...', ...
    'ClickedCallback', @aboutGame);





end






function newGame(src,eventdata)
% newGame  Callback when the "New Game" toolbar button is pressed

if nargin > 1
    btn = questdlg('Abandon current game?', 'New Game', 'Yes', 'No', 'Yes');
    switch btn
        case 'No'
            return
    end
end

%         % Reset game object
%         reset(obj.Game)
%
%         % Update the score history
%         updateAllScoresData(obj)
%
%         % Update the block visualization
%         updateBlocks(obj)
end

function toggleAnimation(varargin)
% toggleAnimation  Turn on/off animation of blocks

return

end


