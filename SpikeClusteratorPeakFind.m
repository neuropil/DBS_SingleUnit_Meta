






sampData = CElectrode1;
sampData(sampData < 0) = 0;
spkData = double(CElectrode1);

thresh = round(std(double(sampData))*4+mean(double(sampData)));
minDist = round(mer.sampFreqHz/1000)*1.25;

[~,locs_Rwave] = findpeaks(double(sampData),'MinPeakHeight',thresh,...
                                    'MinPeakDistance',minDist);                     
close all                  
plot(sampData);
hold on
plot(locs_Rwave,sampData(locs_Rwave),'rv','MarkerFaceColor','r');

waveForms = zeros(18,length(locs_Rwave));
for ai = 1:length(locs_Rwave)
    
    locP = locs_Rwave(ai);
    waveForms(:,ai) = spkData(locP - 6:locP + 11);

end

plot(waveForms,'k')

%%

features = struct;

% Reduce dimensions and extract Waveforms of interest
tempWaves = transpose(waveForms);

% Peak
features.Peak = max(tempWaves,[],2);
% Valley
features.Valley = min(tempWaves,[],2);
% Energy
features.Energy = trapz(abs(tempWaves),2);
% Combine for WavePCA analysis
featsForPCA = horzcat(features.Peak,...
    features.Valley,...
    features.Energy);
% WavePC1
[~,pcScores,~] =...
    princomp(featsForPCA);

features.WavePC1 = pcScores(:,1);

features.FSDE_Values =...
    FSDE_Method(tempWaves);

%%


%%


% normalize features

% X = [features.Peak , features.Valley ,...
%      features.Energy , features.WavePC1 ,...
%      features.FSDE_Values.FDmin , features.FSDE_Values.SDmax ,...
%      features.FSDE_Values.SDmin , features.WaveFitParams.gauss_fit_neg_width ,...
%      features.WaveFitParams.gauss_fit_pos_width];


X = [features.Peak , features.Valley ,...
    features.Energy , features.WavePC1 ,...
    features.FSDE_Values.FDmin , features.FSDE_Values.SDmax ,...
    features.FSDE_Values.SDmin];


%%


X1 = X(:,[1:3 5 7]);
eva = evalclusters(X1,'kmeans','DaviesBouldin','KList',1:6);
% eva = evalclusters(X1,'kmeans','CalinskiHarabasz','KList',1:7);

numClusts =  eva.OptimalK;

%%


% c = clusterdata(X1,'mahalanobis','linkage','ward','maxclust',3);
c = clusterdata(X1,'distance','chebychev','linkage','ward','maxclust',numClusts);
% Plot the data with each cluster shown in a different color.
figure
scatter3(X1(:,1),X1(:,2),X1(:,4),10,c)

%%

filtWave = tempWaves;
cfilt = c;
%%
figure;
subplot(1,2,1);
plot(filtWave(cfilt==1,:)','r')
ylim([-6000 6000]);
subplot(1,2,2);
plot(filtWave(cfilt==2,:)','g')
ylim([-10000 10000]);


figure;
plot(mean(filtWave(cfilt==1,:))','r-','LineWidth',2)
hold on
plot(mean(filtWave(cfilt==2,:))','g-','LineWidth',2)
plot(mean(filtWave(cfilt==3,:))','b-','LineWidth',2)
plot(mean(filtWave(cfilt==4,:))','k-','LineWidth',2)
ylim([-6000 6000]);
xlim([0 size(filtWave,2)])




























