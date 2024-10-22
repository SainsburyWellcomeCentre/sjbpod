function Sound_And_Stimulation_GUIParameters()

    global S %BpodSystem
    
    %% General tab:
    S.GUITabs.General = {'General'};
    % Fields
    S.GUIPanels.General = {'LowFrequency','HighFrequency','SoundAmplitude'...
        'SoundDuration','Silence'};
    % Define
    S.GUI.LowFrequency = 2000;
	S.GUI.HighFrequency = 50000;
	S.GUI.SoundAmplitude = 0.02;
    S.GUI.SoundDuration = .5;
    S.GUI.Silence = 4;
    
    %% PulsePal tab:
    S.GUITabs.OptoStimulation = {'OptoStimulation'};
    % Fields
    S.GUIPanels.OptoStimulation = {'OptoStim', 'OptoChance', 'PulseDuration'...
        'PulseInterval', 'TrainDuration'};
    % Define
    S.GUI.OptoStim = 1; % Default is no stimulation
    S.GUIMeta.OptoStim.Style = 'popupmenu'; % the GUIMeta field is used by the ParameterGUI plugin to customize UI objects.
    S.GUIMeta.OptoStim.String = {'No', 'Yes'};
    S.GUI.OptoChance = 0.2; % % of trials which will have stimulation
    
    S.GUI.PulseDuration = 0.005; % Set output channel to produce 5ms pulses
    S.GUI.PulseInterval = 0.095; % Set pulse interval to produce 10Hz pulses
    S.GUI.TrainDuration = 0.5; % Set pulse train to last 0.5 seconds
    
end
