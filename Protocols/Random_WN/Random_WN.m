function Random_WN
global BpodSystem nidaq S
% EndPulsePal;
try 
    evalin('base', 'PulsePalSystem;') 
catch
    try
        PulsePal;
    catch
        disp('Pulsepal not connected')
    end
end
S = BpodSystem.ProtocolSettings;
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings

    Random_WN_GUIParameters();
end

% Initialize parameter GUI plugin
BpodParameterGUI_with_tabs('init', S);
BpodSystem.Status.Pause=1;
HandlePauseCondition;
% Sync S to the changed GUI parameters
S = BpodParameterGUI_with_tabs('sync', S);

S.PercVect = [98, 82, 66, 50, 34, 18, 2];
S.ToneOptions = fliplr(logspace(log10(7500), log10(30000), 7));

%% Define stable sound parameters: 
%percentage of high tones (difficulty). High-Left, Low-Right

%HighFreq = logspace(log10(20000), log10(40000), 16);   % silenced YJ
%LowFreq = logspace(log10(5000), log10(10000), 16);     % silenced YJ
sampRate = 192000;
duration = S.GUI.SoundDuration;
rampTime = 0.01; 
amplitude = S.GUI.SoundAmplitude; %Calibrate properly! 
subduration = 0.03;
suboverlap = 0.01;


PsychToolboxSoundServer('init');
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';
MaxTrials = 1500;
% Define trial sequence
TrialsProb = [1];
%TrialsProb = [0.5, 0.5];           % silence YJ
TrialSequence = WeightedRandomTrials(TrialsProb, MaxTrials);

%TrialSequence(TrialSequence==2) = 7;

emptyVector = nan(1, length(TrialSequence));
BpodSystem.Data.TrialSequence = emptyVector;
BpodSystem.Data.SoundAmplitude = emptyVector;
BpodSystem.Data.Stimulus = {};
BpodSystem.Data.TrialHighPerc = emptyVector;
BpodSystem.Data.SoundAmplitude = emptyVector;

%% Main trial loop
for currentTrial = 1:MaxTrials
    S.ITI = 100;
    while S.ITI > 3 * S.GUI.ITI || S.ITI < 2 * duration
        S.ITI = exprnd(S.GUI.ITI);
    end
    display(S.ITI)
    
    %HighPerc = S.PercVect(TrialSequence(currentTrial));    % silence YJ
    %LowPerc = 100 - HighPerc;                              % silence YJ
    
    ToneForThisTrial = S.ToneOptions(TrialSequence(currentTrial));
    %COTSound = CloudOfTones(sampRate, duration, rampTime, amplitude, HighFreq, LowFreq, HighPerc, LowPerc, subduration, suboverlap);
    modAmp = randomAmplitudeModulation(duration,sampRate,15,0.8);
    
    ModCOTSound = GenerateWhiteNoise(sampRate, duration, rampTime, amplitude);
    SoundType = 'WN';
    %ModCOTSound = modAmp.*COTSound;
    
    SoundID = 1;
    PsychToolboxSoundServer('Load', SoundID, ModCOTSound);

    SoundOutput = {'SoftCode', SoundID};
        %% Assemble state matrix
    sma = NewStateMachine(); 
    sma = AddState(sma, 'Name', 'TrialStart', ... 
        'Timer', 0.01, ...
        'StateChangeConditions', {'Tup', 'Cue'}, ...
        'OutputActions', {'BNCState', 2}); %to sync with photometry
     %'Cue' is the second automatic state
    sma = AddState(sma, 'Name', 'Cue', ...
        'Timer', duration, ...
        'StateChangeConditions', {'Tup', 'ITI'}, ...
        'OutputActions', SoundOutput);
    %ITI is drawn from random exponential distribution
    sma = AddState(sma,'Name', 'ITI',...
        'Timer',S.ITI,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions',{});
    
    SendStateMachine(sma);
    RawEvents = RunStateMachine;
     
  if ~isempty(fieldnames(RawEvents)) 
    BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data

    %BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
    BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
    BpodSystem.Data.TrialSequence(currentTrial) = TrialSequence(currentTrial); % Adds the trial type of the current trial to data
    %BpodSystem.Data.TrialHighPerc(currentTrial) = HighPerc; %'difficulty' % silence YJ
    BpodSystem.Data.Stimulus{currentTrial} = ModCOTSound; %save the sound
    BpodSystem.Data.SoundAmplitude(currentTrial) = amplitude; %sound amplitude
    BpodSystem.Data.SoundType{currentTrial} = SoundType; % sound type
    
    SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file

        HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0 %stop button pressed        
        PsychToolboxSoundServer('close'); % Close sound server
        return
    end
  end
end
end