function Two_AFC_Menegas_GUIParameters()

    global S %BpodSystem
    
    %% General tab:
    S.GUITabs.General = {'General'};
    % Fields
    S.GUIPanels.General = {'SoundAmplitude','LEDIntensity','RewardAmount',...
        'ResponseTime','CenterPortDuration','VariableCueDelay','MaxCenterPortDuration','PunishDelay','TrainingLevel',...
        'BiasCorrection','Punish'};
    % Define
    S.GUI.SoundAmplitude = 0.005;
    S.GUI.LEDIntensity = 100;
    S.GUI.RewardAmount = 5; % ul
    S.GUI.ResponseTime = 30; % seconds to respond
    S.GUI.CenterPortDuration = 0.03; % How long the mouse must poke in the center to activate the goal port
    
    S.GUI.VariableCueDelay = 0; %Default is off %% This is for Mat's implementation of increamental centre port hold
    S.GUIMeta.VariableCueDelay.Style = 'checkbox';
    S.GUI.MaxCenterPortDuration = 1;
    
    S.GUI.PunishDelay = 0; % Seconds of punishment
    
    S.GUI.TrainingLevel = 1; % Default Training Level
    S.GUIMeta.TrainingLevel.Style = 'popupmenu'; % the GUIMeta field is used by the ParameterGUI plugin to customize UI objects.
    S.GUIMeta.TrainingLevel.String = {'Habituation', 'Visual', 'Auditory', 'Aud_Psycho', 'Inter_Freqs_Aud_Psycho'};
    
    S.GUI.BiasCorrection = 1; % Default is yes
    S.GUIMeta.BiasCorrection.Style = 'checkbox';
    
    S.GUI.Punish = 1; % Default
    S.GUIMeta.Punish.Style = 'popupmenu'; % the GUIMeta field is used by the ParameterGUI plugin to customize UI objects.
    S.GUIMeta.Punish.String = {'No', 'Only choice', 'Also early center out'};
    
    
    %% Specifics tab:
    S.GUITabs.Specifics = {'Specifics'};
    % Fields
    S.GUIPanels.Specifics = {'Contingency', 'ContingencyBlockLength',...
        'Muscimol', 'RewardProb', 'LargeRewardProb', 'RewardChange','RewardChangeBlockLength', ...
        'IncludeSoundInVisual'};
    
    % Contingency
    S.GUI.Contingency = 1; % Default is High-Left / Low-Right
    S.GUIMeta.Contingency.Style = 'popupmenu'; % the GUIMeta field is used by the ParameterGUI plugin to customize UI objects.
    S.GUIMeta.Contingency.String = {'High-Left / Low-Right', 'Low-Left / High-Right', 'Block Switch'};
    S.GUI.ContingencyBlockLength = 150; % Length of the block if the contingency is set to switch
    % Have a field for text input to label some trials as muscimol    
    S.GUI.Muscimol = 1; % Default is No
    S.GUIMeta.Muscimol.Style = 'popupmenu'; % the GUIMeta field is used by the ParameterGUI plugin to customize UI objects.
    S.GUIMeta.Muscimol.String = {'No', 'AUD1-bilat', 'StrTail-bilat', 'MGB-bilat', 'StrTail-bilat-Control',...
        'AUD1-bilat-Control', 'StrTail-left', 'StrTail-right', 'DMS-bilat', 'DMS-bilat-Control'};
    %Reward
    S.GUI.RewardProb = 1;
    S.GUI.LargeRewardProb = 0;
    S.GUI.RewardChange = 1; % Default is No
    S.GUIMeta.RewardChange.Style = 'popupmenu'; % the GUIMeta field is used by the ParameterGUI plugin to customize UI objects.
    S.GUIMeta.RewardChange.String = {'No', '3x Block Switch', 'Range of values'};
    S.GUI.RewardChangeBlockLength = 150; % Length of the block if the RewardAmountChange is set to switch
    
    %Include sound in visual trials - this is for PH3 controls
    S.GUI.IncludeSoundInVisual = 0; % Default is no
    S.GUIMeta.IncludeSoundInVisual.Style = 'checkbox';
    

    %% OptoStimulation tab:
    S.GUITabs.OptoStimulation = {'OptoStimulation'};
    % Fields
    S.GUIPanels.OptoStimulation = {'OptoStim', 'OptoState', 'FiberLocation', ...
        'JustOnePort', 'JOPSide',...
        'OptoChance', 'FreeOptoIniTrials'};
    % Define
    S.GUI.OptoStim = 1; % Default is no stimulation
    S.GUIMeta.OptoStim.Style = 'popupmenu'; % the GUIMeta field is used by the ParameterGUI plugin to customize UI objects.
    S.GUIMeta.OptoStim.String = {'NoStimulation', 'Left', 'Right', 'Both'};
    
    S.GUI.OptoState = 1; % Default is center port
    S.GUIMeta.OptoState.Style = 'popupmenu';
    S.GUIMeta.OptoState.String = {'CenterPort', 'SidePort'};
    
    S.GUI.FiberLocation = 1; % Default is tail of str
    S.GUIMeta.FiberLocation.Style = 'popupmenu';
    S.GUIMeta.FiberLocation.String = {'StrTail', 'NAc'};
    
    S.GUI.JustOnePort = 0; % Default is this does not apply
    S.GUIMeta.JustOnePort.Style = 'checkbox';
    S.GUI.JOPSide = 1; % Default is left
    S.GUIMeta.JOPSide.Style = 'popupmenu';
    S.GUIMeta.JOPSide.String = {'Left', 'Right'};
    
    S.GUI.OptoChance = 0.15; % % of trials which will have stimulation
    
    S.GUI.FreeOptoIniTrials = 0; % Initial trials without opto

    
    %% PulsePal tab:
    S.GUITabs.PulsePal = {'PulsePal'};
    % Fields
    S.GUIPanels.PulsePal = {'PulseDuration',...
        'PulseInterval', 'TrainDuration', 'TimeBeforeOnset', 'TimeBeforeOnsetDuration',...
        'AddTruncExp', 'Exp_offset', 'Exp_rate', 'Exp_trunc'};
    % Define    
    S.GUI.PulseDuration = 0.005; % Set output channel to produce 5ms pulses
    S.GUI.PulseInterval = 0.045; % Set pulse interval to produce 20Hz pulses
    S.GUI.TrainDuration = 0.5; % Set pulse train to last 0.5 seconds
    
    %Include extra time before sound onset
    S.GUI.TimeBeforeOnset = 0; % Default is no
    S.GUIMeta.TimeBeforeOnset.Style = 'checkbox';
    S.GUI.TimeBeforeOnsetDuration = 0.05;
    S.GUI.AddTruncExp = 0; % Default is no
    S.GUIMeta.AddTruncExp.Style = 'checkbox';
    S.GUI.Exp_offset = 0.05;
    S.GUI.Exp_rate = 0.1;
    S.GUI.Exp_trunc = 0.2;
    
    
    %% Sounds tab:
    S.GUITabs.Sounds = {'Sounds'};
    % Fields
    S.GUIPanels.Sounds = {'RandomizeAmplitude', 'AmplitudeLowerBound', 'AmplitudeUpperBound', 'NumberOfAmplitudes'};
    
    S.GUI.RandomizeAmplitude = 0; % Default is no
    S.GUIMeta.RandomizeAmplitude.Style = 'checkbox';
    S.GUI.AmplitudeLowerBound = 0.001;
    S.GUI.AmplitudeUpperBound = 0.01;
    S.GUI.NumberOfAmplitudes = 7;
    
    %% Inference tab
    S.GUITabs.Inference = {'Inference'};
    % Fields
    S.GUIPanels.Inference = {'Inference', 'WNOnset', 'WNSide',...
        'ClickOnset', 'ClickSide', 'SilenceOnset', 'SilenceSide'};
    % Inference
    S.GUI.Inference = 1; % Default is No
    S.GUIMeta.Inference.Style = 'popupmenu';
    S.GUIMeta.Inference.String = {'No', 'Simple_WN', 'Simple_Click', 'Dual', 'Silence', 'Menegas'}; % Dual can be sequential or simultaneous
    % WN 
    S.GUI.WNOnset = 200; % Onset (trial) of WN
    S.GUI.WNSide = 1; % Default is Left
    S.GUIMeta.WNSide.Style = 'popupmenu';
    S.GUIMeta.WNSide.String = {'Left', 'Right'};
    % Clicks '
    S.GUI.ClickOnset = 50; % Onset (trial) of Click
    S.GUI.ClickSide = 2; % Default is Right
    S.GUIMeta.ClickSide.Style = 'popupmenu';
    S.GUIMeta.ClickSide.String = {'Left', 'Right'};
    
    % Silence
    S.GUI.SilenceOnset = 50; % Onset (trial) of Silence
    S.GUI.SilenceSide = 2; % Default is Right
    S.GUIMeta.SilenceSide.Style = 'popupmenu';
    S.GUIMeta.SilenceSide.String = {'Left', 'Right'};
    
end
