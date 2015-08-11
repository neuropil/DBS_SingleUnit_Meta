function [ output_args ] = ConvertSpk2NeuroDB(cell_num)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

dbaseLoc = 'Y:\HumanNeuronDB';
cd(dbaseLoc)
%% Load Data
load(cell_num)

[trStart] = CalculateTrialStart(ttlInfo);
% % spktms = spk_fi/1000000;

[ref_spike_times, trial_inds, ref_times] =...
    Neuro_DB_raster(...
                    humanStruct.spikeEvents,...
                    trStart(trialIndex),... 
                    taskbase.OdorPokeIn(trialIndex));

end

