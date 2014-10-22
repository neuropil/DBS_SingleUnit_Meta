function MERtestSuiteStart()

displayQuest = sprintf('Choose Function Family: \n 1) PCA funs \n 2) PlotExtra \n 3) Debugging \n 4) Preprocessing \n 5) SpiketimeExtract \n 6) RunSpikeCluster \n 7) MER GUI \n 8) PostAnalysis \n Choice>>>');

chooseFuns = input(displayQuest,'s');

switch chooseFuns
    
    case '1'
        edit demoPCA_2D.m
        edit demoPCA_Life.m
        edit Demo_Sum.m
        edit Demo_Sum2.m
    case '2'
        edit multiColorLine.m
        edit multiColorLineSCRIPT.m
        edit plotISI_scratchPAD.m
        edit plot_transparent_waveOverlay.m
    case '3'
        edit spikeDebug_case.m
        edit testRunSpikeCode_10_02_2014.m
        edit spikeDebugNOwv.m
    case '4'
        edit CompAllNeuroPhys.m
        edit ConvertDepthNames.m
        edit LFPtest.m
        edit Relabel_AO_Depth_v01.m
        edit CheckDeDBSLength.m
        edit SubjecCheckNoise.m
        edit GetDirFileList.m
        edit CheckThreshCross.m % Checks whether threshold works across entire day
        edit Run_CreateThresh.m
    case '5'
        edit amp_detect_jat.m % old old JAT spike extractor
        edit amp_detect_TEST_truncate.m % Test verison of old JAT spike extractor
        edit spikeThreshold_filter_beta.m % Test version of JAT filter
        edit spikeThreshold_filter.m % JAT's old spike time extractor
        edit SpikeTimeExtract.m % JAT's new spike time extractor
        edit SpikeThresholdCreate.m % Obtains threshold
        edit InterpolateSpikes.m % Runs inside of SpikeTimeExtract.m
        edit set_parameters_CSC_jat.m % original/old parameter file
        edit set_parameters_CSC_TEST.m % beta parameter file
        edit set_parameters_AO.m % NEW parameter file
    case '6'
        edit PlotMultiWindowSpikeInfo.m % This file will analyze an entire day
        edit spikeDebugNOwv.m % Old meta spike cluster extraction
        edit SpikeClusterMetaExtract.m % NEW meta spike cluster extraction
        edit wave_features_jat.m % Old wave feature extraction
        edit test_ks_jat.m % Old ks test for wave_features_jat
        edit ExtractWaveFeatures.m % NEW wave feature extraction
        edit KStestJAT.m % New ks test for ExtractWaveFeatures.m
        edit cluster_spikeData.m % Old cluster m file
        edit ClusterSpikes.m % New cluster m file
        edit run_cluster_jat.m % Old cluster executable
        edit RunWavClusAlgo.m % NEW cluster executable
        edit GetClusIndex_WCalg.m % Extracts cluster info from cluster output
        edit find_temp_jat.m % OLD helper function inside GetClusIndex
        edit FindWCTemper.m % NEW algorithm temperature selection    
    case '7'
        edit merguitest_v0.m % Current beta GUI
    case '8'
        edit NeuroDBS_DB_beta_v01.m % UNedited post waveform processing function
        edit SpikeClustProfiler.m % Allows selection of a single trace FOLLOWING use of PlotMultiWindowSpikeInfo.m
        
        
        






























end