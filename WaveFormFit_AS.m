function [WaveFitParams] = WaveFormFit_AS(Clust_Waves,timeLen)

time = linspace(0,1,timeLen);
time = round(time * 100)/100;
sampleindex = (1:1:timeLen)';

WaveFitParams = struct;
% WaveSum_DS = struct;


tempWaves = Clust_Waves;

% wavemeanTemp = mean(tempWaves);
% wavestdTemp = std(tempWaves);
% wavestdPTemp = wavemeanTemp + wavestdTemp;
% wavestdMTemp = wavemeanTemp - wavestdTemp;

% waveAll = horzcat(transpose(wavemeanTemp),...
%     transpose(wavestdTemp),...
%     transpose(wavestdPTemp),...
%     transpose(wavestdMTemp));

% WaveSum_DS = mat2dataset(waveAll, 'VarNames', {'Mean','StD','PStD','MStD'});
noiseVec = false(size(tempWaves,1),1);
for ti = 1:size(tempWaves,1)
    
    wavemeanTemp = tempWaves(ti,:);
    
    uselead = wavemeanTemp;
    
    basesub = mean(uselead(timeLen - 5:timeLen));
    
    uselead_base = detrend(uselead);
    
    [~, maxpoint] = max(uselead_base);
    
    if maxpoint > round(0.95*timeLen)
        noiseVec(ti) = 1;
        
        
    end
    
%     [~, minpoint] = min(uselead_base(round(timeLen*0.5):timeLen));
%     
%     
%     minpoint = minpoint + 12;
%     
%     if maxpoint == 1
%         maxpoint = round(timeLen*0.4);
%     end
%     
%     before_max = find(sampleindex < maxpoint);
%     after_max = find(sampleindex >= maxpoint);
%     
%     if after_max == timeLen
%         after_max = round(timeLen*0.3) + 2:timeLen;
%     end
    
%     first_pos_def = find(uselead_base(before_max) < 0,1,'last');
%     second_pos_def = find(uselead_base(after_max) < 0,1,'first');
%     second_pos_def = second_pos_def - 1;
%     
%     if isempty(first_pos_def) == 1;
%         first_pos_def = 1;
%     end
%     
%     if second_pos_def == 0;
%         second_pos_def = length(after_max) - 2;
%     end
    
%     pospeakstart = uselead_base(before_max(first_pos_def));
%     pospeakend = uselead_base(after_max(second_pos_def));
%     
%     posps_loc = find(uselead_base == pospeakstart);
%     pospe_loc = find(uselead_base == pospeakend);
%     
%     pospeak_width = time(pospe_loc) - time(posps_loc);
    
    % min calculation
    
%     before_min = find(sampleindex < minpoint);
%     first_neg_def = find(uselead_base(before_min) > 0,1,'last');
    
%     if isempty(first_neg_def) == 1;
%         first_neg_def = max(before_min);
%     end
    
%     negpeakstart = uselead_base(before_min(first_neg_def));
%     negps_loc = find(uselead_base == negpeakstart);
%     
%     halfwidth = ceil((minpoint + negps_loc)/2);
%     addhalf = minpoint - halfwidth;
%     halfwidthpoint2 = minpoint + addhalf;
%     
%     if halfwidthpoint2 >= 32
%         halfwidthpoint2 = 32;
%     end
%     
%     negpeak_half_width = time(halfwidthpoint2) - time(halfwidth);
    
    baselinevolt = abs(basesub);
    spkamp = max(uselead_base) - baselinevolt;
    
%     WaveFitParams.jtkoyama_neg_width(ti) = negpeak_half_width;
%     WaveFitParams.jtkoyama_pos_width(ti) = pospeak_width;
    WaveFitParams.amp(ti) = spkamp;
    WaveFitParams.baseline(ti) = basesub;
    
    % Gidon Waveform Analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    last_ind = find(uselead(maxpoint:end) < basesub, 1, 'first') + 15;
    
    if isempty(last_ind) == 1
        last_ind = 24;
    end
    
    wpos = uselead(1:last_ind);
    
    xpos = [0.1:0.1:(0.1 * last_ind)];
    
    gain_init = max(wpos);
    center_init = xpos(find(wpos == max(wpos)));
    stdev_init = 0.3;
    dc_init = wpos(1);
    
    params_init = [gain_init, center_init, stdev_init, dc_init];
    
    [params_fit.pos, ~, ~, pmse] = RunGaussianFit(xpos', wpos', params_init);
    
    
    y_fit.pos = Gaussian(xpos, params_fit.pos(1), params_fit.pos(2), params_fit.pos(3), params_fit.pos(4));
    
    [pactual_re] = Rescale(wpos', [0 1]);
    [pfit_re] = Rescale(y_fit.pos', [0 1]);
    
    p_error = pfit_re - pactual_re;
    
    pos_rescale_mse = mean(p_error.^2);
    
    %% fit the negative component of the waveform
    
    wneg = uselead((last_ind - 1):end);
    xneg = (0.1 * (last_ind - 1)):0.1:timeLen*0.1;
    %x.neg = [0.1:0.1:(length(w.neg) * 0.1)];
    
    gain_init = min(wneg);
    center_init = xneg(find(wneg == min(wneg)));
    stdev_init = 0.3;
    dc_init = wneg(end);
    
    params_init = [gain_init, center_init, stdev_init, dc_init];
    [params_fit.neg, ~, ~, nmse] = RunGaussianFit(xneg', wneg', params_init);
    
    y_fit.neg = Gaussian(xneg, params_fit.neg(1), params_fit.neg(2), params_fit.neg(3), params_fit.neg(4));
    
    [nactual_re] = Rescale(wneg', [0 1]);
    [nfit_re] = Rescale(y_fit.neg', [0 1]);
    
    n_error = nfit_re - nactual_re;
    
    neg_rescale_mse = mean(n_error.^2);
    
    WaveFitParams.gauss_fit_neg_width(ti,1) = (round(params_fit.neg(3) * 100) / 100);
    WaveFitParams.gauss_fit_pos_width(ti,1) = (round(params_fit.pos(3) * 100) / 100);
    WaveFitParams.neg_mse(ti,1) = nmse;
    WaveFitParams.ngain(ti,1) = params_fit.neg(1);
    WaveFitParams.ncenter(ti,1) = params_fit.neg(2);
    WaveFitParams.nstandev(ti,1) = params_fit.neg(3);
    WaveFitParams.ndc(ti,1) = params_fit.neg(4);
    WaveFitParams.nrmse(ti,1) = neg_rescale_mse;
    WaveFitParams.nbase_cen(ti,1) = params_fit.neg(4) - params_fit.neg(2);
    WaveFitParams.pos_mse(ti,1) = pmse;
    WaveFitParams.pgain(ti,1) = params_fit.pos(1);
    WaveFitParams.pcenter(ti,1) = params_fit.pos(2);
    WaveFitParams.pstandev(ti,1) = params_fit.pos(3);
    WaveFitParams.pdc(ti,1) = params_fit.pos(4);
    WaveFitParams.prmse(ti,1) = pos_rescale_mse;
    
    fprintf('Wave %d out of %d is DONE!!! \n',ti ,size(tempWaves,1))
    
end

WaveFitParams.noise = noiseVec;

end





