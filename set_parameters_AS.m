function par = set_parameters_AS(sr)

% SPC PARAMETERS
               % maximum temperature for SPC
par.KNearNeighb=11;                  % number of nearest neighbors for SPC   
par.min_clus = 60;                   % minimum size of a cluster (default 60)   
par.max_clus = 13;                   % maximum number of clusters allowed (default 13)
par.randomseed = 0;                  % if 0, random seed is taken as the clock value (default 0)
par.fname_in = 'tmp_data';           % temporary filename used as input for SPC
par.fname = 'data';                  % filename for interaction with SPC

% DETECTION PARAMETERS
par.tmax= 'all';                     % maximum time to load (default)
%par.tmax= 180;                      % maximum time to load (in sec)
par.tmin= 0;                         % starting time for loading (in sec)
par.sr=sr;                           % sampling rate

par.w_pre = round((sr/1000)*0.75);  % number of pre-event data points stored 0.75 ms
par.w_post = round((sr/1000)*1.15) ;   % number of post-event data points stored 1.15 ms

ref = 1.5;                           % detector dead time (in ms)
par.ref = floor(ref * sr/1000);      % conversion to datapoints
par.stdmin = 3;                      % minimum threshold for detection
par.stdmax = 50;                     % maximum threshold for detection
par.detect_fmin = 300;               %high pass filter for detection
par.detect_fmax = 1000;              %low pass filter for detection
par.sort_fmin = 300;                 %high pass filter for sorting
par.sort_fmax = 3000;                %low pass filter for sorting
par.detection = 'pos';               % type of threshold
%par.detection = 'neg';
%par.detection = 'both';
par.segments_length = 5;             %length of segments in which the data is cutted (default 5min).

% INTERPOLATION PARAMETERS
par.int_factor = 2;                  % interpolation factor
par.interpolation = 'y';             % interpolation with cubic splines (default)
%par.interpolation = 'n';

% FEATURES PARAMETERS
par.inputs=10;                       % number of inputs to the clustering
par.scales=4;                        % number of scales for the wavelet decomposition
par.features = 'wav';                 % type of feature 
%par.features = 'pca'                
if strcmp(par.features,'pca'); par.inputs=3; end

% FORCE MEMBERSHIP PARAMETERS
par.template_sdnum = 3;             % max radius of cluster in std devs.
par.template_k = 10;                % # of nearest neighbors
par.template_k_min = 10;            % min # of nn for vote
%par.template_type = 'mahal';        % nn, center, ml, mahal
par.template_type = 'center';        % nn, center, ml, mahal
par.force_feature = 'spk';          % feature use for forcing (whole spike shape)

par.max_spikes = 1000;               % max. # of spikes to be plotted




    

