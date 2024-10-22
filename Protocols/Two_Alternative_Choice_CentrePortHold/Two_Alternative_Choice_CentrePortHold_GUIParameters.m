function Two_Alternative_Choice_CentrePortHold_GUIParameters()

    global S %BpodSystem
    
    %% General tab:
    S.GUITabs.General = {'General'};
    % Fields
    S.GUIPanels.General = {'SoundAmplitude','LEDIntensity','RewardAmount',...
        'ResponseTime','CenterPortDuration','VariableCueDelay','MaxCenterPortDuration','PunishDelay','TrainingLevel',...
        'BiasCorrection','Punish'};
    % Define
    S.GUI.SoundAmplitude = 0.005;
    S.GUI.LEDIntensity = 5;
    S.GUI.RewardAmount = 2; % ul
    S.GUI.ResponseTime = 10; % seconds to respond
    S.GUI.CenterPortDuration = 0.1; % How long the mouse must poke in the center to activate the goal port
    S.GUI.VariableCueDelay = 0; %default is off
    S.GUIMeta.VariableCueDelay.Style = 'checkbox';
    S.GUI.MaxCenterPortDuration = 1;
    S.GUI.PunishDelay = 3; % Seconds of punishment
    
    S.GUI.TrainingLevel = 1; % Default Training Level
    S.GUIMeta.TrainingLevel.Style = 'popupmenu'; % the GUIMeta field is used by the ParameterGUI plugin to customize UI objects.
    S.GUIMeta.TrainingLevel.String = {'Habituation', 'Visual', 'Auditory', 'Aud_Psycho'};
    
    S.GUI.BiasCorrection = 1; % Default is yes
    S.GUIMeta.BiasCorrection.Style = 'checkbox';
    
    S.GUI.Punish = 1; % Default
    S.GUIMeta.Punish.Style = 'popupmenu'; % the GUIMeta field is used by the ParameterGUI plugin to customize UI objects.
    S.GUIMeta.Punish.String = {'No', 'Only choice', 'Also early center out'};
    
    
    %% Specifics tab:
    S.GUITabs.Specifics = {'Specifics'};
    % Fields
    S.GUIPanels.Specifics = {'Contingency','ContingencyBlockLength',...
        'Muscimol','RewardProb', 'LargeRewardProb', 'RewardChange','RewardChangeBlockLength'};
    
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
    
    
    %% PulsePal tab:
    S.GUITabs.OptoStimulation = {'OptoStimulation'};
    % Fields
    S.GUIPanels.OptoStimulation = {'OptoStim', 'OptoChance', 'PulseDuration'...
        'PulseInterval', 'TrainDuration'};
    % Define
    S.GUI.OptoStim = 1; % Default is no stimulation
    S.GUIMeta.OptoStim.Style = 'popupmenu'; % the GUIMeta field is used by the ParameterGUI plugin to customize UI objects.
    S.GUIMeta.OptoStim.String = {'NoStimulation', 'Left', 'Right', 'Both'};
    S.GUI.OptoChance = 0.15; % % of trials which will have stimulation
    
    S.GUI.PulseDuration = 0.005; % Set output channel to produce 5ms pulses
    S.GUI.PulseInterval = 0.045; % Set pulse interval to produce 20Hz pulses
    S.GUI.TrainDuration = 0.5; % Set pulse train to last 0.5 seconds
    
end
