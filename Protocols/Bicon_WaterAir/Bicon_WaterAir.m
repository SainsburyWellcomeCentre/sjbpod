%{
---------------------------------------------------------------------------
Bicon_WaterAir.m
2020/11/03
Svenja Nierwetberg
Stephenson-Jones/MacAskill Lab
Sainsbury Wellcome Center

Based on: Sequence.m + Context_Bicon.m (SJ Lab)
---------------------------------------------------------------------------
%}
%{
---------------------------------------------------------------------------
Contextual Biconditional Discrimination task for freely moving mice and one
port. Task is run in either of two contexts (A or B).
The stimulus is either an 7kHz tone (Tone1) or 16kHz tone (Tone2).

Full Task:
In ContextA, responding to Tone1 gives reward, but responding to Tone2
results in punishment. In Context2 the rules are reversed. Both Tones occur
in a pseudorandom fashion in any session, with the ratio determined in the GUI. 

Association:
In this version, only the rewarded cue occurs. This is intended to interest
the mouse in the port. 

Trial Structure
- The trial starts after a variable ITI with the cue coming on (Tone1 or
Tone 2)
- If the mouse pokes into the port before the timeout, this counts as a
response trial.
- If the response was correct, the mouse receives a reward
- If the response was incorrect, the mouse receives an air puff & a white
noise stimulus
- Otherwise, nothing happens and the next ITI starts. 


TODO:
- Trial Numbers: Does the protocol actually stop after NrOfTrials
- Figure out Valveidx 

---------------------------------------------------------------------------
%}
%% 

function Bicon_WaterAir
%% DESCRIPTION
% Biconditional Tone Discrimination Task with 2 outcomes (reward,
% punishment)
%

%% init
global BpodSystem S;

S = BpodSystem.ProtocolSettings;
if isempty(fieldnames(S))
    p = []; m = [];
    
    %% Define TaskType, TrainingStage, ITI, TO, NrOfTrials
    p.SubjectName = 00;
    
    p.TaskType = 1; % 1=A, 2=B, 
    m.TaskType.Style = 'popupmenu';
    m.TaskType.String = {'A', 'B'};  % which contingency: A - Tone 1 is rewarded, B - Tone 2 is rewarded
    
    p.TrainingStage = 1; % 1=Full, 2=Association
    m.TrainingStage.Style = 'popupmenu';
    m.TrainingStage.String = {'Full', 'Association'};
    
    p.ITI_lower = 15; % sec
    p.ITI_upper = 30;
    
    p.Timeout = 5; % sec
    
    p.Reward_amount_uL = 5;
    
    p.Trials_NrOfTrials = 60;
    p.Percent_Punished = 0.3;
    
    p.Amplitude = 0.5; %SoundAmplitude for cues
    
    %% set gui
    S.GUI = p;
    S.GUIMeta = m;
end
%% Make fancy new GUI
BpodParameterGUI_with_tabs('init', S);
%% Make permutation vector of trial types

switch S.GUIMeta.TaskType.String{S.GUI.TaskType}
    %Use different rules depending on contingency
    case 'A'
        %ConA means Tone1 is rewarded, and Tone2 is not
        TrialsType1 = ones(1, (S.GUI.Trials_NrOfTrials*(1-S.GUI.Percent_Punished)));
        TrialsType0 = zeros(1, (S.GUI.Trials_NrOfTrials*S.GUI.Percent_Punished));
        TrialType = [TrialsType1, TrialsType0];
    case 'B'
        %ConB means Tone2 is rewarded, and Tone1 is not
        TrialsType0 = zeros(1, (S.GUI.Trials_NrOfTrials*(1-S.GUI.Percent_Punished)));
        TrialsType1 = ones(1, (S.GUI.Trials_NrOfTrials*S.GUI.Percent_Punished));
        TrialType = [TrialsType1, TrialsType0];
    otherwise
        error('Not implemented.')
end

RandomTrials = TrialType(randperm(length(TrialType)));

for e = 3:length(RandomTrials)
    if RandomTrials(e)==RandomTrials(e-1)&& RandomTrials(e)==RandomTrials(e-2)
        r = RandomTrials(e:length(RandomTrials));
        RandomTrials(e:length(RandomTrials)) = r(randperm(length(r)));
    end
end

%% Generate and Load Sounds
InitializePsychSound;

%Sound Parameters
Frequency_1 = 7000;     %Tone 1 = 7kHz
Modulation1 = 4;        %'Speed' of modulation for Freq1
Frequency_2 = 10000;    %Tone 2 = 16 kHz
Modulation2 = 5;        %'Speed' of modulation for Freq2
widthFreq = 1.002;      % no real clue what this does, look into specs of SoundGenerator function
nbOfFreq = 4;           % same as above
ToneDuration = 20;      %duration in s
RampTime = 0.005;       %time in s that the tone ramps up (to prevent speaker cracking)
SamplingRate = 192000;
Amplitude = S.GUI.Amplitude*0.02;
WN_Amplitude = S.GUI.Amplitude*0.5; % White Noise Amplitude, should be aversive i.e. higher than tone-amplitude

%Make two sounds out of the above parameters
Sound1 = SoundGenerator(SamplingRate, Frequency_1, widthFreq, nbOfFreq, ToneDuration, RampTime, Amplitude);
Sound2 = SoundGenerator(SamplingRate, Frequency_2, widthFreq, nbOfFreq, ToneDuration, RampTime, Amplitude);

%Generate White Noise Punishment
Sound3 = GenerateWhiteNoise(SamplingRate, ToneDuration, RampTime, WN_Amplitude);

%Modulation script, copied from Emmett						
%Time specifications:						
Fs = SamplingRate;           % samples per second						
dt = 1/Fs;                   % seconds per sample						
StopTime = ToneDuration;						
t = (0:dt:StopTime-dt)';     % seconds		

%Make two modulation waves						
Amp1(1,:) = (((cos(2*pi*Modulation1*t))+1)/2)*-1 + 1;						
Amp2(1,:) = (((cos(2*pi*Modulation2*t))+1)/2)*-1 + 1;	

%Modulate sound waves with modulation waves						
ModSound1 = Sound1 .* Amp1;						
ModSound2 = Sound2 .* Amp2;												

%Initialize Soundserver and load two sounds
%They can be accessed with 'Sound1' and 'Sound2' respectively
PsychToolboxSoundServer('init');
PsychToolboxSoundServer('Load', 1, ModSound1);
PsychToolboxSoundServer('Load', 2, ModSound2);
PsychToolboxSoundServer('Load', 3, Sound3);
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';

%% WAIT for user go, Pause to get GUI parameters
BpodSystem.Status.Pause=1;
HandlePauseCondition;

% Save current git commit, on which the protocol is executed on
[~, git_hash_string] = system('git rev-parse HEAD');
BpodSystem.Data.git_hash_string = git_hash_string;

% Sync S to the changed GUI parameters
S  = BpodParameterGUI('sync', S);

%% Initiate plots 
MultiFigureSN = figure('Position', [10 10 1000 600],'numbertitle','off', 'MenuBar', 'none', 'Resize', 'on');

OnlinePlot(BpodSystem, 'Init', MultiFigureSN);
%%
for trialIdx = 1:S.GUI.Trials_NrOfTrials
    %% paradigm
    S = BpodParameterGUI_with_tabs('sync', S);
    
    %% s
    switch S.GUIMeta.TrainingStage.String{S.GUI.TrainingStage}
        case 'Full' 
            %randomly decide which Sound to play
            if RandomTrials(trialIdx)== 1
                SoundID = 1;
                headsup = 'Current Tone is Tone1.'
            elseif RandomTrials(trialIdx)== 0
                SoundID = 2;
                headsup = 'Current Tone is Tone2.'
            else
                headsup = 'Trial Type not updated.'
            end
        case 'Association'
            if S.GUI.TaskType == 1
                SoundID = 1;
                headsup = 'Current Tone is Tone1.'
            else
                SoundID = 2;
                headsup = 'Current Tone is Tone2.'
            end
    end
       
    switch S.GUIMeta.TaskType.String{S.GUI.TaskType} 
        %Use different rules depending on contingency
        case 'A' 
            %ConA means Tone1 is rewarded, and Tone2 is not
            if SoundID == 1
                outcome = 'Water';
            else 
                outcome = 'AirPuff';
            end
        case 'B'
            %ConB means Tone2 is rewarded, and Tone1 is not
            if SoundID == 2
                outcome = 'Water';
            else 
                outcome = 'AirPuff';
            end
        otherwise
            error('Not implemented.')
    end
    
    %% draw delay
    iti_range = S.GUI.ITI_upper - S.GUI.ITI_lower;
    ITI = randi(iti_range,1) + S.GUI.ITI_lower;
    
    %% valves
    valve_time = GetValveTimes(S.GUI.Reward_amount_uL, 1);
    valve_time_air = 0.2; %in seconds

    %% Assemble state matrix
    sma = NewStateMachine();
    sma = AddState(sma, 'Name', 'ITI', ...
        'Timer', ITI, ...
        'StateChangeConditions', {'Tup', 'Cue' }, ... %'Port1In', 'AirPuff'
        'OutputActions', {'SoftCode', 255});
    sma = AddState(sma, 'Name', 'Cue', ...
        'Timer', S.GUI.Timeout, ...
        'StateChangeConditions', {'Port1In', outcome, 'Tup', 'exit'},...
        'OutputActions', {'SoftCode',SoundID});
    sma = AddState(sma, 'Name', 'Water', ...
        'Timer', valve_time, ...
        'StateChangeConditions', {'Tup', 'exit'}, ...
        'OutputActions', {'ValveState', 1,'SoftCode', SoundID});
    sma = AddState(sma, 'Name', 'AirPuff', ...
        'Timer', valve_time_air, ...
        'StateChangeConditions', {'Tup', 'exit'}, ...
        'OutputActions', {'ValveState', 2,'SoftCode', 3});
    
    SendStateMachine(sma);
    RawEvents = RunStateMachine;
    BpodSystem.Data.nTrials = trialIdx;
    BpodSystem.Data.Sound(trialIdx) = SoundID;
    
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data, RawEvents);
        BpodSystem.Data.TrialSettings(trialIdx) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        BpodSystem.Data.TaskType = S.GUI.TaskType;
        
        SaveBpodSessionData;
    end
    
    OnlinePlot(BpodSystem, 'Update', MultiFigureSN);
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    
    if BpodSystem.Status.BeingUsed == 0 %stop button pressed
        OnlinePlot(BpodSystem, 'CleanUp', MultiFigureSN);
        return
    end
end


end