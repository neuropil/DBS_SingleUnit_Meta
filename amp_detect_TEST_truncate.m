function [spikes,thresh_spike,index] = amp_detect_TEST_truncate(x,handles)
% Detect spikes with amplitude thresholding. Uses median estimation.
% Detection is done with filters set by fmin_detect and fmax_detect. Spikes
% are stored for sorting using fmin_sort and fmax_sort. This trick can
% eliminate noise in the detection but keeps the spikes shapes for sorting.

sampRate = handles.params.sr;
timePreWindow = handles.params.w_pre;
timePostWindow = handles.params.w_post;
% peak_ref = refers to point in wave window that represent crossing
peak_ref = handles.params.ref;
detect_direction = handles.params.detection;
stdmin = handles.params.stdmin;
stdmax = handles.params.stdmax;
fmin_detect = handles.params.detect_fmin;
fmax_detect = handles.params.detect_fmax;
fmin_sort = handles.params.sort_fmin;
fmax_sort = handles.params.sort_fmax;

% HIGH-PASS FILTER OF THE DATA
[b,a] = ellip(2,0.1,40,[fmin_detect fmax_detect]*2/sampRate);
spike_detect_filter = filtfilt(b,a,x);
[b,a] = ellip(2,0.1,40,[fmin_sort fmax_sort]*2/sampRate);
artifact_filter = filtfilt(b,a,x);

noise_std_detect = median(abs(spike_detect_filter)) / 0.6667; % x 1.5
noise_std_sorted = median(abs(artifact_filter)) / 0.6667;
thresh_spike = stdmin * noise_std_detect;        %thr for detection is based on detect settings.
thresh_artif = stdmax * noise_std_sorted;     %thrmax for artifact removal is based on sorted settings.

% set(handles.file_name,'string','Detecting spikes ...');

% Calculate time of signal
lengthOfTrace = round(length(spike_detect_filter)/sampRate);

% Calculate Maximum possible spikes if firing rate 600Hz
theorTmaxSpkNum = lengthOfTrace*600; 

if ~(strcmp(handles.datatype, 'pre-clustered)'))
        
    % LOCATE SPIKE TIMES
    switch detect_direction
        case 'pos'
            % Set up index vector with NaN - make longer than needed
            index  = nan(1,theorTmaxSpkNum);
            spikeNumber = 0; % Number of spikes detected
            % Extract all possible threshold crossings, use window :
            % starting prewindow + 2 of trace to postwindow - 2 
            % Add prewindow + 1 to each index value shifting thresholds by
            % that value
            thrXIndex_shft = find(spike_detect_filter(timePreWindow + 2:length(spike_detect_filter) - timePostWindow - 2) > thresh_spike) + timePreWindow + 1; 
            
            % Loop through candidate spikes
            % peak_ref = refers to point in wave window that represent crossing
            
            tempXindex = 0;
            for sptI = 1:length(thrXIndex_shft)
                if thrXIndex_shft(sptI) >= tempXindex + peak_ref % does current index occur within the range between previous index and one half wave window
                    % Get max index relative to threshold crossing
                    [~, relXindex] = max((artifact_filter(thrXIndex_shft(sptI):thrXIndex_shft(sptI) + floor(peak_ref / 2) - 1)));  %introduces alignment
                    spikeNumber = spikeNumber + 1;
                    index(spikeNumber) = relXindex + thrXIndex_shft(sptI) - 1; % subtract 1 to account for the shift
                    tempXindex = index(spikeNumber);
                end
            end
    end
    
    % Clear off NaNs
    index = index(~isnan(index));

    % SPIKE SORTING (with or without interpolation)
    spikeWindow = timePreWindow + timePostWindow; % number of points in spike window
    spikes = zeros(spikeNumber, spikeWindow + 4);
    
    % Adds buffer with the length of the post window
    % In case spike is located on last index of window
    artifact_filter = [artifact_filter zeros(1, timePostWindow)];
    
    % Eliminates artifacts
    for spkI = 1:spikeNumber                          
        % Get window around spike index for artifact filter
        % If max value in spike window less than artifact threshold then KEEP spike
        if max(abs(artifact_filter(index(spkI) - timePreWindow:index(spkI) + timePostWindow))) < thresh_artif
            % Adds one point to front and two points to back of window
            spikes(spkI,:) = artifact_filter(index(spkI) - timePreWindow - 1:index(spkI) + timePostWindow + 2);
        end
    end
    
    % Erases indexes that were artifacts
    % Zero rows would reflect skipped spikes from above for loop
    artifactIndex = find(spikes(:, timePreWindow) == 0);       
    spikes(artifactIndex,:) = [];
    index(artifactIndex) = [];

    % Eliminates borders that were introduced for interpolation
    switch handles.params.interpolation
        case 'n'
            spikes(:, end - 1:end) = [];      
            spikes(:, 1:2) = [];
        case 'y'
            %Does interpolation
            spikes = int_spikes_jat(spikes,handles);
    end
end
