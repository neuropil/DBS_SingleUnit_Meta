function [] = AO_IO_Ephys_processing(step , year , driveLetter, study , date)


if nargin == 3
    date2use = nan;
    study2use = 'ET-DK';
elseif nargin == 4
    study2use = study;
    date2use = nan;
else
    date2use = date;
    study2use = study;
end


switch step
    
    % case 1 % loop through S1 year and add folders to S2 that are missing
    case 1 % RUN WHEN ONLY .MPX files are available
        preSetAOC_folds(year, driveLetter)
    case 2 % RUN AFTER CONVERTING MPX to MAT in S2
        place2SetsTxts_AOS2(year , driveLetter)
    case 3 % RUN AFTER STEP 2
        initializeS2_S3(year , driveLetter)
    case 4 % NEED TO FIX SETS
        postAOCleanUp(study2use , year , date2use , driveLetter)
    case 5 % NEED TO FIX SETS
        resetS3_S4_crash(year , date2use , driveLetter)
end





end