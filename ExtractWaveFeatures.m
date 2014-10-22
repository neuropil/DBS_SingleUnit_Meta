function [waveFeatures] = ExtractWaveFeatures(spikes, handles)
%Calculates the spike features

% OLD version called wave_feature_jat.m

scales = handles.params.scales;
feature = handles.params.features;
inputs = handles.params.inputs;
nspk = size(spikes,1);
lenspk = size(spikes,2);


% CALCULATES FEATURES
switch feature
    
    case 'wav'
        spkDecompAll = zeros(nspk,lenspk);
        if exist('wavedec','file')                      % Looks for Wavelets Toolbox
            for i = 1:nspk                              % Wavelet decomposition
                % Decompose each spike into four coefficient components
                [tempDecomp, ~] = wavedec(spikes(i,:),scales,'haar');
                spkDecompAll(i,1:lenspk) = tempDecomp(1:lenspk);
            end
        else
            for i = 1:nspk                              % Replaces Wavelets Toolbox, if not available
                [tempDecomp,~] = fix_wavedec(spikes(i,:),scales); % MAKE MY OWN FOR STUDEND COMPUTER
                spkDecompAll(i,1:lenspk) = tempDecomp(1:lenspk);
            end
        end
        
        sd = zeros(1,lenspk);
        for i = 1:lenspk                                 % KS test for coefficient selection: choose which coefficient to keep 
            % Select and test each coefficient column of spike 
            thr_dist = std(spkDecompAll(:,i)) * 3;
            thr_dist_min = mean(spkDecompAll(:,i)) - thr_dist;
            thr_dist_max = mean(spkDecompAll(:,i)) + thr_dist;
            coeff2useInd = spkDecompAll(spkDecompAll(:,i) > thr_dist_min & spkDecompAll(:,i) < thr_dist_max,i);
            
            if length(coeff2useInd) > 10;
                [ksstat] = KStestJAT(coeff2useInd);
                sd(i)= ksstat;
            else
                sd(i) = 0;
            end
        end
        
        [~, ind] = sort(sd);
        % Sort and extract last component index
        coeff(1:inputs) = ind(lenspk:-1:lenspk - inputs + 1);
        
    case 'pca'
        [~, S, ~] = princomp(spikes);
        spkDecompAll = S;
        inputs = 3; 
        coeff(1:3) = [1 2 3];
end

%CREATES INPUT MATRIX FOR SPC
waveFeatures = zeros(nspk, inputs);
for i = 1:nspk
    waveFeatures(i,:) = spkDecompAll(i, coeff);
end

