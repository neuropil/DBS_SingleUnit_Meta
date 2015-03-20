%%% Start script by loading in a data file with 'firstBlock' and
%%% 'secondBlock'

% Trial start time according to the ephys clock.  The successive time points
% will happen at times dictated by the TTL sampling frequency.  Assuming
% there was no error in both sampling frequencies, the signal would simply
% happened every 1/12kHz seconds.  I look into the variance of the TTL
% pulse deliveries and it's roughly 2.3ms
trialStartTimes = [firstBlock.TTL_StartTime + (firstBlock.TTL_UpVec./firstBlock.TTL_fs_Hz),...
                   secondBlock.TTL_StartTime + (secondBlock.TTL_UpVec./secondBlock.TTL_fs_Hz)];
  
% Combining the ephys data
stitchedEphys = [firstBlock.ephysData , secondBlock.ephysData];       
% Creating the ephys time sequence (according to the ephys clock)
ephysTimePoints = 1:1:length(stitchedEphys);
ephysTimes = firstBlock.ephys_StartTime + ephysTimePoints./firstBlock.ephys_fs_Hz;

% Parameters to convert ephys time to respective element number
t = ephysTimes(1); tau = 1/firstBlock.ephys_fs_Hz;

% Visual check
figure(1); hold on;
plot(ephysTimes)
p1 = plot((firstBlock.TTL_StartTime-t)/tau, firstBlock.TTL_StartTime, 'r.', 'markersize', 18);
plot((secondBlock.TTL_StartTime-t)/tau, secondBlock.TTL_StartTime, 'r.', 'markersize', 18);
p2 = plot((secondBlock.TTL_EndTime-t)/tau, secondBlock.TTL_EndTime, 'rx', 'markersize', 12);
plot((firstBlock.TTL_EndTime-t)/tau, firstBlock.TTL_EndTime, 'rx', 'markersize', 12);
xlabel('Element #', 'fontsize', 14);
ylabel('Time (s)', 'fontsize', 14);
hold off;

legend([p1 p2], {'TTL block start', 'TTL block stop'}, 'location', 'NW');

% plot ephys data
figure(2);
e1 = plot(ephysTimes, stitchedEphys);
xlabel('Time (s)', 'fontsize', 14);
ylabel('Amplitude', 'fontsize', 14);

% plot of trial start times
minV = min(stitchedEphys); linePlotHeights = [1.1*minV; 1.2*minV];
e2 = line([trialStartTimes; trialStartTimes],...
    repmat(linePlotHeights, [1 numel(trialStartTimes)]), 'color', [1 0 0]);

legend([e1 e2(1)], {'Ephys', 'TTL'}, 'location', 'NE');