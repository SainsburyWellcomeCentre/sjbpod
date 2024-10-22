%{
---------------------------------------------------------------------------
ClockTask.m
MAIN PROTOCOL
2020
Emmett James Thompson
Sainsbury Wellcome Center
---------------------------------------------------------------------------
mice must folow the light and are rewarded onn the second poke of short 2
poke sequences. These transitions are in blocks and change to a different
direction vector once the mouse has completed a block
%}


%% Make BpodSystem object
global BpodSystem S

beep('off'); % native matlab error sounds OFF


%% GUI Params
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S

if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    
    %Task Features
    S.GUI.TrainingLevel = 1; % Default Training Level
    S.GUIMeta.TrainingLevel.Style = 'popupmenu'; % the GUIMeta field is used by the ParameterGUI plugin to customize UI objects.
    S.GUIMeta.TrainingLevel.String = {'WaterGuided', 'FinalTask'};
    
    S.GUI.Number_of_Sequences = 9; %
    
    S.GUI.BlockSize = 15;
    
    S.GUI.ResponseWindow = 30; %s
    
    S.GUI.OptoStim = 0; % off by default
    S.GUIMeta.OptoStim.Style = 'checkbox';
    
    S.GUI.RewardSound = 1; %default is on
    S.GUIMeta.RewardSound.Style = 'checkbox';
    
    S.GUI.IntermediateReward = 1.8;
    S.GUI.FinalReward =  1.8;
    
    %Sequences
    S.GUI.Sequence1 = 15;
    S.GUI.Sequence2 = 16;
    S.GUI.Sequence3 = 21;
    S.GUI.Sequence4 = 25;
    S.GUI.Sequence5 = 26;
    S.GUI.Sequence6 = 27;
    S.GUI.Sequence7 = 23;
    S.GUI.Sequence8 = 36;
    S.GUI.Sequence9 = 37;

    %lag times to allow enough time for trial manager to fully compute sma
    S.GUI.LagTime1 = 0.4;
    S.GUI.LagTime2 = 0.3; % less time needed once there is no lights of cue deval as sma is created faster
    
    %Reward/Punihsment
    S.GUI.RewardDelay = 0; %s
    
    %Sound Feautres
    S.GUI.RewardSoundAmp = 4;
    S.GUI.RewardSoundDuration = 0.5;

    %Stim Feautres
    S.GUI.StimPoke = 1; % poke number that triggers stim, # 
    S.GUI.PulsePower = 12; % power in V
    S.GUI.OptoChance = 0.15; % % of trials which will have stimulation
    S.GUI.PulseDuration = 0.005; % Set output channel to produce 5ms pulses
    S.GUI.PulseInterval = 0.045; % Set pulse interval to produce 20Hz pulses
    S.GUI.TrainDuration = 0.5; % Set pulse train to last 0.5 seconds
    
    S.GUIPanels.Task = {'TrainingLevel','Number_of_Sequences', 'BlockSize','IntermediateReward','FinalReward','OptoStim','ResponseWindow'}; % GUIPanels organize the parameters into groups.
    S.GUIPanels.Sequences = {'Sequence1','Sequence2','Sequence3','Sequence4','Sequence5','Sequence6','Sequence7','Sequence8','Sequence9'};
    S.GUIPanels.Settings = {'RewardDelay', 'LagTime1', 'LagTime2'};
    S.GUIPanels.Sound = {'RewardSound','RewardSoundAmp','RewardSoundDuration'};
    S.GUIPanels.Stim_Settings = {'StimPoke','OptoChance','PulsePower', 'PulseDuration','PulseInterval', 'TrainDuration'};
    
    S.GUITabs.Task = {'Task'};
    S.GUITabs.Sequences = {'Sequences'};
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



%% barcode pulse % Hardcoded to output on BNC 2

ttl_sma = protocol_init_ttl(S, 'LsLsLs');
SendStateMatrix(ttl_sma);
RunStateMatrix;

%% Create trial manager object

TrialManager = TrialManagerObject;


%% Define trials
BpodSystem.Data.MaxTrials = 2000;

% make block structure:
TrialTypes = [];
for type = 1:S.GUI.Number_of_Sequences
     new_types = repmat(type,1,S.GUI.BlockSize);
     TrialTypes = cat(2,TrialTypes,new_types);
end
     
% repeat block structure so that mouse can keep going after finsihing full task
TrialTypes = repmat(TrialTypes,1,400);

TrialTypes = TrialTypes(1:BpodSystem.Data.MaxTrials);

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

%make reward sound
if S.GUI.RewardSound == 1
    srate=20000; % sampling rate
    freq1=5;
    dur1=1.5*1000;
    RewardSound = S.GUI.RewardSoundAmp*(MakeBupperSwoop(srate,0, freq1 , freq1 , dur1/2 , dur1/2,0,0.1));
else
    RewardSound = zeros(1,sampRate*S.GUI.RewardSoundDuration); %No noise but will still play the 'sound'
end

%Initiate sound server and load sounds:
PsychToolboxSoundServer('init');
PsychToolboxSoundServer('Load', 1, RewardSound);

BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';

%% Initialize plots

MultiFigureEJT = figure('Position', [10 10 1000 600],'name',SubjectName,'numbertitle','off', 'MenuBar', 'none', 'Resize', 'on');

%Create an object that is called on cleanup to save stuff
[filepath,name,~] = fileparts(BpodSystem.Path.CurrentDataFile);
finishup = onCleanup(@() CleanupFunctionAutoSeq(MultiFigureEJT, filepath, name));

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
S.GUI.Sequence1 = num2str(S.GUI.Sequence1)-'0';
S.GUI.Sequence2 = num2str(S.GUI.Sequence2)-'0';
S.GUI.Sequence3 = num2str(S.GUI.Sequence3)-'0';
S.GUI.Sequence4 = num2str(S.GUI.Sequence4)-'0';
S.GUI.Sequence5 = num2str(S.GUI.Sequence5)-'0';
S.GUI.Sequence6 = num2str(S.GUI.Sequence6)-'0';
S.GUI.Sequence7 = num2str(S.GUI.Sequence7)-'0';
S.GUI.Sequence8 = num2str(S.GUI.Sequence8)-'0';
S.GUI.Sequence9 = num2str(S.GUI.Sequence9)-'0';

BpodSystem.Data.SessionVariables.Full_SequenceSet = [S.GUI.Sequence1,S.GUI.Sequence2,S.GUI.Sequence3,S.GUI.Sequence4,S.GUI.Sequence5,S.GUI.Sequence6,S.GUI.Sequence7,S.GUI.Sequence8,S.GUI.Sequence9];

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
        BpodSystem.Data.SessionVariables.LEDIntensitys.port1(currentTrial) = BpodSystem.Data.sma_vars.LedIntensity1;
        BpodSystem.Data.SessionVariables.LEDIntensitys.port2(currentTrial) = BpodSystem.Data.sma_vars.LedIntensity2;
        BpodSystem.Data.SessionVariables.RewardAmount.port1(currentTrial) = BpodSystem.Data.sma_vars.FirstRewardAmount;
        BpodSystem.Data.SessionVariables.RewardAmount.port2(currentTrial) = BpodSystem.Data.sma_vars.SecondRewardAmount;
        
        if currentTrial == 1
            UpdateOnlinePlotDirVectors(S.GUI,BpodSystem.Data,BpodSystem.GUIData.SubjectName,TrialTypes(currentTrial),'Init',MultiFigureEJT); %update online plot
        else
            UpdateOnlinePlotDirVectors(S.GUI,BpodSystem.Data,BpodSystem.GUIData.SubjectName,TrialTypes(currentTrial),'Update',MultiFigureEJT); %update online plot
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

    %Set the port order based on the trial type and the GUI settings
    [Port_1,Port_2] = UpdateCurrentSeqeunce_DirectionVecs(TrialTypes(currentTrial),BpodSystem.Data.SessionVariables.Full_SequenceSet);
        
%     BpodSystem.Data.TrialSequence(currentTrial,1) = [Port_1,Port_2];

    %Reward_amounts
    BpodSystem.Data.sma_vars.FirstRewardAmount = S.GUI.IntermediateReward;
    BpodSystem.Data.sma_vars.SecondRewardAmount = S.GUI.FinalReward;
    
    FirstValveTime = DetermineValveTime(BpodSystem.Data.sma_vars.FirstRewardAmount, Port_1);
    SecondValveTime = DetermineValveTime(BpodSystem.Data.sma_vars.SecondRewardAmount, Port_2);

    %Set the LedIntensity
    BpodSystem.Data.sma_vars.LedIntensity1 = 80;
    BpodSystem.Data.sma_vars.LedIntensity2 = 80;


    %Set interpoke timeout limit
    BpodSystem.Data.SessionVariables.ResponseWindow = S.GUI.ResponseWindow;
    InterPoke_TimeOut = BpodSystem.Data.SessionVariables.ResponseWindow;
    % set opto conditon 
    if S.GUI.OptoStim == 1
        disp('opto trials coming up...')
        disp(BpodSystem.Data.SessionVariables.OptoStim(currentTrial:currentTrial+5));
    end
      
    switch BpodSystem.Data.SessionVariables.OptoStim(currentTrial)
        case 0 % No opto
            OptoCondition1 = 0;
            OptoCondition2 = 0;

        case 1 % Opto
            if S.GUI.StimPoke == 1
                OptoCondition1 = 1; % BNC number 2
                OptoCondition2 = 0;
            elseif S.GUI.StimPoke == 2
                OptoCondition1 = 0;
                OptoCondition2 = 1;
            end
    end
    
    %find valve states for each port
    Valvestate1 = FindValveState(str2num(Port_1));
    Valvestate2 = FindValveState(str2num(Port_2));
    
    %Set state conditional outputs}
    First_Condition = {['PWM',Port_1], BpodSystem.Data.sma_vars.LedIntensity1,'BNC1', 1}; % removed: 'SoftCode', TrialTypes(currentTrial)% trial specific Cue will always play but if cues are turned off it will play silence
    Second_Condition = {['PWM',Port_2], BpodSystem.Data.sma_vars.LedIntensity2};

    TrialManagerLagTime = S.GUI.LagTime1;
    if mod((currentTrial-1), 100) == 0
        TrialManagerLagTime = 2;
    end

    
    %Reward outputs
    if S.GUI.TrainingLevel == 1 % water guided
         % sounds for each poke, reward can be set to come from any port as well as final port 
        First_Reward_Output = {'SoftCode', 1, 'ValveState', Valvestate1,'BNC2', OptoCondition1 };
        Second_Reward_Output = {'SoftCode', 1, 'ValveState', Valvestate2,'BNC2', OptoCondition2 };
    else % no water
        First_Reward_Output = {'SoftCode', 1,'BNC2', OptoCondition1 };
        Second_Reward_Output = {'SoftCode', 1,'ValveState', Valvestate2,'BNC2', OptoCondition2 };
    end
    
    %State conditions
    %correct pokes only cause a reward noise  
    Init_conditions = {['Port', Port_1, 'In'], 'InitialPokeValve'};
    port2_conditions = {['Port',Port_2, 'In'], 'Reward', 'Tup', 'Punish'};

    % if optostim tr to prevent repeated stim through looping by making timeout much shorter 
    switch BpodSystem.Data.SessionVariables.OptoStim(currentTrial)
        case {1}
            InterPoke_TimeOut = 1.3;
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
    sma = AddState(sma, 'Name', 'Reward', ...
        'Timer', SecondValveTime,...
        'StateChangeConditions', {'Tup', 'ExitSeq'},...
        'OutputActions', Second_Reward_Output ); %reward and reward noise
    
   sma = AddState(sma, 'Name', 'Punish', ...
        'Timer',  0,...
        'StateChangeConditions', {'Tup', 'ExitSeq'},...
        'OutputActions', {}); %All lights on and punishnoise
    
    sma = AddState(sma, 'Name', 'ExitSeq', ...
        'Timer',  TrialManagerLagTime,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {});
    
    
end