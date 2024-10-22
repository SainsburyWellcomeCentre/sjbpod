%{
---------------------------------------------------------------------------
Short_Sequence.m
MAIN PROTOCOL
2020
Emmett James Thompson
Sainsbury Wellcome Center
---------------------------------------------------------------------------

%% ADAPTED from % to 4 POKE SEQUENCE 29/09/19 EJT

Training stages:

1. Habitutation
Follow the light (all pokes rewarded). lights move across the whole
sequence/sequences. Reward sound accompanys rewards. Erroneous pokes not punihsed, no
time limit.

2. CueDevaluation
Rewards reduced (except not at the end of the sequence/sequences) and
lights dim on every succesful run through of the sequence. Erroneous pokes not
punihsed, no time limit.

3. Sound guided
Same as the end of cue deval: no lights, correct pokes are indicated to the
mouse by the reward noise. With optional warm up phase. 
(timeout is 60s)

4. final task
Same as above but now sounds play for every single port so dont indicate
correct path. timeout is default set to 30s 

5. custom
decide which ports dimish. 


multiple sequences = trials are presented in a block structure
%}

%% Make BpodSystem object
global BpodSystem S

beep('off'); % native matlab error sounds OFF

%% Create trial manager object
TrialManager = TrialManagerObject;


%% GUI Params
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S

if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    
    %Task Features
    S.GUI.TrainingLevel = 3; % Default Training Level
    S.GUIMeta.TrainingLevel.Style = 'popupmenu'; % the GUIMeta field is used by the ParameterGUI plugin to customize UI objects.
    S.GUIMeta.TrainingLevel.String = {'1_Habituation', '2_Cue_Devaluation', '3_Sound_Guided', '4_Final_Task','5_Custom_Devaluation'};
    
    S.GUI.Number_of_Sequences = 1; % Default Training Level
    S.GUIMeta.Number_of_Sequences.Style = 'popupmenu'; % the GUIMeta field is used by the ParameterGUI plugin to customize UI objects.
    S.GUIMeta.Number_of_Sequences.String = {'1', '2', '3'};
    
    S.GUI.UsePreviousSettings = 0; %default is off
    S.GUIMeta.UsePreviousSettings.Style = 'checkbox';
    
    S.GUI.OptoStim = 0; % off by default
    S.GUIMeta.OptoStim.Style = 'checkbox';
    
    S.GUI.PunishSound = 0; %default is off
    S.GUIMeta.PunishSound.Style = 'checkbox';
    
    S.GUI.RewardSound = 1; %default is on
    S.GUIMeta.RewardSound.Style = 'checkbox';
    
    S.GUI.CueSound = 0; %default is off
    S.GUIMeta.CueSound.Style = 'checkbox';
    
    S.GUI.WarmUp = 0; %default is off
    S.GUIMeta.WarmUp.Style = 'checkbox';
    
    S.GUI.ExperimentType = 1 ; %default is training
    S.GUIMeta.ExperimentType.Style = 'popupmenu';
    S.GUIMeta.ExperimentType.String = {'1_Training', '2_Muscimol', '3_ZIP', '4_Caspase'}; 
    
    %Sequences
    S.GUI.Sequence_1 = 2637;
    S.GUI.Sequence_2 = 0000;
    S.GUI.Sequence_3 = 0000;
    S.GUI.MultiSeq_LowerBlockBound = 15;
    S.GUI.MultiSeq_UpperBlockBound = 30;
    S.GUI.Custom_Dimish_Ports = 4;
    
    %lag times to allow enough time for trial manager to fully compute sma
    S.GUI.LagTime1 = 0.4;
    S.GUI.LagTime2 = 0.3; % less time needed once there is no lights of cue deval as sma is created faster
    
    
    %Reward/Punihsment
    S.GUI.FinalRewardAmount = 1.5; %ul
    S.GUI.IntermediateRewardAmount = 2; %ul
    S.GUI.LEDIntensity = 100; %
    S.GUI.RewardDelay = 0; %s
    S.GUI.Shaping_ResponseWindow = 60;
    S.GUI.FinalTask_ResponseWindow = 30; %s
    S.GUI.HabituationResponseWindow = 1000; %s
    S.GUI.PunishTimeoutDuration = 0; %s
    S.GUI.Shaping1_WarmUpEnd = 50;
    S.GUI.CueDevalRate = 0.985; %percentage change across trials during cue deval sessions
    
    %Sound Feautres
    S.GUI.PunishSoundAmplitude = 0.015;
    S.GUI.CueSoundAmplitude = 0.009;
    S.GUI.RewardSoundAmp = 4;
    S.GUI.RewardSoundDuration = 1;
    S.GUI.PunishSoundDuration = 0.3;
    S.GUI.Cue_Duration = 1;
    S.GUI.Cue1_Frequencey = 8000;
    S.GUI.Cue1_Modulation = 4; %Hz
    S.GUI.Cue2_Frequencey = 18000;
    S.GUI.Cue2_Modulation = 4; %Hz
    S.GUI.Cue3_Frequencey = 28000;
    S.GUI.Cue3_Modulation = 4; %Hz
    
    %Stim Feautres
    S.GUI.StimPoke = 1; % poke number that triggers stim, # 
    S.GUI.PulsePower = 12; % power in V
    S.GUI.OptoChance = 0.15; % % of trials which will have stimulation
    S.GUI.PulseDuration = 0.005; % Set output channel to produce 5ms pulses
    S.GUI.PulseInterval = 0.045; % Set pulse interval to produce 20Hz pulses
    S.GUI.TrainDuration = 0.5; % Set pulse train to last 0.5 seconds
    
    
    S.GUIPanels.Task = {'TrainingLevel','Number_of_Sequences','UsePreviousSettings','WarmUp','ExperimentType','Sequence_1', 'Sequence_2', 'Sequence_3', 'OptoStim'}; % GUIPanels organize the parameters into groups.
    S.GUIPanels.Settings = {'FinalRewardAmount','IntermediateRewardAmount', 'CueDevalRate','Custom_Dimish_Ports','RewardDelay', 'Shaping1_WarmUpEnd','Shaping_ResponseWindow','FinalTask_ResponseWindow','HabituationResponseWindow','PunishTimeoutDuration','LEDIntensity','MultiSeq_LowerBlockBound','MultiSeq_UpperBlockBound', 'LagTime1', 'LagTime2'};
    S.GUIPanels.Sound = { 'PunishSound', 'RewardSound', 'CueSound', 'PunishSoundAmplitude','CueSoundAmplitude','RewardSoundAmp', 'RewardSoundDuration','PunishSoundDuration','Cue_Duration', 'Cue1_Frequencey', 'Cue1_Modulation','Cue2_Frequencey', 'Cue2_Modulation','Cue3_Frequencey', 'Cue3_Modulation'};
    S.GUIPanels.Stim_Settings = {'StimPoke','OptoChance','PulsePower', 'PulseDuration','PulseInterval', 'TrainDuration'};
    
    S.GUITabs.Task = {'Task'};
    S.GUITabs.Settings = {'Settings'};
    S.GUITabs.Sound = {'Sound'};
    S.GUITabs.Stim_Settings = {'Stim_Settings'};
    
end

% Initialize parameter GUI plugin
BpodParameterGUI_with_tabs('init', S);
set(BpodSystem.ProtocolFigures.ParameterGUI, 'Position', [0 550 450, 680 ]);

%Open the schematic image of the ports...
Protocol_Path = BpodSystem.Path.ProtocolFolder;
PNG_Path = 'Sequence/Sequence_Helper_Files/PortLayout.png';
I = imread(strcat(Protocol_Path,PNG_Path));
figure(10);set(gcf,'Position',[0 1500 5 5]); imshow(I);

% Pause to allow user to change GUI parameters
BpodSystem.Status.Pause=1;
HandlePauseCondition;

%Close the schematic image of the ports...
close(10);

% Sync S to the changed GUI parameters
S = BpodParameterGUI('sync', S);


%% Find previous settings if asked for in GUI
BpodSystem.Status.CurrentSubjectName
if S.GUI.UsePreviousSettings == 1 && S.GUI.TrainingLevel == 2 %if tick box checked find and use data from previous day
    disp('Please find data from previous day')
    path = strcat(BpodSystem.Path.DataFolder,BpodSystem.GUIData.SubjectName,'/',BpodSystem.GUIData.ProtocolName,'/Session Data');
    file = uigetfile(path);
    previousdata = load(strcat(path,'/',file));
    
    PreviousLEDIntensity2 = previousdata.SessionData.SessionVariables.LEDIntensitys.port2(previousdata.SessionData.nTrials);
    PreviousLEDIntensity3 = previousdata.SessionData.SessionVariables.LEDIntensitys.port3(previousdata.SessionData.nTrials);
    PreviousLEDIntensity4 = previousdata.SessionData.SessionVariables.LEDIntensitys.port4(previousdata.SessionData.nTrials);
    PreviousLEDIntensity5 = previousdata.SessionData.SessionVariables.LEDIntensitys.port5(previousdata.SessionData.nTrials);
    
    BpodSystem.Data.sma_vars.PrevLEDIntensity2 = PreviousLEDIntensity2 * 1.1; % increase from revious day to get mouse back in the swing of things
    BpodSystem.Data.sma_vars.PrevLEDIntensity3 = PreviousLEDIntensity3 * 1.1; % increase from revious day to get mouse back in the swing of things
    BpodSystem.Data.sma_vars.PrevLEDIntensity4 = PreviousLEDIntensity4 * 1.1; % increase from revious day to get mouse back in the swing of things
    BpodSystem.Data.sma_vars.PrevLEDIntensity5 = PreviousLEDIntensity5 * 1.1; % increase from revious day to get mouse back in the swing of things
    
    IntermediateRewardAmount1 = previousdata.SessionData.SessionVariables.ItermediateRewardAmount.Port1(previousdata.SessionData.nTrials);
    IntermediateRewardAmount2 = previousdata.SessionData.SessionVariables.ItermediateRewardAmount.Port2(previousdata.SessionData.nTrials);
    IntermediateRewardAmount3 = previousdata.SessionData.SessionVariables.ItermediateRewardAmount.Port3(previousdata.SessionData.nTrials);
    IntermediateRewardAmount4 = previousdata.SessionData.SessionVariables.ItermediateRewardAmount.Port4(previousdata.SessionData.nTrials);
    
    BpodSystem.Data.sma_vars.PrevIntermediateRewardAmount1 = IntermediateRewardAmount1 * 1.1; % increase from revious day to get mouse back in the swing of things
    BpodSystem.Data.sma_vars.PrevIntermediateRewardAmount2 = IntermediateRewardAmount2 * 1.1; % increase from revious day to get mouse back in the swing of things
    BpodSystem.Data.sma_vars.PrevIntermediateRewardAmount3 = IntermediateRewardAmount3 * 1.1; % increase from revious day to get mouse back in the swing of things
    BpodSystem.Data.sma_vars.PrevIntermediateRewardAmount4 = IntermediateRewardAmount4 * 1.1; % increase from revious day to get mouse back in the swing of things
end

%% Define trials
BpodSystem.Data.MaxTrials = 2000;

%If multiple sequences selected then make the trials in blocks with repspect to all possible sequences

switch S.GUI.Number_of_Sequences
    case {1} % 1 sequence
        TrialTypes = linspace(1, 1,BpodSystem.Data.MaxTrials);
    case {2} % 2 sequences
        TrialTypes = make_block_structure(2,S.GUI.MultiSeq_LowerBlockBound,S.GUI.MultiSeq_UpperBlockBound,BpodSystem.Data.MaxTrials);
    case {3} % 3 sequences
        TrialTypes = make_block_structure(3,S.GUI.MultiSeq_LowerBlockBound,S.GUI.MultiSeq_UpperBlockBound,BpodSystem.Data.MaxTrials);
end

    
%clear variables for saving out data
BpodSystem.Data.TrialTypes = [];
BpodSystem.Data.TrialSequence = [];
BpodSystem.Data.SessionVariables.Punish_condition = [];

%% Generate and Load Sounds
InitializePsychSound

%Sound Parameters:
sampRate = 192000;
widthFreq = 1.002;
nbOfFreq = 4;
punish_rampTime = 0.005;
rampTime = 0.005;


%Define reward and punihsment sounds if they are asked for via the GUI:
%make punish sound
if S.GUI.PunishSound == 1
    PunishSound = rand(1,sampRate*S.GUI.PunishSoundDuration)*S.GUI.PunishSoundAmplitude;
    ramp = ones(1,(sampRate*S.GUI.PunishSoundDuration));
    ramp(1:((sampRate*S.GUI.PunishSoundDuration)*punish_rampTime)) = linspace(0,1,(sampRate*S.GUI.PunishSoundDuration)*punish_rampTime);
    PunishSound = PunishSound.*ramp; %ramp the signal
else
    PunishSound = zeros(1,sampRate*S.GUI.PunishSoundDuration); %No noise but will still play the 'sound'
end

%make reward sound
if S.GUI.RewardSound == 1
    srate=20000; % sampling rate
    freq1=5;
    dur1=1.5*1000;
    RewardSound = S.GUI.RewardSoundAmp*(MakeBupperSwoop(srate,0, freq1 , freq1 , dur1/2 , dur1/2,0,0.1));
else
    RewardSound = zeros(1,sampRate*S.GUI.RewardSoundDuration); %No noise but will still play the 'sound'
end

%Define Cue sounds and modulation:

if S.GUI.CueSound == 1
    switch S.GUI.Number_of_Sequences
        case{1}
            Sequence_Cue1 = SoundGenerator(sampRate, S.GUI.Cue1_Frequencey, widthFreq, nbOfFreq, S.GUI.Cue_Duration, rampTime,S.GUI.CueSoundAmplitude);
            Sequence_Cue2 = zeros(1,sampRate*S.GUI.Cue_Duration); %No noise but will still play the 'sound'
            Sequence_Cue3 = zeros(1,sampRate*S.GUI.Cue_Duration); %No noise but will still play the 'sound'
        case{2}
            Sequence_Cue1 = SoundGenerator(sampRate, S.GUI.Cue1_Frequencey, widthFreq, nbOfFreq, S.GUI.Cue_Duration, rampTime,S.GUI.CueSoundAmplitude);
            Sequence_Cue2 = SoundGenerator(sampRate, S.GUI.Cue2_Frequencey, widthFreq, nbOfFreq, S.GUI.Cue_Duration, rampTime,S.GUI.CueSoundAmplitude);
            Sequence_Cue3 = zeros(1,sampRate*S.GUI.Cue_Duration); %No noise but will still play the 'sound'
        case{3}
            Sequence_Cue1 = SoundGenerator(sampRate, S.GUI.Cue1_Frequencey, widthFreq, nbOfFreq, S.GUI.Cue_Duration, rampTime,S.GUI.CueSoundAmplitude);
            Sequence_Cue2 = SoundGenerator(sampRate, S.GUI.Cue2_Frequencey, widthFreq, nbOfFreq, S.GUI.Cue_Duration, rampTime,S.GUI.CueSoundAmplitude);
            Sequence_Cue3 = SoundGenerator(sampRate, S.GUI.Cue3_Frequencey, widthFreq, nbOfFreq, S.GUI.Cue_Duration, rampTime,S.GUI.CueSoundAmplitude);
    end
else
    Sequence_Cue1 = zeros(1,sampRate*S.GUI.Cue_Duration); %No noise but will still play the 'sound'
    Sequence_Cue2 = zeros(1,sampRate*S.GUI.Cue_Duration); %No noise but will still play the 'sound'
    Sequence_Cue3 = zeros(1,sampRate*S.GUI.Cue_Duration); %No noise but will still play the 'sound'
end

% %Define Amplitude modulations:
%Time specifications:
Fs = sampRate;               % samples per second
dt = 1/Fs;                   % seconds per sample
StopTime = S.GUI.Cue_Duration;
t = (0:dt:StopTime-dt)';     % seconds
%Modualtion Waves
Amp1(1,:) = (((cos(2*pi*S.GUI.Cue1_Modulation*t))+1)/2)*-1 + 1;
Amp2(1,:) = (((cos(2*pi*S.GUI.Cue2_Modulation*t))+1)/2)*-1 + 1;
Amp3(1,:) = (((cos(2*pi*S.GUI.Cue3_Modulation*t))+1)/2)*-1 + 1;
%Modulate sound waves with modulation waves
Sequence_Cue1 = Sequence_Cue1 .* Amp1;
Sequence_Cue2 = Sequence_Cue2 .* Amp2;
Sequence_Cue3 = Sequence_Cue3 .* Amp3;


%Initiate sound server and load sounds:
PsychToolboxSoundServer('init');
PsychToolboxSoundServer('Load', 1, Sequence_Cue1);
PsychToolboxSoundServer('Load', 2, Sequence_Cue2);
PsychToolboxSoundServer('Load', 3, Sequence_Cue3);
PsychToolboxSoundServer('Load', 4, RewardSound);
PsychToolboxSoundServer('Load', 5, PunishSound);

BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';

%% Initialize plots

MultiFigureEJT = figure('Position', [10 10 1000 600],'name',SubjectName,'numbertitle','off', 'MenuBar', 'none', 'Resize', 'on');

%Create an object that is called on cleanup to save stuff
[filepath,name,~] = fileparts(BpodSystem.Path.CurrentDataFile);
finishup = onCleanup(@() CleanupFunctionSeq(MultiFigureEJT, filepath, name));

%% Initialize pulsepal
if S.GUI.OptoStim == 1
  
    try
        evalin('base', 'PulsePalSystem;')
    catch
        try
            PulsePal('COM3');
        catch
            disp('Pulsepal not connected')
        end
    end
    
    %Load parameters to pulsepal
    S.InitialPulsePalParameters = struct;
    load PulsePal_ParameterMatrix;
    try
        ProgramPulsePal(ParameterMatrix);
        S.InitialPulsePalParameters = ParameterMatrix;
    catch
        disp('Pulsepal default parameters failed to load')
    end
    
    % Specific task-related parameters
    try
        ProgramPulsePalParam(1, 'Phase1Voltage', S.GUI.PulsePower); % Set output channel 1 to produce 5V pulses
        ProgramPulsePalParam(1, 'Phase1Duration', S.GUI.PulseDuration); % Set output channel 1 to produce Xms pulses
        ProgramPulsePalParam(1, 'InterPulseInterval', S.GUI.PulseInterval); % Set pulse interval to produce XHz pulses
        ProgramPulsePalParam(1, 'PulseTrainDuration', S.GUI.TrainDuration); % Set pulse train to last X seconds
        %The following fails to load
        %ProgramPulsePalParam(1, 'LinkedToTriggerCH1', 1); % Set output channel 1 to respond to trigger ch 1
        ProgramPulsePalParam(1, 'TriggerMode', 0); % Set trigger channel 1 to toggle mode
    catch
        disp('Pulsepal specific parameters failed to load')
    end
    
    %Generate trials with optostimulation
    OptoStim = WeightedRandomTrials([1-S.GUI.OptoChance S.GUI.OptoChance], BpodSystem.Data.MaxTrials);
    BpodSystem.Data.SessionVariables.OptoStim = OptoStim - 1; % 0s or 1s
else
    BpodSystem.Data.SessionVariables.OptoStim = linspace(0,0,BpodSystem.Data.MaxTrials);
end
         

%% Setup Trial manager for parallel (speedy) initiation 

%convert the sequence integer back into an array so it can be indexed:
S.GUI.Sequence_1 = num2str(S.GUI.Sequence_1)-'0';
S.GUI.Sequence_2 = num2str(S.GUI.Sequence_2)-'0';
S.GUI.Sequence_3 = num2str(S.GUI.Sequence_3)-'0';

if S.GUI.TrainingLevel == 5
    BpodSystem.Data.sma_vars.custom_ports = num2str(S.GUI.Custom_Dimish_Ports)-'0';
end

sma = PrepareStateMachine(S, TrialTypes, 1, []); % Prepare state machine for trial 1 with empty "current events" variable
TrialManager.startTrial(sma); % Sends & starts running first trial's state machine. A MATLAB timer object updates the 
                              % console UI, while code below proceeds in parallel.

                              
                     
                              
%% Main trial loop
for currentTrial = 1:BpodSystem.Data.MaxTrials
    
    currentTrialEvents = TrialManager.getCurrentEvents({'ExitSeq'}); 
                                       % Hangs here until Bpod enters one of the listed trigger states, 
                                       % then returns current trial's states visited + events captured to this point
    if BpodSystem.Status.BeingUsed == 0; return; end % If user hit console "stop" button, end session 
    [sma, S] = PrepareStateMachine(S, TrialTypes, currentTrial+1, currentTrialEvents); % Prepare next state machine.
    % Since PrepareStateMachine is a function with a separate workspace, pass any local variables needed to make 
    % the state machine as fields of settings struct S e.g. S.learningRate = 0.2.
    SendStateMachine(sma, 'RunASAP'); % With TrialManager, you can send the next trial's state machine while the current trial is ongoing
    RawEvents = TrialManager.getTrialData; % Hangs here until trial is over, then retrieves full trial's raw data
    if BpodSystem.Status.BeingUsed == 0; return; end % If user hit console "stop" button, end session 
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    TrialManager.startTrial(); % Start processing the next trial's events (call with no argument since SM was already sent)
    
    % Save out data, update trialoutcome plot:   
    
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        BpodSystem.Data.TrialTypes(currentTrial) = TrialTypes(currentTrial);
        BpodSystem.Data.SessionVariables.LEDIntensitys.port2(currentTrial) = BpodSystem.Data.sma_vars.LedIntensity2;
        BpodSystem.Data.SessionVariables.LEDIntensitys.port3(currentTrial) = BpodSystem.Data.sma_vars.LedIntensity3;
        BpodSystem.Data.SessionVariables.LEDIntensitys.port4(currentTrial) = BpodSystem.Data.sma_vars.LedIntensity4;
        BpodSystem.Data.SessionVariables.ItermediateRewardAmount.Port1(currentTrial) = BpodSystem.Data.sma_vars.SessionVariable_IRA1;
        BpodSystem.Data.SessionVariables.ItermediateRewardAmount.Port2(currentTrial) = BpodSystem.Data.sma_vars.SessionVariable_IRA2;
        BpodSystem.Data.SessionVariables.ItermediateRewardAmount.Port3(currentTrial) = BpodSystem.Data.sma_vars.SessionVariable_IRA3;

        
        if currentTrial == 1
            Short_UpdateOnlinePlotFast(BpodSystem.Data,BpodSystem.GUIData.SubjectName,TrialTypes(currentTrial),'Init',MultiFigureEJT); %update online plot
        else
            Short_UpdateOnlinePlotFast(BpodSystem.Data,BpodSystem.GUIData.SubjectName,TrialTypes(currentTrial),'Update',MultiFigureEJT); %update online plot
        end    
           
        if mod((currentTrial-1), 400) == 0
            SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
            disp('Data saved');
        end
    end
end

%% Trial specific Matrix outputs

function [sma, S] = PrepareStateMachine(S, TrialTypes, currentTrial, currentTrialEvents)
    
    % In this case, we don't need trial events to build the state machine - but
    % they are available in currentTrialEvents.

    global BpodSystem
    
    %Set interpoke timeout limit
    switch S.GUI.TrainingLevel
        case {1 2}
            InterPoke_TimeOut = 36000; %10 hours, so it will never time out and punihsment state should never be reached
        case {3 5}
            InterPoke_TimeOut = S.GUI.Shaping_ResponseWindow;
        case {4}
            InterPoke_TimeOut = S.GUI.FinalTask_ResponseWindow;
    end
    
    %Set the port order based on the trial type and the GUI settings
    if TrialTypes(currentTrial) == 1
        Port_1 = num2str(S.GUI.Sequence_1(1));
        Port_2 = num2str(S.GUI.Sequence_1(2));
        Port_3 = num2str(S.GUI.Sequence_1(3));
        Port_4 = num2str(S.GUI.Sequence_1(4));
        %for saving out the sequence  and experiment data
        BpodSystem.Data.TrialSequence(currentTrial,1) = S.GUI.Sequence_1(1);
        BpodSystem.Data.TrialSequence(currentTrial,2) = S.GUI.Sequence_1(2);
        BpodSystem.Data.TrialSequence(currentTrial,3) = S.GUI.Sequence_1(3);
        BpodSystem.Data.TrialSequence(currentTrial,4) = S.GUI.Sequence_1(4);
        BpodSystem.Data.ExperimentType = S.GUI.ExperimentType;
        
    elseif TrialTypes(currentTrial) == 2
        Port_1 = num2str(S.GUI.Sequence_2(1));
        Port_2 = num2str(S.GUI.Sequence_2(2));
        Port_3 = num2str(S.GUI.Sequence_2(3));
        Port_4 = num2str(S.GUI.Sequence_2(4));
        disp(S.GUI.Sequence_2)
        %for saving out the sequence data
        BpodSystem.Data.TrialSequence(currentTrial,1) = S.GUI.Sequence_2(1);
        BpodSystem.Data.TrialSequence(currentTrial,2) = S.GUI.Sequence_2(2);
        BpodSystem.Data.TrialSequence(currentTrial,3) = S.GUI.Sequence_2(3);
        BpodSystem.Data.TrialSequence(currentTrial,4) = S.GUI.Sequence_2(4);
        BpodSystem.Data.TrialSequence(currentTrial,5) = S.GUI.Sequence_2(5);
        
    elseif TrialTypes(currentTrial) == 3
        Port_1 = num2str(S.GUI.Sequence_3(1));
        Port_2 = num2str(S.GUI.Sequence_3(2));
        Port_3 = num2str(S.GUI.Sequence_3(3));
        Port_4 = num2str(S.GUI.Sequence_3(4));
        %for saving out the sequence data
        BpodSystem.Data.TrialSequence(currentTrial,1) = S.GUI.Sequence_3(1);
        BpodSystem.Data.TrialSequence(currentTrial,2) = S.GUI.Sequence_3(2);
        BpodSystem.Data.TrialSequence(currentTrial,3) = S.GUI.Sequence_3(3);
        BpodSystem.Data.TrialSequence(currentTrial,4) = S.GUI.Sequence_3(4);
        disp(S.GUI.Sequence_3)
        
    else
        disp('error, trial type not recognised')
        return
    end
    
    % Update reward amounts and Set valve times
    %First the final reward
    R = GetValveTimes(S.GUI.FinalRewardAmount, [1 2 3 4 5 6 7 8]);
    if TrialTypes(currentTrial) == 1
        Reward_Valve_time = R(S.GUI.Sequence_1(4));
    elseif TrialTypes(currentTrial) == 2
        Reward_Valve_time = R(S.GUI.Sequence_2(4));
    elseif TrialTypes(currentTrial) == 3
        Reward_Valve_time = R(S.GUI.Sequence_3(4));
    else
        disp('error, trial type not recognised')
        return
    end
    %Then the intermediate rewards
    switch S.GUI.TrainingLevel
        case {1}
            IR = GetValveTimes(S.GUI.IntermediateRewardAmount, [1 2 3 4 5 6 7 8]);
            FirstValveTime = IR(str2num(Port_1));
            SecondValveTime = IR(str2num(Port_2));
            ThirdValveTime = IR(str2num(Port_3));
            BpodSystem.Data.sma_vars.SessionVariable_IRA1 = 0;
            BpodSystem.Data.sma_vars.SessionVariable_IRA2 = 0;
            BpodSystem.Data.sma_vars.SessionVariable_IRA3 = 0;
            
        case {2 5} %diminishing reward
            if currentTrial == 1 && S.GUI.UsePreviousSettings == 1 && S.GUI.TrainingLevel == 2
                BpodSystem.Data.sma_vars.SessionVariable_IRA1 = BpodSystem.Data.sma_vars.PrevIntermediateRewardAmount1; %set session varaible to GUI setting
                BpodSystem.Data.sma_vars.SessionVariable_IRA2 = BpodSystem.Data.sma_vars.PrevIntermediateRewardAmount2; %set session varaible to GUI setting
                BpodSystem.Data.sma_vars.SessionVariable_IRA3 = BpodSystem.Data.sma_vars.PrevIntermediateRewardAmount3; %set session varaible to GUI setting
                BpodSystem.Data.sma_vars.DiminishValve = 1; %set first port to be diminished first
                
            elseif currentTrial == 1 && S.GUI.TrainingLevel == 2
                BpodSystem.Data.sma_vars.SessionVariable_IRA1 = S.GUI.IntermediateRewardAmount; %set session varaible to GUI setting
                BpodSystem.Data.sma_vars.SessionVariable_IRA2 = S.GUI.IntermediateRewardAmount; %set session varaible to GUI setting
                BpodSystem.Data.sma_vars.SessionVariable_IRA3 = S.GUI.IntermediateRewardAmount; %set session varaible to GUI setting
                BpodSystem.Data.sma_vars.DiminishValve = 1; %set first port to be diminished first
                
            elseif currentTrial == 1 && S.GUI.TrainingLevel == 5 % set only custom pokes to diminish:
                
                if any(BpodSystem.Data.sma_vars.custom_ports == 1)
                    BpodSystem.Data.sma_vars.SessionVariable_IRA1 =S.GUI.IntermediateRewardAmount;
                else
                    BpodSystem.Data.sma_vars.SessionVariable_IRA1 =0;
                end
                if any(BpodSystem.Data.sma_vars.custom_ports == 2)
                    BpodSystem.Data.sma_vars.SessionVariable_IRA2 =S.GUI.IntermediateRewardAmount;
                else
                    BpodSystem.Data.sma_vars.SessionVariable_IRA2 =0;
                end
                if any(BpodSystem.Data.sma_vars.custom_ports == 3)
                    BpodSystem.Data.sma_vars.SessionVariable_IRA3 =S.GUI.IntermediateRewardAmount;
                else
                    BpodSystem.Data.sma_vars.SessionVariable_IRA3 =0;
                end
                if any(BpodSystem.Data.sma_vars.custom_ports == 4)
                    BpodSystem.Data.sma_vars.SessionVariable_IRA4 =S.GUI.IntermediateRewardAmount;
                else
                    BpodSystem.Data.sma_vars.SessionVariable_IRA4 =0;
                end
                
                BpodSystem.Data.sma_vars.DiminishValve = BpodSystem.Data.sma_vars.custom_ports(1); %set first port to be diminished first
                
            end
            
            
            %if last trial was correct, water reward is less than for previous trial for 1 port
            if BpodSystem.Data.sma_vars.DiminishValve == 1 && currentTrial > 2 && isnan(BpodSystem.Data.RawEvents.Trial{1, (currentTrial-2)}.States.Reward(1)) == 0
                BpodSystem.Data.sma_vars.SessionVariable_IRA1 = ReduceReward(BpodSystem.Data.sma_vars.SessionVariable_IRA1,S.GUI.CueDevalRate);
                if BpodSystem.Data.sma_vars.SessionVariable_IRA1 == 0
                    BpodSystem.Data.sma_vars.DiminishValve = BpodSystem.Data.sma_vars.DiminishValve+1;
                end
            elseif BpodSystem.Data.sma_vars.DiminishValve == 2 && currentTrial > 2 && isnan(BpodSystem.Data.RawEvents.Trial{1, (currentTrial-2)}.States.Reward(1)) == 0
                BpodSystem.Data.sma_vars.SessionVariable_IRA2 = ReduceReward(BpodSystem.Data.sma_vars.SessionVariable_IRA2,S.GUI.CueDevalRate);
                if BpodSystem.Data.sma_vars.SessionVariable_IRA2 == 0
                    BpodSystem.Data.sma_vars.DiminishValve = BpodSystem.Data.sma_vars.DiminishValve+1;
                end
            elseif BpodSystem.Data.sma_vars.DiminishValve == 3 && currentTrial > 2 && isnan(BpodSystem.Data.RawEvents.Trial{1, (currentTrial-2)}.States.Reward(1)) == 0
                BpodSystem.Data.sma_vars.SessionVariable_IRA3 = ReduceReward(BpodSystem.Data.sma_vars.SessionVariable_IRA3,S.GUI.CueDevalRate);
                if BpodSystem.Data.sma_vars.SessionVariable_IRA3 == 0
                    BpodSystem.Data.sma_vars.DiminishValve = BpodSystem.Data.sma_vars.DiminishValve+1;
                end 
            elseif BpodSystem.Data.sma_vars.DiminishValve > 3
                disp ('All ports have been fully diminished')
            end
            
            %Set valve time based on diminished rewards
            if BpodSystem.Data.sma_vars.SessionVariable_IRA1 == 0
                FirstValveTime = 0 ;
            else     
                IR = GetValveTimes(BpodSystem.Data.sma_vars.SessionVariable_IRA1, [1 2 3 4 5 6 7 8]);
                FirstValveTime = IR(str2num(Port_1));
            end
            if BpodSystem.Data.sma_vars.SessionVariable_IRA2 == 0
                SecondValveTime = 0;
            else     
                IR = GetValveTimes(BpodSystem.Data.sma_vars.SessionVariable_IRA2, [1 2 3 4 5 6 7 8]);
                SecondValveTime = IR(str2num(Port_1));
            end
            if BpodSystem.Data.sma_vars.SessionVariable_IRA3 == 0
                ThirdValveTime = 0; 
            else     
                IR = GetValveTimes(BpodSystem.Data.sma_vars.SessionVariable_IRA3, [1 2 3 4 5 6 7 8]);
                ThirdValveTime = IR(str2num(Port_1));
            end
           
        case {3 4 6}
            FirstValveTime = 0;
            SecondValveTime = 0;
            ThirdValveTime = 0;
            BpodSystem.Data.sma_vars.SessionVariable_IRA1 =0;
            BpodSystem.Data.sma_vars.SessionVariable_IRA2 =0;
            BpodSystem.Data.sma_vars.SessionVariable_IRA3 =0;
    
    end
    
    %Set the LedIntensity
    switch S.GUI.TrainingLevel
        case {1 }
            BpodSystem.Data.sma_vars.LedIntensity2 = S.GUI.LEDIntensity; BpodSystem.Data.sma_vars.LedIntensity3 = S.GUI.LEDIntensity; BpodSystem.Data.sma_vars.LedIntensity4 = S.GUI.LEDIntensity; 
            
        case {2 5} % diminishing brightness
            if currentTrial == 1 && S.GUI.UsePreviousSettings == 1 && S.GUI.TrainingLevel == 2
                BpodSystem.Data.sma_vars.LedIntensity2 = BpodSystem.Data.sma_vars.PrevLEDIntensity2; BpodSystem.Data.sma_vars.LedIntensity3 = BpodSystem.Data.sma_vars.PrevLEDIntensity3; BpodSystem.Data.sma_vars.LedIntensity4 = BpodSystem.Data.sma_vars.PrevLEDIntensity4; BpodSystem.Data.sma_vars.LedIntensity5 = BpodSystem.Data.sma_vars.PrevLEDIntensity5;
                BpodSystem.Data.sma_vars.Diminish_LED = 1;
            elseif currentTrial == 1 && S.GUI.TrainingLevel == 5 % if case 5 set dimish LED to start from port 4:
                BpodSystem.Data.sma_vars.LedIntensity2 = 0;BpodSystem.Data.sma_vars.LedIntensity3 = 0;BpodSystem.Data.sma_vars.LedIntensity4 = 0;BpodSystem.Data.sma_vars.LedIntensity5 = 0;
                if any(BpodSystem.Data.sma_vars.custom_ports == 2)
                    BpodSystem.Data.sma_vars.LedIntensity2 = S.GUI.LEDIntensity;
                end
                if any(BpodSystem.Data.sma_vars.custom_ports == 3)
                    BpodSystem.Data.sma_vars.LedIntensity3 = S.GUI.LEDIntensity;
                end
                if any(BpodSystem.Data.sma_vars.custom_ports == 4)
                    BpodSystem.Data.sma_vars.LedIntensity4 = S.GUI.LEDIntensity;
                end

               BpodSystem.Data.sma_vars.Diminish_LED = BpodSystem.Data.sma_vars.custom_ports(1);
               disp(BpodSystem.Data.sma_vars.Diminish_LED);
            elseif currentTrial == 1
               BpodSystem.Data.sma_vars.LedIntensity2 = S.GUI.LEDIntensity;BpodSystem.Data.sma_vars.LedIntensity3 = S.GUI.LEDIntensity;BpodSystem.Data.sma_vars.LedIntensity4 = S.GUI.LEDIntensity;BpodSystem.Data.sma_vars.LedIntensity5 = S.GUI.LEDIntensity;
               BpodSystem.Data.sma_vars.Diminish_LED = 1;
               disp(BpodSystem.Data.sma_vars.Diminish_LED);
            end
            
            if BpodSystem.Data.sma_vars.Diminish_LED == 1 && currentTrial > 2 && isnan(BpodSystem.Data.RawEvents.Trial{1, (currentTrial-2)}.States.Reward(1)) == 0
               BpodSystem.Data.sma_vars.LedIntensity2 = BpodSystem.Data.sma_vars.LedIntensity2 * S.GUI.CueDevalRate;
               BpodSystem.Data.sma_vars.LedIntensity2 %leave uncommented
                if BpodSystem.Data.sma_vars.LedIntensity2 < 10 % if the LED gets very small then switch it off
                   BpodSystem.Data.sma_vars.LedIntensity2 = 0;
                   disp('LED2 turned off');
                   BpodSystem.Data.sma_vars.Diminish_LED  = BpodSystem.Data.sma_vars.Diminish_LED + 1;
                   disp(BpodSystem.Data.sma_vars.Diminish_LED)
                end
                
            elseif BpodSystem.Data.sma_vars.Diminish_LED == 2 && currentTrial > 2 && isnan(BpodSystem.Data.RawEvents.Trial{1, (currentTrial-2)}.States.Reward(1)) == 0
                BpodSystem.Data.sma_vars.LedIntensity3 = BpodSystem.Data.sma_vars.LedIntensity3 * S.GUI.CueDevalRate;
                BpodSystem.Data.sma_vars.LedIntensity3 %leave uncommented
                if BpodSystem.Data.sma_vars.LedIntensity3 < 10 % if the  LED gets very small then switch it off
                    BpodSystem.Data.sma_vars.LedIntensity3 = 0;
                    disp('LED3 turned off');
                    BpodSystem.Data.sma_vars.Diminish_LED  = BpodSystem.Data.sma_vars.Diminish_LED + 1;
                    disp(BpodSystem.Data.sma_vars.Diminish_LED)
                end
                
            elseif BpodSystem.Data.sma_vars.Diminish_LED == 3 && currentTrial > 2 && isnan(BpodSystem.Data.RawEvents.Trial{1, (currentTrial-2)}.States.Reward(1)) == 0
                BpodSystem.Data.sma_vars.LedIntensity4 = BpodSystem.Data.sma_vars.LedIntensity4 * S.GUI.CueDevalRate;
                BpodSystem.Data.sma_vars.LedIntensity4 %leave uncommented
                if BpodSystem.Data.sma_vars.LedIntensity4 < 10 % if the LED gets very small then switch it off
                    BpodSystem.Data.sma_vars.LedIntensity4 = 0;
                    disp('LED4 turned off');
                    BpodSystem.Data.sma_vars.Diminish_LED  = BpodSystem.Data.sma_vars.Diminish_LED + 1;
                    disp(BpodSystem.Data.sma_vars.Diminish_LED)
                end
            end
        case {3} % shaping sound
            if S.GUI.WarmUp == 1 %if the warm up is turned on in the GUI:
                if currentTrial == 1
                    BpodSystem.Data.sma_vars.RewardTrialsCount = 0;
                end
                BpodSystem.Data.sma_vars.LedIntensity2 = S.GUI.LEDIntensity; BpodSystem.Data.sma_vars.LedIntensity3 = S.GUI.LEDIntensity; BpodSystem.Data.sma_vars.LedIntensity4 = S.GUI.LEDIntensity; BpodSystem.Data.sma_vars.LedIntensity5 = S.GUI.LEDIntensity;
                if  BpodSystem.Data.sma_vars.RewardTrialsCount <= S.GUI.Shaping1_WarmUpEnd && BpodSystem.Data.sma_vars.LedIntensity2 > 10 && currentTrial > 2 && isnan(BpodSystem.Data.RawEvents.Trial{1, (currentTrial-2)}.States.Reward(1)) == 0
                    BpodSystem.Data.sma_vars.LedIntensity2 = BpodSystem.Data.sma_vars.LedIntensity2*0.92;
                    BpodSystem.Data.sma_vars.LedIntensity3 = BpodSystem.Data.sma_vars.LedIntensity3*0.92;
                    BpodSystem.Data.sma_vars.LedIntensity4 = BpodSystem.Data.sma_vars.LedIntensity4*0.92;
                    BpodSystem.Data.sma_vars.RewardTrialsCount = BpodSystem.Data.sma_vars.RewardTrialsCount +1;
                elseif BpodSystem.Data.sma_vars.RewardTrialsCount > S.GUI.Shaping1_WarmUpEnd
                    BpodSystem.Data.sma_vars.LedIntensity2 = 0;
                    BpodSystem.Data.sma_vars.LedIntensity3 = 0;
                    BpodSystem.Data.sma_vars.LedIntensity4 = 0;
                    disp('Lights turned off');
                end
            else %if warm up is turned off then all lights are off from the start
                BpodSystem.Data.sma_vars.LedIntensity2 = 0; BpodSystem.Data.sma_vars.LedIntensity3 = 0; BpodSystem.Data.sma_vars.LedIntensity4 = 0;
            end
        case {4}
            BpodSystem.Data.sma_vars.LedIntensity2 = 0; BpodSystem.Data.sma_vars.LedIntensity3 = 0; BpodSystem.Data.sma_vars.LedIntensity4 = 0;
    end
    
    
    
    % set opto conditon
    
    if S.GUI.OptoStim == 1
        disp('opto trials coming up...')
        disp(BpodSystem.Data.SessionVariables.OptoStim(currentTrial:currentTrial+5));
    end
        
    
    switch BpodSystem.Data.SessionVariables.OptoStim(currentTrial)
        case 0 % No opto
            OptoCondition1 = 0;
            OptoCondition2 = 0;
            OptoCondition3 = 0;
            OptoCondition4 = 0;
            
        case 1 % Opto
            if S.GUI.StimPoke == 1
                OptoCondition1 = 1; % BNC number 2
                OptoCondition2 = 0;
                OptoCondition3 = 0;
                OptoCondition4 = 0;
            elseif S.GUI.StimPoke == 2
                OptoCondition1 = 0;
                OptoCondition2 = 1;
                OptoCondition3 = 0;
                OptoCondition4 = 0;
            elseif S.GUI.StimPoke == 3
                OptoCondition1 = 0;
                OptoCondition2 = 0;
                OptoCondition3 = 1;
                OptoCondition4 = 0;
            elseif S.GUI.StimPoke == 4
                OptoCondition1 = 0;
                OptoCondition2 = 0;
                OptoCondition3 = 0;
                OptoCondition4 = 1;
            end
    end
    
        
    %Set wrong ports for training stage 6 and for 4, this is used to play sounds even for incoreect pokes
    switch S.GUI.TrainingLevel
        case {4}
            Wrong1 = num2str(WrongPorts(str2num(Port_1),0,str2num(Port_1)));
            Wrong2 = num2str(WrongPorts(str2num(Port_2),0,str2num(Port_1)));
            Wrong3 = num2str(WrongPorts(str2num(Port_3),0,str2num(Port_1)));
            Wrong5 = num2str(WrongPorts(str2num(Port_4),0,str2num(Port_1)));
        case {6}
            Wrong1 = num2str(WrongPorts(str2num(Port_1),str2num(Port_1),str2num(Port_1)));
            Wrong2 = num2str(WrongPorts(str2num(Port_2),str2num(Port_1),str2num(Port_1)));
            Wrong3 = num2str(WrongPorts(str2num(Port_3),str2num(Port_2),str2num(Port_1)));
            Wrong5 = num2str(WrongPorts(str2num(Port_4),str2num(Port_3),str2num(Port_1)));
    end
    
    %find valave states for each port
    Valvestate1 = FindValveState(str2num(Port_1));
    Valvestate2 = FindValveState(str2num(Port_2));
    Valvestate3 = FindValveState(str2num(Port_3));
    Valvestate4 = FindValveState(str2num(Port_4));
    
    %Set state conditional outputs}
    First_Condition = {['PWM',Port_1], 100,'BNC1', 1}; % removed: 'SoftCode', TrialTypes(currentTrial)% trial specific Cue will always play but if cues are turned off it will play silence
    Second_Condition = {['PWM',Port_2], BpodSystem.Data.sma_vars.LedIntensity2};
    Third_Condition = {['PWM',Port_3], BpodSystem.Data.sma_vars.LedIntensity3};
    Fifth_Condition = {['PWM',Port_4], BpodSystem.Data.sma_vars.LedIntensity4 };
    
    switch S.GUI.TrainingLevel
        case {1 2}
            TrialManagerLagTime = S.GUI.LagTime1;
            if mod((currentTrial-1), 100) == 0
                TrialManagerLagTime = 2;
            end
                
        case {3 4 5}
            TrialManagerLagTime = S.GUI.LagTime2;
           if mod((currentTrial-1), 100) == 0
                TrialManagerLagTime = 2;
            end
    end
    
    %Reward outputs
    switch S.GUI.TrainingLevel
        case {1 2 5} % sounds for each poke, reward can be set to come from any port as well as final port 
            First_Reward_Output = {'SoftCode', 4, 'ValveState', Valvestate1,'BNC2', OptoCondition1 };
            Second_Reward_Output = {'SoftCode', 4, 'ValveState', Valvestate2,'BNC2', OptoCondition2 };
            Third_Reward_Output = {'SoftCode', 4, 'ValveState', Valvestate3,'BNC2', OptoCondition3 };
            Final_Reward_Output = {'SoftCode', 4, 'ValveState', Valvestate4};
        case {3 4} %Sounds for every correct poke, reward at end only 
            First_Reward_Output = {'SoftCode', 4,'BNC2', OptoCondition1 };
            Second_Reward_Output = {'SoftCode', 4,'BNC2', OptoCondition2 };
            Third_Reward_Output = {'SoftCode', 4,'BNC2', OptoCondition3 };
            Final_Reward_Output = {'SoftCode', 4, 'ValveState', Valvestate4};
    end
    
    %State conditions
    switch S.GUI.TrainingLevel
        case {1 2 3 5}
            Init_conditions = {['Port', Port_1, 'In'], 'InitialPokeValve'};
            port2_conditions = {['Port',Port_2, 'In'], 'SecondPokeValve', 'Tup', 'Punish'};
            port3_conditions = {['Port', Port_3, 'In'], 'ThirdPokeValve','Tup', 'Punish'};
            port4_conditions = {['Port', Port_4, 'In'], 'Reward','Tup', 'Punish'};
        case {4} %make it so that any poke = sound but not a state change
            Init_conditions = {['Port', Port_1, 'In'], 'InitialPokeValve'};
            port2_conditions = {['Port',Port_2, 'In'], 'SecondPokeValve',['Port',Port_1, 'In'], 'InitialPokeValve', 'Tup', 'Punish',['Port', Wrong2(1), 'In'],'InitialPokeValve',['Port', Wrong2(2), 'In'],'InitialPokeValve',['Port', Wrong2(3), 'In'],'InitialPokeValve',['Port', Wrong2(4), 'In'],'InitialPokeValve',['Port', Wrong2(5), 'In'],'InitialPokeValve',['Port', Wrong2(6), 'In'],'InitialPokeValve'};
            port3_conditions = {['Port', Port_3, 'In'], 'ThirdPokeValve',['Port',Port_1, 'In'], 'InitialPokeValve','Tup', 'Punish',['Port', Wrong3(1), 'In'],'SecondPokeValve',['Port', Wrong3(2), 'In'],'SecondPokeValve',['Port', Wrong3(3), 'In'],'SecondPokeValve',['Port', Wrong3(4), 'In'],'SecondPokeValve',['Port', Wrong3(5), 'In'],'SecondPokeValve',['Port', Wrong3(6), 'In'],'SecondPokeValve'};
            port4_conditions = {['Port', Port_4, 'In'], 'Reward',['Port',Port_1, 'In'], 'InitialPokeValve','Tup', 'Punish',['Port', Wrong5(1), 'In'],'ThirdPokeValve',['Port', Wrong5(2), 'In'],'ThirdPokeValve',['Port', Wrong5(3), 'In'],'ThirdPokeValve',['Port', Wrong5(4), 'In'],'ThirdPokeValve',['Port', Wrong5(5), 'In'],'ThirdPokeValve',['Port', Wrong5(6), 'In'],'ThirdPokeValve'};
    end
    
    switch S.GUI.TrainingLevel
        case {1 2 3 4 5}
            Punish_Output = {'SoftCode', 5}; % 'PWM1', 100,'PWM2', 100,'PWM3', 100,'PWM4', 100,'PWM5', 100,'PWM6', 100,'PWM7', 100, 'PWM8', 100, %all ports turn on and white noise sound
    end
   
    %% STATE MATRIX
    sma = NewStateMachine(); % Assemble state matrix

    sma = AddState(sma, 'Name', 'WaitForInitialPoke', ...
        'Timer',0,...
        'StateChangeConditions', Init_conditions,...
        'OutputActions', First_Condition);
    
    sma = AddState(sma, 'Name', 'InitialPokeValve', ...
        'Timer', FirstValveTime,...
        'StateChangeConditions', {'Tup', 'WaitForSecondPoke'},...
        'OutputActions', First_Reward_Output); %reward and reward noise
    
    sma = AddState(sma, 'Name', 'WaitForSecondPoke', ...
        'Timer', InterPoke_TimeOut,...
        'StateChangeConditions', port2_conditions,...
        'OutputActions', Second_Condition);
    sma = AddState(sma, 'Name', 'SecondPokeValve', ...
        'Timer', SecondValveTime,...
        'StateChangeConditions', {'Tup', 'WaitForThirdPoke'},...
        'OutputActions', Second_Reward_Output ); %reward and reward noise
    
    sma = AddState(sma, 'Name', 'WaitForThirdPoke', ...
        'Timer', InterPoke_TimeOut,...
        'StateChangeConditions', port3_conditions,...
        'OutputActions', Third_Condition);
    sma = AddState(sma, 'Name', 'ThirdPokeValve', ...
        'Timer', ThirdValveTime,...
        'StateChangeConditions', {'Tup', 'WaitForFourthPoke'},...
        'OutputActions', Third_Reward_Output ); %reward and reward noise
   
    
    sma = AddState(sma, 'Name', 'WaitForFourthPoke', ...
        'Timer', InterPoke_TimeOut,...
        'StateChangeConditions', port4_conditions,...
        'OutputActions', Fifth_Condition);
    sma = AddState(sma, 'Name', 'Reward', ...
        'Timer', Reward_Valve_time,...
        'StateChangeConditions', {'Tup', 'ExitSeq'},...
        'OutputActions', Final_Reward_Output); %reward and reward noise
    
    sma = AddState(sma, 'Name', 'Punish', ...
        'Timer',  S.GUI.PunishTimeoutDuration,...
        'StateChangeConditions', {'Tup', 'ExitSeq'},...
        'OutputActions', Punish_Output); %All lights on and punishnoise
    
    sma = AddState(sma, 'Name', 'ExitSeq', ...
        'Timer',  TrialManagerLagTime,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {});
    
    
end
