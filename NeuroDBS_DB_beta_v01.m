function [CellInfo] = NeuroDBS_DB_beta_v01(sessNum, depthNum, eleNum)


% TO DO
% 10/10/14
% Add CElectode1_TimeBegin to get time differences between similar depths

% Location of all recording days for individual mice
BaseLoc = 'Y:\PreProcessEphysData\';
% Cell array of mice that have been recorded for experiments
cd(BaseLoc);
dirfolders = dir;
foldernamesTemp = {dirfolders.name};
foldernamesFinal = foldernamesTemp(~cellfun(@(x) strcmp('.',x(1)),foldernamesTemp));
expectedSessNames = foldernamesFinal;
expectedEleNames = {'CElectrode1', 'CElectrode2', 'CElectrode3'};

% mfilename is the name of the function$$$
% Checks if sessNum variable is a character array
validateattributes(sessNum, {'char'}, {'nonempty'}, mfilename, 'sessNum', 1)
% Checks if depthNum variable is a character array
validateattributes(depthNum, {'char'}, {'nonempty'}, mfilename, 'depthNum', 2)
% Checks if eleNum variable is a character array
validateattributes(eleNum, {'char'}, {'nonempty'}, mfilename, 'eleNum', 3)

% Checks whether selected mouseName is contained within Experimental mice
sessName = validatestring(sessNum, expectedSessNames, mfilename, 'sessNum', 1);

% Checks whether selected mouseName is contained Electrode Names
eleName = validatestring(eleNum, expectedEleNames, mfilename, 'eleNum', 1);

% If all input variables check out: then create folder indices
SessionLoc_all = strcat(BaseLoc,sessName);

cd(SessionLoc_all);

% Ensure you're not in a set folder %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get list of dates from mouse specified
all_depths = GetDirFileList(pwd);

% Checks whether selected recDate is contained within mouse's date folder
recDepth = validatestring(depthNum, all_depths, mfilename, 'depthNum', 2);

% Load in file of interest
load(recDepth);

% Get list of files in workspace
allWorkspace = who;

% Check if Electrode selected is present
eleCheck = ismember(eleName, allWorkspace);

if ~eleCheck
    disp('Electrode not present in file')
    return
end

%%%%% THIS IS WHERE I AM AT 10/28/2014



CellInfo = struct;

recDepthSep = strsplit(recDepth,'.');
eleCname = strcat('E',eleName(length(eleName)));
sessCname = strrep(sessName,'_','');

% Get Cell name from mouse,date,tetrode and cluster info
cellName = strcat('Cell_',sessCname,'_',recDepthSep{1},'_',eleCname);

% Calculate features for recreation or rederivation of PCA

sampFreq = sampFreqMER*1000; 
handles.datatype = 'unClustered';
handles.params = set_parameters_AO(sampFreq, cellName, handles);

tempSpkData = eval(eleName);

[thrOut] = SpikeThresholdCreate(tempSpkData, handles, 'Min9sig');
filtSpkData = thrOut.Filtered;
threshold = thrOut.AveThresh;
[wave_Struct] = SpikeTimeExtract(filtSpkData, threshold, handles);

waveForms = wave_Struct.spkWaveforms;

features = struct;
% Reduce dimensions and extract Waveforms of interest

% Peak
features.Peak = max(waveForms,[],2);
% Valley
features.Valley = min(waveForms,[],2);
% Energy
features.Energy = trapz(abs(waveForms'))';
% Width p-t
features.WidthPtT = WvPTdist(waveForms, sampFreq);
% Area

% Waveform Comparison (Bray-Curtis Index)
% Keep off during dbug TAKES a while to compute 6/10/2013

% BrayCurtis analysis expects waveforms to be formatted by with each column
% representing a new waveform and each row representing a time point
features.WaveSimIndex = BrayCurtisIndexMER(waveForms',cellName);

% First & Second Derivative analysis
features.FSDE_Values = FSDE_Method(waveForms');
    
% Combine for WavePCA analysis
featsForPCA = horzcat(features.Peak, features.Valley, features.Energy,...
    features.WidthPtT, features.WaveSimIndex, features.FSDE_Values.FDmin,...
    features.FSDE_Values.SDmin, features.FSDE_Values.SDmax);

%%%%%%%% NEED TO DO some testing

[~,features.WavePCs,~,~,Explained] = pca(featsForPCA);


% Derive Gaussian fit parameters for positive and negative
% component of waveform (Felsen and Thompson method)



%%%%%%%% OLD code




[features.WaveFitParams, features.WaveSumDS] = WaveFormFit(disindex,Clust_Waves);


% Load spike file
load(spkName)
% Transfer spike time data into seconds
spktms = spk_fi/1000000;

% For ISI calculation
msSpktms = spktms*1000; % convert spike times to milliseconds
spkIntervals = diff(msSpktms);
spkLogtimes = log(spkIntervals);
% for plotting: hist(spkLogtimes,100);
% for trouble shooting: ps = numel(find(spkIntervals < 1))/numel(spkIntervals)
perISIviolate = numel(find(spkLogtimes < 0))/numel(spkLogtimes);

ISIinfo.msSpktms = msSpktms;
ISIinfo.spkIntervals = spkIntervals;
ISIinfo.spkLogtimes = spkLogtimes;
ISIinfo.ISIviolations = perISIviolate;



CellInfo.MouseName = sessName;
CellInfo.RecordDate = recDepth;
CellInfo.Tetrode = getTetNum;
CellInfo.Cluster = getClustNum;
CellInfo.ADBitVolts = ADBitVolts;
CellInfo.InputRange = InputRange;
CellInfo.ThreshValues = ThreshValues;
CellInfo.Inverted = Inverted;
CellInfo.DualThreshold = DualThresh;
CellInfo.DisabledLeads = InactiveLeads;
CellInfo.ClustWaves = Clust_Waves;
CellInfo.ClusterIndex = clustCut;
CellInfo.SpikeTimes = spktms;
CellInfo.LRatio = LR;
CellInfo.IsolationDistance = ID;
CellInfo.Features = features;
CellInfo.Experiment = Expermt;
CellInfo.WaveIndex = WaveIndex;
CellInfo.ShortLong_Info = SLos;
CellInfo.ISIViolations = ISIinfo;
CellInfo.CurrentTrials = Current;
CellInfo.PreviousTrials = Previous;

cd('G:\Tetrode_DATA\Days of Recording\Neuron_Activity_Info_Database');

save(cellName,'-struct','CellInfo');



