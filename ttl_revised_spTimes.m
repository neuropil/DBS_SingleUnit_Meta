function [tsIndex] = ttl_revised_spTimes(CElectrode1, CElectrode1_KHz,...
    CElectrode1_TimeBegin, C1_DI001_KHz, C1_DI001_TimeBegin, TTLvector)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%%% Need to add UP and DOWN vectors


%% Reset TTL up and down vectors to align with ephys clock 0
TTL_fs_Hz = C1_DI001_KHz * 1000;
ephys_fs_Hz = CElectrode1_KHz * 1000;

% Single vector for all Ephys data
stitchedEphys = CElectrode1;

% Duration of time before first TTL Up Timestamp
expToffset = C1_DI001_TimeBegin - CElectrode1_TimeBegin; % in seconds


%% ADJUST TTL vector so it is ZEROED at the start of the ephys clock

% Need to reset TTL time stamps to zero at beginning of electrode time
% expToffset is the time diff between Electrode start and TTL start

% Get number of sampling points reflected by time difference
expToffSF = round(expToffset*TTL_fs_Hz);

% Total number of sampling possible sampling points for EPHYS
totTimeSampPoints = 0:1:length(stitchedEphys);
% Corresponding times of sampling points using EPHYS sampling frequency
totTimeSampTimes = totTimeSampPoints/(ephys_fs_Hz);

% THIS is a PARAMETER I'm still debating to help align the two SAMPLING
% frequencies between the TTL and EPHYS
roundVal = 100000;

% Rounding error to adjust values in range of TTL sampling frequency
totTimeSTround = round(totTimeSampTimes*roundVal)/roundVal;

% Account sampling point difference between start of ephys and start of TTL
resetTTL = TTLvector + expToffSF;
% Get times in seconds corresponding to sampling points
timeStampVec = resetTTL/TTL_fs_Hz;
% Rounding error adjust values in range of TTL sampling frequency
timeStampVR = round(timeStampVec*roundVal)/roundVal;

% Find the corresponding sampling point in the EPHYS DATA 
tsIndex = zeros(length(timeStampVR),1);
for tsI = 1:length(timeStampVR)
    
    ts = timeStampVR(tsI);
    
    if isempty(find(ismember(totTimeSTround,ts),1))
        [~, tsIndex(tsI)] = min(abs(totTimeSTround - ts));
    else
        tsIndex(tsI) = find(ismember(totTimeSTround,ts));
    end
 
end


end

