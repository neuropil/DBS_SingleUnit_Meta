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
% Checks if mouseName variable is a character array
validateattributes(sessNum, {'char'}, {'nonempty'}, mfilename, 'sessNum', 1)
% Checks if recdate variable is a character array
validateattributes(depthNum, {'char'}, {'nonempty'}, mfilename, 'depthNum', 2)
% Checks if recdate variable is a character array
validateattributes(eleNum, {'char'}, {'nonempty'}, mfilename, 'eleNum', 3)

% Checks whether selected mouseName is contained within Experimental mice
sessName = validatestring(sessNum, expectedSessNames, mfilename, 'sessNum', 1);

% Checks whether selected mouseName is contained Electrode Names
eleName = validatestring(eleNum, expectedEleNames, mfilename, 'eleNum', 1);

% If all input variables check out: then create folder indices
SessionLoc_all = strcat(BaseLoc,sessName);

cd(SessionLoc_all);

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

%%%%% THIS IS WHERE I AM AT 10/28/2014

% If the recording day has been clustered than run_analysis = 1
switch run_analysis
    
    case 0
        
        warndlg('Need to Cluster Data','User Error')
        
    case 1
        


        for clustI = 1:length(fileS.t)

            CellInfo = struct;
            

            
            % Get Cell name from mouse,date,tetrode and cluster info
            cellName = strcat('Cell_',sessName,'_',recDepth,'_t',getTetNum,'_c',getClustNum);
            
            % Ensure that you're in Neurophysiology folder
            cd(NeuroLoc_date)
            

            
            fprintf('HEADER for cluster %d on tetrode %d in mouse %s recorded on %s evaluated...\n',...
                str2double(getClustNum), str2double(getTetNum), sessName, recDepth);
            

            % Calculate features for recreation or rederivation of PCA
            features = struct;
            for fi = 1:length(disindex)
                
                % Reduce dimensions and extract Waveforms of interest
                tempWaves = squeeze(Clust_Waves(:,disindex(fi),:));
                
                % Waveform Structure
                WaveIndex.(strcat('L',num2str(disindex(fi)))) = tempWaves;
                
                % Peak
                features.Peak.(strcat('L',num2str(disindex(fi)))) =...
                    max(tempWaves)';
                % Valley
                features.Valley.(strcat('L',num2str(disindex(fi)))) =...
                    min(tempWaves)';
                % Energy
                features.Energy.(strcat('L',num2str(disindex(fi)))) =...
                    trapz(abs(tempWaves))';
                % Combine for WavePCA analysis
                featsForPCA = horzcat(features.Peak.(strcat('L',num2str(disindex(fi)))),...
                    features.Valley.(strcat('L',num2str(disindex(fi)))),...
                    features.Energy.(strcat('L',num2str(disindex(fi)))));
                % WavePC1
                features.WavePC1.(strcat('L',num2str(disindex(fi)))) =...
                    pca(featsForPCA);
                % Waveform Comparison (Bray-Curtis Index)
                % Keep off during dbug TAKES a while to compute 6/10/2013
                
                features.WaveSimIndex.(strcat('L',num2str(disindex(fi)))) =...
                    BrayCurtisIndex(tempWaves,disindex(fi));
                
                
                % First & Second Derivative analysis
                features.FSDE_Values.(strcat('L',num2str(disindex(fi)))) =...
                    FSDE_Method(tempWaves);
                
            end
            
            % Derive Gaussian fit parameters for positive and negative
            % component of waveform (Felsen and Thompson method)
            [features.WaveFitParams, features.WaveSumDS] = WaveFormFit(disindex,Clust_Waves);
            
            fprintf('WAVEFORM FEATURES for cluster %d on tetrode %d in mouse %s recorded on %s calculated...\n',...
                str2double(getClustNum), str2double(getTetNum), sessName, recDepth);
            
           

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
            
        end
end



% Last things to do:
% Make sure all outputs in structure are accounted for




% Future things
% 1. Calculate values for Autocorrelation
% 2. Turn CellSelectivity into switch construction