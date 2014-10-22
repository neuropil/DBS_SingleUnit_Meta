function varargout = merguitest_v0(varargin)
% MERGUITEST_V0 MATLAB code for merguitest_v0.fig
%      MERGUITEST_V0, by itself, creates a new MERGUITEST_V0 or raises the existing
%      singleton*.
%
%      H = MERGUITEST_V0 returns the handle to a new MERGUITEST_V0 or the handle to
%      the existing singleton*.
%
%      MERGUITEST_V0('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MERGUITEST_V0.M with the given input arguments.
%
%      MERGUITEST_V0('Property','Value',...) creates a new MERGUITEST_V0 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before merguitest_v0_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to merguitest_v0_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help merguitest_v0

% Last Modified by GUIDE v2.5 04-Aug-2014 09:40:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @merguitest_v0_OpeningFcn, ...
    'gui_OutputFcn',  @merguitest_v0_OutputFcn, ...
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


% --- Executes just before merguitest_v0 is made visible.
function merguitest_v0_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to merguitest_v0 (see VARARGIN)

% Choose default command line output for merguitest_v0
handles.output = hObject;

toolT = sprintf('Depths represented in mm from target');

set(handles.depthTable,'ColumnName',{'Depth'},...
    'ColumnWidth', {85},...
    'ColumnFormat',{'short'},...
    'TooltipString', toolT,...
    'FontWeight', 'bold',...
    'FontSize', 14,...
    'Enable','off')




% Update handles structure
guidata(hObject, handles);

% UIWAIT makes merguitest_v0 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = merguitest_v0_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function fileOpts_Callback(hObject, eventdata, handles)
% hObject    handle to loadF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function eleOpts_Callback(hObject, eventdata, handles)
% hObject    handle to loadF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function loadF_Callback(hObject, eventdata, handles)
% hObject    handle to loadF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% TO DO
% Add option to select Patient Day


% CD to file folder location
cd('Y:\AlphaOmegaMatlabData\06_19_2014')
% Get a list of depth files
dirFiles = dir('*.mat');
dirTable = struct2table(dirFiles);
depthNames = dirTable.name;
% Convert and reorder to Depth names
[handles.depthActNames , handles.depthFnames] = ConvertDepthNames(depthNames);
% Convert one more time
newDFs = cell(length(handles.depthFnames),1);
for ndf = 1:length(handles.depthFnames)
    newDFs{ndf} = sprintf('%0.2f',handles.depthFnames(ndf));
end
% Set Depth table
set(handles.depthTable,'Data',newDFs)
set(handles.depthTable,'Enable','on');





guidata(hObject, handles);

% --------------------------------------------------------------------
function exitP_Callback(hObject, eventdata, handles)
% hObject    handle to exitP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% TO DO
% Add figure delete code





% --- Executes when selected cell(s) is changed in depthTable.
function depthTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to depthTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

% FUTURE CHANGE : CHANGE to USER SELECTED DIRECTORY************************
cd('Y:\AlphaOmegaMatlabData\06_19_2014')

% Get user selection from Depth table
selection = eventdata.Indices(1);
% Get filename
handles.fileName = handles.depthActNames{selection};
% Load this mfile
load(handles.depthActNames{selection})
% Get Electrode data
handles.EL1 = CElectrode1;
handles.EL2 = CElectrode2;
handles.EL3 = CElectrode3;

handles.timeAxisLONG = linspace(0,length(CElectrode1)/(CElectrode1_KHz*1000),length(CElectrode1));
handles.shortAXISind = handles.timeAxisLONG <= 1;
handles.timeAxisSHORT = handles.timeAxisLONG(handles.timeAxisLONG <= 1);

handles.datatype = 'unClustered';
USER_DATA = get(handles.figure1,'userdata');

handles.sampleRate = CElectrode1_KHz*1000;








axes(handles.ele1show)
plot(handles.timeAxisSHORT,handles.EL1(handles.shortAXISind),'r')
set(handles.ele1show,'Color','none',...
    'XColor','white','YColor','white',...
    'Box','off','YTickLabel',[],'XTickLabel',[],...
    'YLim',[-6000 6000])

axes(handles.ele2show)
plot(handles.timeAxisSHORT,handles.EL2(handles.shortAXISind),'Color', [0.4 0.6 1])
set(handles.ele2show,'Color','none',...
    'XColor','white','YColor','white',...
    'Box','off','YTickLabel',[],'XTickLabel',[],...
    'YLim',[-10000 10000])

axes(handles.ele3show)
plot(handles.timeAxisSHORT,handles.EL3(handles.shortAXISind),'g')
set(handles.ele3show,'Color','none',...
    'XColor','white','YColor','white',...
    'Box','off','YTickLabel',[],'XTickLabel',[],...
    'YLim',[-10000 10000])

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ele1show_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ele1show (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate ele1show


% --- Executes on mouse press over axes background.
function ele1show_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ele1show (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.voltTrace)
plot(handles.timeAxisLONG,handles.EL1,'r')
set(handles.voltTrace,'Color','none',...
    'XColor','white','YColor','white',...
    'Box','off','YLim',[-10000 10000])
ylabel('microVolts')


% --- Executes on mouse press over axes background.
function ele2show_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ele2show (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.voltTrace)
plot(handles.timeAxisLONG,handles.EL2,'Color',[0.4 0.6 1])
set(handles.voltTrace,'Color','none',...
    'XColor','white','YColor','white',...
    'Box','off','YLim',[-10000 10000])
ylabel('microVolts')


% --- Executes on mouse press over axes background.
function ele3show_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ele3show (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.voltTrace)
plot(handles.timeAxisLONG,handles.EL3,'g')
set(handles.voltTrace,'Color','none',...
    'XColor','white','YColor','white',...
    'Box','off','YLim',[-10000 10000])
ylabel('microVolts')


% --------------------------------------------------------------------
function ext_spk_Callback(hObject, eventdata, handles)
% hObject    handle to ext_spk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles.params = set_parameters_CSC_jat(handles.sampleRate,handles.fileName,handles);     % Load parameters

%Load continuous data
% CHANGE EL1 to selected PLOT 
% TO CHANGE : Change from amp_detect_TEST to amp_detect_jat; 
[spikes,thr,index] = amp_detect_TEST(handles.EL1,handles);   %detection with amp. thresh.

USER_DATA = get(handles.figure1,'userdata');
USER_DATA{2} = spikes;
USER_DATA{3} = index;
set(handles.figure1,'userdata',USER_DATA);

[inspk] = wave_features_jat(spikes, handles);               %Extract spike features.

if handles.params.permut == 'y'
    if handles.params.match == 'y';
        naux = min(handles.params.max_spk,size(inspk,1));
        ipermut = randperm(length(inspk));
        ipermut(naux+1:end) = [];
        inspk_aux = inspk(ipermut,:);
    else
        ipermut = randperm(length(inspk));
        inspk_aux = inspk(ipermut,:);
    end
else
    if handles.params.match == 'y';
        naux = min(handles.params.max_spk,size(inspk,1));
        inspk_aux = inspk(1:naux,:);
    else
        inspk_aux = inspk;
    end
end

%Interaction with SPC
% set(handles.file_name,'string','Running SPC ...');
fname_in = handles.params.fname_in;
save([fname_in],'inspk_aux','-ascii');                      %Input file for SPC
handles.params.fnamesave = [handles.params.fname];          %filename if "save clusters" button is pressed
handles.params.fnamespc = handles.params.fname;
handles.params.fname = [handles.params.fname '_wc'];        %Output filename of SPC
[clu,tree] = run_cluster_jat(handles);
USER_DATA = get(handles.figure1,'userdata');

if exist('ipermut')
    clu_aux = zeros(size(clu,1),length(index)) + 1000;
    for i=1:length(ipermut)
        clu_aux(:,ipermut(i)+2) = clu(:,i+2);
    end
    clu_aux(:,1:2) = clu(:,1:2);
    clu = clu_aux; clear clu_aux
    USER_DATA{12} = ipermut;
end

USER_DATA{4} = clu;
USER_DATA{5} = tree;
USER_DATA{7} = inspk;
set(handles.figure1,'userdata',USER_DATA)
