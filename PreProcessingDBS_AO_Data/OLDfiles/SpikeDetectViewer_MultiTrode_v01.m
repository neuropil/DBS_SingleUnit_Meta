function varargout = SpikeDetectViewer_MultiTrode_v01(varargin)
% SPIKEDETECTVIEWER_MULTITRODE_V01 MATLAB code for SpikeDetectViewer_MultiTrode_v01.fig
%      SPIKEDETECTVIEWER_MULTITRODE_V01, by itself, creates a new SPIKEDETECTVIEWER_MULTITRODE_V01 or raises the existing
%      singleton*.
%
%      H = SPIKEDETECTVIEWER_MULTITRODE_V01 returns the handle to a new SPIKEDETECTVIEWER_MULTITRODE_V01 or the handle to
%      the existing singleton*.
%
%      SPIKEDETECTVIEWER_MULTITRODE_V01('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPIKEDETECTVIEWER_MULTITRODE_V01.M with the given input arguments.
%
%      SPIKEDETECTVIEWER_MULTITRODE_V01('Property','Value',...) creates a new SPIKEDETECTVIEWER_MULTITRODE_V01 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SpikeDetectViewer_MultiTrode_v01_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SpikeDetectViewer_MultiTrode_v01_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SpikeDetectViewer_MultiTrode_v01

% Last Modified by GUIDE v2.5 08-Dec-2015 09:22:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SpikeDetectViewer_MultiTrode_v01_OpeningFcn, ...
    'gui_OutputFcn',  @SpikeDetectViewer_MultiTrode_v01_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SpikeDetectViewer_MultiTrode_v01 is made visible.
function SpikeDetectViewer_MultiTrode_v01_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has noE1 output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SpikeDetectViewer_MultiTrode_v01 (see VARARGIN)

% Choose default command line output for SpikeDetectViewer_MultiTrode_v01
handles.output = hObject;

handles.yesE1.Value = 0;
handles.noE1.Value = 0;
handles.yesE2.Value = 0;
handles.noE2.Value = 0;
handles.yesE3.Value = 0;
handles.noE3.Value = 0;


set(handles.yesE1,'Enable','off')
set(handles.noE1,'Enable','off')
set(handles.yesE2,'Enable','off')
set(handles.noE2,'Enable','off')
set(handles.yesE3,'Enable','off')
set(handles.noE3,'Enable','off')
set(handles.seg_back,'Enable','off')
set(handles.seg_for,'Enable','off')
set(handles.next_file,'Enable','off')
set(handles.zIn,'Enable','off')
set(handles.zOut,'Enable','off')

set(handles.closeProgram,'Enable','off')

handles.messageTxt.String = 'Press the ''L'' Button to initiate the program';


%%%% TO DO

% Add Computer finding and save location creation code


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SpikeDetectViewer_MultiTrode_v01 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SpikeDetectViewer_MultiTrode_v01_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function loadFolder_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to loadFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


question = 'Select File location based on User ID';
title = 'File User ID';
selections = {'Gault_J','Thompson_J','Winter_M','Gibson_T'};
selectStr = 'Select User';
listSize = [180 150];

[fileLoc,~] = listdlg('PromptString',question,...
    'Name',title,...
    'SelectionMode','single',...
    'ListSize',listSize,...
    'OKString',selectStr,...
    'fus',15,...
    'ListString',selections);

rawFoldStart = PC_LocCheck_v01(fileLoc, 3);

rawDataLoc = uigetdir(rawFoldStart);

cd(rawDataLoc);

handles.SaveLoc = PC_LocCheck_v01(1, 6);

% Test folder with data
% cd('Y:\PreProcessEphysData\07_20_2015')

% Get mat file list
mDir = dir('*.mat');
mFnames = {mDir.name};

% Reorder with Abv and Below separate
mFnamesSp = cellfun(@(x) strsplit(x,'_'), mFnames, 'UniformOutput',false);
abF = cellfun(@(x) x{1}, mFnamesSp, 'UniformOutput',false);

aInd = cellfun(@(x) strcmp(x,'AbvTrgt'), abF);

depthNumsA = str2double(cellfun(@(x) x{2}, mFnamesSp(aInd), 'UniformOutput',false));
depthNumsB = str2double(cellfun(@(x) x{2}, mFnamesSp(~aInd), 'UniformOutput',false));

[~ , newOrderA] = sort(depthNumsA);
[~ , newOrderB] = sort(depthNumsB);

mFnamesA = mFnames(aInd);
mFnamesB = mFnames(~aInd);

mFnamesF = [mFnamesA(newOrderA)   mFnamesB(newOrderB)];

% Save mat file list as cell array in handles
handles.fNames = mFnamesF;
handles.FileTotal = numel(mFnamesF);
handles.activeFile.Num = 1;
handles.activeFile.Name = handles.fNames{handles.activeFile.Num};

% Load first file
firstFile = mFnamesF{1};
load(firstFile);
handles.activeFname = firstFile;

% Determine if CSPK or CElectrode

handles.activeE.E1 = CElectrode1;
handles.activeE.E2 = CElectrode2;
handles.activeE.E3 = CElectrode3;

handles.activeE.Temp = handles.activeE.E1;

handles.activeFR = round(mer.sampFreqHz);
% Calculate Segments

handles.activeLength.sPoints = length(handles.activeE.Temp);
handles.activeLength.tPoints = round(length(handles.activeE.Temp)/handles.activeFR); % in seconds

% Plot first segment
handles.activeLength.numSegs = floor(length(handles.activeE.Temp)/(handles.activeFR));
handles.activeLength.allSampPoints = 1:handles.activeLength.numSegs*round(handles.activeFR);

handles.activeLength.segSamps =...
    reshape(handles.activeLength.allSampPoints,...
    [round(handles.activeFR), handles.activeLength.numSegs])';

handles.eleColor.E1 = 'r';
handles.eleColor.E2 = 'b';
handles.eleColor.E3 = [0 0.49 0];

% Plot First electrode
axes(handles.ele1win)

plot(linspace(0,size(handles.activeLength.segSamps,2)/handles.activeFR,...
    length(handles.activeLength.segSamps(1,:))),...
    handles.activeE.E1(handles.activeLength.segSamps(1,:)),...
    'Color',handles.eleColor.E1)

ylim([-6000 6000]);
handles.ele1win.XTick = [];
handles.ele1win.YTick = [];

% Plot Second electrode
axes(handles.ele2win)

plot(linspace(0,size(handles.activeLength.segSamps,2)/handles.activeFR,...
    length(handles.activeLength.segSamps(1,:))),...
    handles.activeE.E2(handles.activeLength.segSamps(1,:)),...
    'Color',handles.eleColor.E2)

ylim([-6000 6000]);
handles.ele2win.XTick = [];
handles.ele2win.YTick = [];

% Plot Thrid electrode
axes(handles.ele3win)

plot(linspace(0,size(handles.activeLength.segSamps,2)/handles.activeFR,...
    length(handles.activeLength.segSamps(1,:))),...
    handles.activeE.E3(handles.activeLength.segSamps(1,:)),...
    'Color',handles.eleColor.E3)

ylim([-6000 6000]);
handles.ele3win.XTick = [];
handles.ele3win.YTick = [];


handles.NUMsegs.String = '1';
allFileParts = strsplit(rawDataLoc,'\');

if strcmp(allFileParts{length(allFileParts)}(1:3),'Set')
    % Determine set number
    setNum = allFileParts{length(allFileParts)}(4);
    handles.setNum = setNum;
    
    surgNumStr = allFileParts{length(allFileParts)-1};
    
    surgNumParts = strsplit(surgNumStr);
    
    if length(surgNumParts) > 3
        % Determine surgery number
        surgNum = surgNumParts{length(surgNumParts)};
        handles.surgNum = surgNum;
    else
        handles.surgNum = '1';
    end
    
    handles.caseNum.String = allFileParts{length(allFileParts)-1};
    
else
    
    handles.setNum = '1';
   
    surgNumStr = allFileParts{length(allFileParts)};
    surgNumParts = strsplit(surgNumStr);
    
    if length(surgNumParts) > 3
        % Determine surgery number
        surgNum = surgNumParts{length(surgNumParts)};
        handles.surgNum = surgNum;
    else
        handles.surgNum = '1';
    end
    
    handles.caseNum.String = allFileParts{length(allFileParts)};
    
end





handles.depthVal.String = handles.activeFname;

set(handles.yesE1,'Enable','on')
set(handles.noE1,'Enable','on')
set(handles.yesE2,'Enable','on')
set(handles.noE2,'Enable','on')
set(handles.yesE3,'Enable','on')
set(handles.noE3,'Enable','on')


set(handles.seg_back,'Enable','on')
set(handles.seg_for,'Enable','on')
set(handles.next_file,'Enable','on')
set(handles.zIn,'Enable','on')
set(handles.zOut,'Enable','on')

handles.totFile.String = num2str(handles.FileTotal);
handles.curFile.String = num2str(1);

% Set up Export data structure

handles.SpikeInfo.CaseNum = handles.caseNum.String;

% Figure out which computer the program is being and by whom to determine
% SAVE location

% handles.SaveLoc

handles.messageTxt.String = 'Folder Successfully loaded!';

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in seg_back.
function seg_back_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% hObject    handle to seg_back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



handles.curSeg = get(handles.NUMsegs,'String');
if str2double(handles.curSeg) == 1;
    
    
    handles.messageTxt.String = 'At the LOWEST segment';
    
    return
    
else
    % Update Segment Handle
    handles.curSeg = num2str(str2double(handles.curSeg) - 1);
    set(handles.NUMsegs,'String',handles.curSeg);
    
    % Plot All Segments
    
    % Plot first segment
    plotSEG = str2double(handles.curSeg);
    timeAXact = handles.activeLength.segSamps(plotSEG,:);
    timeAXreal = timeAXact/handles.activeFR;
    
    for i = 1:3;
        
        % Load axis image
        axes(handles.(strcat('ele',num2str(i),'win'))) %#ok<*LAXES>
        
        activeEle = handles.activeE.(strcat('E',num2str(i)));
        eleCol = handles.eleColor.(strcat('E',num2str(i)));
        
        plot(timeAXreal,...
            activeEle(handles.activeLength.segSamps(plotSEG,:)),...
            'Color',eleCol)
        % xlim([0 length(handles.activeE1)/handles.activeFR])
        xlim([timeAXreal(1) timeAXreal(end)])
        ylim([-6000 6000]);
        handles.(strcat('ele',num2str(i),'win')).XTick = [];
        handles.(strcat('ele',num2str(i),'win')).YTick = [];
        
        
    end
    
    handles.messageTxt.String = 'Advanced Segment Window BACKWARD';
    
end




guidata(hObject, handles);



% --- Executes on button press in seg_for.
function seg_for_Callback(hObject, eventdata, handles)
% hObject    handle to seg_for (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



handles.curSeg = get(handles.NUMsegs,'String');
if str2double(handles.curSeg) == handles.activeLength.numSegs;
    
    
    handles.messageTxt.String = 'At the HIGHEST segment';
    
    return
    
else
    % Update Segment Handle
    handles.curSeg = num2str(str2double(handles.curSeg) + 1);
    set(handles.NUMsegs,'String',handles.curSeg);
    
    % Plot first segment
    plotSEG = str2double(handles.curSeg);
    timeAXact = handles.activeLength.segSamps(plotSEG,:);
    timeAXreal = timeAXact/handles.activeFR;
    
    for i = 1:3;
        
        % Load axis image
        axes(handles.(strcat('ele',num2str(i),'win'))) %#ok<*LAXES>
        
        activeEle = handles.activeE.(strcat('E',num2str(i)));
        eleCol = handles.eleColor.(strcat('E',num2str(i)));
        
        plot(timeAXreal,...
            activeEle(handles.activeLength.segSamps(plotSEG,:)),...
            'Color',eleCol)
        % xlim([0 length(handles.activeE1)/handles.activeFR])
        xlim([timeAXreal(1) timeAXreal(end)])
        ylim([-6000 6000]);
        handles.(strcat('ele',num2str(i),'win')).XTick = [];
        handles.(strcat('ele',num2str(i),'win')).YTick = [];
        
        
    end
    
     handles.messageTxt.String = 'Advanced Segment Window FORWARD';
    
end




guidata(hObject, handles);







% --- Executes on button press in next_file.
function next_file_Callback(hObject, eventdata, handles)
% hObject    handle to next_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

analyzCheck = [handles.yesE1.Value , handles.noE1.Value , handles.yesE2.Value ,...
               handles.noE2.Value , handles.yesE3.Value , handles.noE3.Value];

% Add file check

if sum(analyzCheck) < 3;
    % User has not selected 'yese1' or 'noe1'
    
    handles.messageTxt.String = 'All Electrodes have NOT been assessed';
    
    return
else
    
    % Interface is ready to advance to next file
    
    % Go to next file
    
    % Reset Electrode Function
    % Handle for total number of files
    % Handle for active file
    handles = new_file_process(handles);
    
    % Depth Num
    handles.depthVal.String = handles.activeFname;
    handles.curFile.String = num2str(handles.activeFile.Num);
    
    % Reset Buttons
    handles.yesE1.Value = 0;
    handles.noE1.Value = 0;
    handles.yesE2.Value = 0;
    handles.noE2.Value = 0;
    handles.yesE3.Value = 0;
    handles.noE3.Value = 0;
    
    set(handles.seg_back,'Enable','on');
    set(handles.seg_for,'Enable','on');
    
%     handles.messageTxt.String = 'Next File Successfully Loaded';
    
end


% Update handles structure
guidata(hObject, handles);







% --- JAT's FUNCTION.
function [handles] = new_file_process(handles)

if handles.activeFile.Num == handles.FileTotal
    % Save mat file list as cell array in handles
    
    % Reset Interface
    set(handles.yesE1,'Enable','off')
    set(handles.noE1,'Enable','off')
    set(handles.yesE2,'Enable','off')
    set(handles.noE2,'Enable','off')
    set(handles.yesE3,'Enable','off')
    set(handles.noE3,'Enable','off')
    set(handles.seg_back,'Enable','off')
    set(handles.seg_for,'Enable','off')
    set(handles.next_file,'Enable','off')
    set(handles.zIn,'Enable','off')
    set(handles.zOut,'Enable','off')
    
    % Clear figures;
    
    cla(handles.ele1win);
    cla(handles.ele2win);
    cla(handles.ele3win);
    
    
    % Message indicating files transferring
    
    handles.messageTxt.String = 'Files exporting...';
    drawnow
    
    export_data(handles);
    
    % Message indicating files transferred
    
    handles.messageTxt.String = 'Files exported!! Select either ''L'' for a new folder or ''X'' to Exit...';
    drawnow
    
    % Including message to close or open new folder
    
    set(handles.closeProgram,'Enable','on')
    
    return
    
else
    
    handles.activeFile.Num = handles.activeFile.Num + 1;
    handles.activeFile.Name = handles.fNames{handles.activeFile.Num};
    
    load(handles.activeFile.Name);
    handles.activeFname = handles.activeFile.Name;
    
    % Determine if CSPK or CElectrode
    
    handles.activeE.E1 = CElectrode1;
    handles.activeE.E2 = CElectrode2;
    handles.activeE.E3 = CElectrode3;
    
    handles.activeE.Temp = handles.activeE.E1;
    
    handles.activeFR = round(mer.sampFreqHz);
    % Calculate Segments
    
    handles.activeLength.sPoints = length(handles.activeE.Temp);
    handles.activeLength.tPoints = round(length(handles.activeE.Temp)/handles.activeFR); % in seconds
    
    % Load axis image
    axes(handles.ele1win)
    
    % Plot first segment
    
    handles.activeLength.numSegs = floor(length(handles.activeE.Temp)/(handles.activeFR));
    handles.activeLength.allSampPoints = 1:handles.activeLength.numSegs*round(handles.activeFR);
    
    handles.activeLength.segSamps =...
        reshape(handles.activeLength.allSampPoints,...
        [round(handles.activeFR), handles.activeLength.numSegs])';
    
    
    handles.eleColor.E1 = 'r';
    handles.eleColor.E2 = 'b';
    handles.eleColor.E3 = [0 0.49 0];
    
    % Plot First electrode
    axes(handles.ele1win)
    
    plot(linspace(0,size(handles.activeLength.segSamps,2)/handles.activeFR,...
        length(handles.activeLength.segSamps(1,:))),...
        handles.activeE.E1(handles.activeLength.segSamps(1,:)),...
        'Color',handles.eleColor.E1)
    
    ylim([-6000 6000]);
    handles.ele1win.XTick = [];
    handles.ele1win.YTick = [];
    
    % Plot Second electrode
    axes(handles.ele2win)
    
    plot(linspace(0,size(handles.activeLength.segSamps,2)/handles.activeFR,...
        length(handles.activeLength.segSamps(1,:))),...
        handles.activeE.E2(handles.activeLength.segSamps(1,:)),...
        'Color',handles.eleColor.E2)
    
    ylim([-6000 6000]);
    handles.ele2win.XTick = [];
    handles.ele2win.YTick = [];
    
    % Plot Thrid electrode
    axes(handles.ele3win)
    
    plot(linspace(0,size(handles.activeLength.segSamps,2)/handles.activeFR,...
        length(handles.activeLength.segSamps(1,:))),...
        handles.activeE.E3(handles.activeLength.segSamps(1,:)),...
        'Color',handles.eleColor.E3)
    
    ylim([-6000 6000]);
    handles.ele3win.XTick = [];
    handles.ele3win.YTick = [];
    
    
    
    
    
    
    
    
    
    
    handles.NUMsegs.String = '1';
    
    
end






% Update handles structure
% guidata(hObject, handles);


% --- Executes on button press in zOut.
function zOut_Callback(hObject, eventdata, handles)
% hObject    handle to zOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% Plot All Segments

for i = 1:3;
    
    % Load axis image
    axes(handles.(strcat('ele',num2str(i),'win'))) %#ok<*LAXES>
    
    activeEle = handles.activeE.(strcat('E',num2str(i)));
    eleCol = handles.eleColor.(strcat('E',num2str(i)));
    
    plot(linspace(0,length(handles.activeLength.allSampPoints)/handles.activeFR,...
        length(handles.activeLength.allSampPoints)),...
        activeEle(handles.activeLength.allSampPoints),...
        'Color',eleCol)
    % xlim([0 length(handles.activeE1)/handles.activeFR])
    ylim([-6000 6000]);
    handles.(strcat('ele',num2str(i),'win')).XTick = [];
    handles.(strcat('ele',num2str(i),'win')).YTick = [];
    
    
end

% Turn off Segment buttons
set(handles.seg_back,'Enable','off');
set(handles.seg_for,'Enable','off');



% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in zIn.
function zIn_Callback(hObject, eventdata, handles)
% hObject    handle to zIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% Plot All Segments

for i = 1:3;
    
    % Load axis image
    axes(handles.(strcat('ele',num2str(i),'win'))) %#ok<*LAXES>
    
    % Plot active segment
    handles.curSeg = str2double(handles.NUMsegs.String);
    
    activeEle = handles.activeE.(strcat('E',num2str(i)));
    eleCol = handles.eleColor.(strcat('E',num2str(i)));
    
    
    plot(linspace(0,size(handles.activeLength.segSamps,2)/handles.activeFR,...
        length(handles.activeLength.segSamps(handles.curSeg,:))),...
        activeEle(handles.activeLength.segSamps(handles.curSeg,:)),...
        'Color',eleCol)
    % xlim([0 length(handles.activeE1)/handles.activeFR])
    ylim([-6000 6000]);
    handles.(strcat('ele',num2str(i),'win')).XTick = [];
    handles.(strcat('ele',num2str(i),'win')).YTick = [];
    
    
end

% Turn on Segment buttons
set(handles.seg_back,'Enable','on');
set(handles.seg_for,'Enable','on');


% Update handles structure
guidata(hObject, handles);



% --- Executes when selected object is changed in analysisPanel_1.
function analysisPanel_1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in analysisPanel_1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% Get the values of the radio buttons in this group.
yesVal1 = handles.yesE1.Value;
noVal1 = handles.noE1.Value;

if yesVal1
    
    % Set up Export data structure
    
    handles.SpikeInfo.DepthID{handles.activeFile.Num,1} = handles.activeFname;
    handles.SpikeInfo.DepthIND{handles.activeFile.Num,1}(1,1) = 1;
    
elseif noVal1
    
    % Set up Export data structure
    
    handles.SpikeInfo.DepthID{handles.activeFile.Num,1} = handles.activeFname;
    handles.SpikeInfo.DepthIND{handles.activeFile.Num,1}(1,1) = 0;
    
    
end


% Update handles structure
guidata(hObject, handles);



% --- Executes when selected object is changed in analysisPanel_2.
function analysisPanel_2_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in analysisPanel_2
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the values of the radio buttons in this group.
yesVal2 = handles.yesE2.Value;
noVal2 = handles.noE2.Value;

if yesVal2
    
    % Set up Export data structure
    
    handles.SpikeInfo.DepthID{handles.activeFile.Num,1} = handles.activeFname;
    handles.SpikeInfo.DepthIND{handles.activeFile.Num,1}(2,1) = 1;
    
elseif noVal2
    
    % Set up Export data structure
    
    handles.SpikeInfo.DepthID{handles.activeFile.Num,1} = handles.activeFname;
    handles.SpikeInfo.DepthIND{handles.activeFile.Num,1}(2,1) = 0;
    
    
end


% Update handles structure
guidata(hObject, handles);





% --- Executes when selected object is changed in analysisPanel_3.
function analysisPanel_3_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in analysisPanel_3
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the values of the radio buttons in this group.
yesVal3 = handles.yesE3.Value;
noVal3 = handles.noE3.Value;

if yesVal3
    
    % Set up Export data structure
    
    handles.SpikeInfo.DepthID{handles.activeFile.Num,1} = handles.activeFname;
    handles.SpikeInfo.DepthIND{handles.activeFile.Num,1}(3,1) = 1;
    
elseif noVal3
    
    % Set up Export data structure
    
    handles.SpikeInfo.DepthID{handles.activeFile.Num,1} = handles.activeFname;
    handles.SpikeInfo.DepthIND{handles.activeFile.Num,1}(3,1) = 0;
    
    
end


% Update handles structure
guidata(hObject, handles);


% --- JAT's FUNCTION.
function [] = export_data(handles)

data2save = handles.SpikeInfo; %#ok<NASGU>

% Create new Save folder if necessary

finalSaveLoc = strcat(handles.SaveLoc);


cd(finalSaveLoc)

% Include in SaveName set and surgery number


saveName = strcat(handles.caseNum.String,'_setNum_',handles.setNum,'_TOspk.mat');

save(saveName,'-struct','data2save');


% --------------------------------------------------------------------
function closeProgram_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to closeProgram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 close(handles.figure1)
