function Cued_Reward_Task_Parameters_Operant()

global S %BpodSystem
    listPhases= {'RewardA', 'RewardARewardBOmissionC'} ;
    phase_idx = listdlg('ListString',listPhases,...
        'PromptString','Select the Phase of the experiment');
    phase{1} = listPhases{phase_idx};
    phaseName = phase{1}; 
    S.Names.Phase = listPhases;
    S.Names.Sound = {'Sweep','Tones'};
    S.Names.StateToZero = {'PostReward','SoundDelivery'};
    S.Names.OutcomePlot = {'Collect','GoNoGo'};
    
    neural_recording_types = {'Photometry','Tetrodes','No_recording'} ;
    rec_idx = listdlg('ListString', neural_recording_types,...
        'PromptString','Select the method for neural recording');
    recording_type = neural_recording_types{rec_idx};
  
    TrialSettings = load_previous_settings(phaseName);
    %copy_settings_fields(TrialSettings);
        
    switch phaseName
        case 'RewardA'
            S.Names.Symbols={'Reward','Omission', 'Punish','Reward Opto','Cue Opto'};
        case 'RewardARewardBOmissionC'
            S.Names.Symbols={'Reward','Omission', 'Punish','Reward Opto','Cue Opto'};
    end
 
    
%% General Parameters    
   
    S.GUIMeta.Phase.Style='popupmenu';
    S.GUIMeta.Phase.String=phaseName;
 
    S.GUIMeta.eZTrials.Style='checkbox';
    S.GUIMeta.eZTrials.String='Auto';

    S.GUIMeta.Wheel.Style='checkbox';
    S.GUIMeta.Wheel.String='Auto';

    S.GUIMeta.Photometry.Style='checkbox';
    S.GUIMeta.Photometry.String='Auto';

    S.GUIMeta.Modulation.Style='checkbox';
    S.GUIMeta.Modulation.String='Auto';

    S.GUIMeta.DbleFibers.Style='checkbox';
    S.GUIMeta.DbleFibers.String='Auto';
    S.GUIPanels.General={'Phase','MaxTrials','eZTrials','Wheel','Photometry','Modulation','DbleFibers'};    
    S.GUI = TrialSettings.GUI;
    %%%%f sinish gui-- test on Setup
    switch S.GUIMeta.Phase.String
      
        case 'RewardA'
            S.GUIPanels.TaskSpecifics={'ProbCueARwd',...
                'ProbCueAOmission','ProbCueBOmission',...
                'ProbUncuedRwd',...
                'ProbUncuedOmission','ProbCueAOpto',...
                'ProbCueBOpto','ProbCueARwdOpto',...
                'ProbCueBOmissionOpto'};
       
        case 'RewardARewardBOmissionC'
            S.GUIPanels.TaskSpecifics = {'ProbCueARwd',...
                'ProbCueAOmission','ProbCueBRwd',...
                'ProbCueBOmission','ProbCueCOmission',...
                'ProbUncuedRwd','ProbCueAOpto',...
                'ProbCueBOpto','ProbCueARwdOpto',...
                'ProbCueBOmissionOpto', 'ProbUncuedRwdOpto'};
   
    end

        S.GUIPanels.Timing={'PreCue','Delay','DelayIncrement','PostOutcome','TimeNoLick','ITI'};

    S.GUITabs.General={'Timing','TaskSpecifics','General'};

%% Task Parameters

    S.GUIMeta.SoundType.Style='popupmenu';
    S.GUIMeta.SoundType.String=S.Names.Sound;
    S.GUIPanels.Cue={'SoundType','SoundDuration','LowFreq','HighFreq','CueC',...
                     'SoundRamp','NbOfFreq','FreqWidth','SoundSamplingRate'};
    
    S.GUIMeta.RewardValve.Style='popupmenu';
    S.GUIMeta.RewardValve.String={0,1,2,3,4,5,6,7,8};

	S.GUIMeta.PunishValve.Style='popupmenu';
    S.GUIMeta.PunishValve.String={0,1,2,3,4,5,6,7,8};
	S.GUIMeta.OmissionValve.Style='popupmenu';
    S.GUIMeta.OmissionValve.String={0,1,2,3,4,5,6,7,8};
    S.GUIPanels.Outcome={'RewardValve','SmallReward','InterReward','LargeReward','PunishValve','PunishTime','OmissionValve'};
 
    S.GUITabs.Cue={'Cue'};
    S.GUITabs.Outcome={'Outcome'};

%% Nidaq and Photometry
 if strcmp(recording_type, 'Photometry')== 1
    S.GUIPanels.Photometry={'NidaqDuration','NidaqSamplingRate',...
                            'LED1_Wavelength','LED1_Amp','LED1_Freq',...
                            'LED2_Wavelength','LED2_Amp','LED2_Freq',...
                            'LED1b_Wavelength','LED1b_Amp','LED1b_Freq'};
                        
    S.GUITabs.Photometry={'Photometry'};
 end
%% Optogenetics

    S.GUIPanels.Optogenetics={ 'OptoStimCueDelay','PulseInterval',...
        'Phase1Voltage','Phase2Voltage','Phase1Duration',...
        'Phase2Duration','InterPhaseInterval','PulseTrainDelay',...
        'PulseTrainDuration','LinkedToTriggerCH1',...
        'LinkedToTriggerCH2','Ramping'};
    S.GUITabs.Optogenetics={'Optogenetics'};

    %%%% Add more options 
    %% Online Plots   
	S.GUIMeta.StateToZero.Style = 'popupmenu';
    S.GUIMeta.StateToZero.String=S.Names.StateToZero;

    S.GUIPanels.PlotParameters = {'StateToZero','TimeMin','TimeMax'};

    S.GUIMeta.Outcome.Style = 'popupmenu';
    S.GUIMeta.Outcome.String = S.Names.OutcomePlot;

    S.GUIMeta.Circle.Style = 'popupmenu';
    S.GUIMeta.Circle.String = S.Names.Symbols;

    S.GUIMeta.Square.Style = 'popupmenu';
    S.GUIMeta.Square.String = S.Names.Symbols;

    S.GUIMeta.Diamond.Style = 'popupmenu';
    S.GUIMeta.Diamond.String = S.Names.Symbols;
    
    S.GUIPanels.PlotLicks={'Outcome','Circle','Square','Diamond'};

    S.GUIPanels.PlotNidaq={'DecimateFactor','NidaqMin',...
                           'NidaqMax','BaselineBegin','BaselineEnd'};
    
    S.GUITabs.OnlinePlot={'PlotNidaq','PlotLicks','PlotParameters'};
    
    
    % --- Check is all parameters have a place in the GUI ---
    conflictingParams = checkIfGUIComplete();
    
   

    
    %%%_-----------------------change symbols : probability dependent
    %%% make more subplots 
    
end
