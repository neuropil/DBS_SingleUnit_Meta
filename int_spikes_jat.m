function [waveIntOut, spikes1] = int_spikes_jat(spikes, handles)
%Interpolates with cubic splines to improve alignment.

% Handle Parameters
timePreWindow = handles.params.w_pre;
timePostWindow = handles.params.w_post;
spikeWaveWindow = timePreWindow + timePostWindow;
detect_direction = handles.params.detection;
% Interpolation factor
int_factor = handles.params.int_factor;

% Derived Spike Parameters
spikeNum = size(spikes,1);
spikeWindowVec = 1:size(spikes,2);
intervals = 1/int_factor:1/int_factor:size(spikes,2);

intspikes = zeros(1, length(intervals));
% Use original wave window length which will remove leading and trailing
% buffers
spikes1 = zeros(spikeNum, spikeWaveWindow);
waveIntOut = zeros(spikeNum, spikeWaveWindow);

switch detect_direction
    case 'pos'
        % For each Spike
        for i = 1:spikeNum
            % Interpolate each spike with interval factor
            intspikes(:) = spline(spikeWindowVec, spikes(i,:), intervals);
            % Attempt to find index for peak value during threshold crossing
            [~, iaux] = max((intspikes(timePreWindow * int_factor:timePreWindow * int_factor + 8))); 
            % Window before original threshold crossing * inter factor -1
            % and + peak index
            iaux = iaux + timePreWindow * int_factor - 1;
            % For each spike index extract the even numbers to rederive the
            % original waveform
            spikes1(i, timePreWindow:-1:1) = intspikes(iaux:-int_factor:iaux - timePreWindow * int_factor + int_factor);
            spikes1(i, timePreWindow + 1:spikeWaveWindow) = intspikes(iaux + int_factor:int_factor:iaux + timePostWindow * int_factor);

            waveIntOut(i, timePreWindow:-1:1) = iaux:-int_factor:iaux - timePreWindow * int_factor + int_factor;
            waveIntOut(i, timePreWindow + 1:spikeWaveWindow) = iaux + int_factor:int_factor:iaux + timePostWindow * int_factor;

        end
    case 'neg'
        for i = 1:spikeNum
            intspikes(:) = spline(spikeWindowVec, spikes(i,:), intervals);
            [~, iaux] = min((intspikes(timePreWindow * int_factor:timePreWindow * int_factor + 8))); 
            iaux = iaux + timePreWindow * int_factor - 1;
            spikes1(i, timePreWindow:-1:1) = intspikes(iaux:-int_factor:iaux - timePreWindow * int_factor + int_factor);
            spikes1(i, timePreWindow + 1:spikeWaveWindow) = intspikes(iaux + int_factor:int_factor:iaux + timePostWindow * int_factor);
        end
    case 'both'
        for i = 1:spikeNum
            intspikes(:) = spline(spikeWindowVec, spikes(i,:), intervals);
            [~, iaux] = max(abs(intspikes(timePreWindow * int_factor:timePreWindow * int_factor + 8))); 
            iaux = iaux + timePreWindow * int_factor - 1;
            spikes1(i, timePreWindow:-1:1) = intspikes(iaux:-int_factor:iaux - timePreWindow * int_factor + int_factor);
            spikes1(i, timePreWindow + 1:spikeWaveWindow) = intspikes(iaux + int_factor:int_factor:iaux + timePostWindow * int_factor);
        end
end
