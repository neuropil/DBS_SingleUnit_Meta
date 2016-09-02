tempWaves = allwaves;


Y = tempWaves(100,:);


% Normalize to max ampulitude of Mean of Waves
% For Rp = Add to each point either 0.25 or 0.5
% For Rn = Subtract from each point either 0.25 or 0.5
% 0.25 creates a more stringent theshold.


meanWave = mean(tempWaves);

figure;
plot(tempWaves','k')
hold on
plot(meanWave','r')

template = meanWave/max(meanWave);
Rp = template + 0.2;
Rn = template - 0.2;


for mi = 1:length(template);
   
    tRz = template(mi);
    
    if abs(tRz) <= 0.25
        Rp(mi) = 0.25;
        Rn(mi) = -0.25;
    elseif tRz > 0.25
        Rp(mi) = max([tRz/2, 0.25]);
        Rn(mi) = Rp(mi) - 0.25;
    else
        Rn(mi) = min([tRz/2 , -0.25]);
        Rp(mi) = Rn(mi) + 0.25;
    end

end


figure;
plot(template','k')
hold on;
plot(Rp','g');
plot(Rn','g');


%%


YN = Y/max(meanWave);



Sy = nan(1,size(template,2));
Sx = nan(1,size(YN,2));
for ti = 1:size(template,2)
    
    
    x = template(ti);
    if x < Rp(ti) && x > Rn(ti)
        Sx(ti) = 0;
    elseif x > Rp(ti)
        Sx(ti) = 1;
    elseif x < Rn(ti)
        Sx(ti) = -1;
    end
    
    y = YN(ti);
    if y < Rp(ti) && y > Rn(ti)
        Sy(ti) = 0;
    elseif y > Rp(ti)
        Sy(ti) = 1;
    elseif y < Rn(ti)
        Sy(ti) = -1;
    end

end

SCC = sum(Sy.*Sx)/length(Sy);

%% ASCI

% Adaptive Signed Correlation Index

% signed correlation between Sy and Sx
  % divided by square root of SC(Sx,Sx) * SC(Sy,Sy)
SxN = Sx >= 0;
Sx(SxN) = 1;

SyN = Sy >= 0;
Sy(SyN) = 1;

SCC = sum(Sy)/length(Sy);

%%

corVal = zeros(size(tempWaves,1),1);
for wi = 1:size(tempWaves,1)
    
    tWave = tempWaves(wi,:);
    tWaveN = tWave/max(meanWave);
    
    S = nan(1,size(tWaveN,2));

    for ti = 1:size(tWaveN,2)

        x = tWaveN(ti);
        if x < Rp(ti) && x > Rn(ti)
            S(ti) = 0;
        elseif x > Rp(ti)
            S(ti) = 1;
        elseif x < Rn(ti)
            S(ti) = -1;
        end
 
    end
    
    
%     SN = S >= 0;
%     S(SN) = 1;
%     
    
    SCC = sum(S)/length(S);
    
    corVal(wi) = SCC;
    
end


corVal = zeros(size(tempWaves,1),1);
for wi = 1:size(tempWaves,1)
    
    tWave = tempWaves(wi,:);
    tWaveN = tWave/max(meanWave);
    
    S = nan(1,size(tWaveN,2));

    for ti = 1:size(tWaveN,2)

        x = tWaveN(ti);
        if x < Rp(ti) && x > Rn(ti)
            S(ti) = 0;
        elseif x > Rp(ti)
            S(ti) = 1;
        elseif x <= Rn(ti)
            S(ti) = -1;
        end
 
    end
    
    
    SN = S >= 0;
    S(SN) = 1;
%     
    
    SCC = sum(S)/length(S);
    
    corVal(wi) = SCC;
    
end





%%

keepSp = corVal > 0.5;

plot(mean(tempWaves(keepSp,:))','k');
hold on
plot(mean(tempWaves(~keepSp,:))','r');







