%{
---------------------------------------------------------------------------
SleepVideo_TTLPulse.m
MAIN PROTOCOL
2021
Emmett James Thompson
Sainsbury Wellcome Center
---------------------------------------------------------------------------
Start Barcode pulse and then one 1s pulse every 60s 

%}


%% Make BpodSystem object
global BpodSystem S

beep('off'); % native matlab error sounds OFF

%% GUI Params
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S

if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    
    %Task Features
    S.GUI.SessionType = 2; % Default PostSleep
    S.GUIMeta.SessionType.Style = 'popupmenu'; % the GUIMeta field is used by the ParameterGUI plugin to customize UI objects.
    S.GUIMeta.SessionType.String = {'PreTask_Sleep','PostTask_Sleep'};
    S.GUI.pulse_duration = 1; %s
    S.GUI.wait_duration = 29; %s
 
%     S.GUIPanels.Settings = {'SessionType','pulse_duration','wait_duration'}; % GUIPanels organize the parameters into groups.
% 
%     S.GUITabs.Settings = {'Task'};
end


% Initialize parameter GUI plugin
BpodParameterGUI_with_tabs('init', S);
set(BpodSystem.ProtocolFigures.ParameterGUI, 'Position', [0 300 500, 300 ]);

% Pause to allow user to change GUI parameters
BpodSystem.Status.Pause=1;
HandlePauseCondition;

% Sync S to the changed GUI parameters
S = BpodParameterGUI('sync', S);



%% barcode pulse % Hardcoded to output on BNC 2
if S.GUI.SessionType == 1 
    Pulse = 'ssLsss';
else
    Pulse = 'LsLsss';
end

ttl_sma = protocol_init_ttl(S, Pulse);
SendStateMatrix(ttl_sma);
RunStateMatrix;

%% Create trial manager object
TrialManager = TrialManagerObject;


%% Define trials
BpodSystem.Data.MaxTrials = 2000;

%% Setup Trial manager for parallel (speedy) initiation 

sma = PrepareStateMachine(S); % Prepare state machine for trial 1 with empty "current events" variable
TrialManager.startTrial(sma); % Sends & starts running first trial's state machine. A MATLAB timer object updates the 
                              % console UI, while code below proceeds in parallel.
                                     
%% Main trial loop
for currentTrial = 1:BpodSystem.Data.MaxTrials
    
    currentTrialEvents = TrialManager.getCurrentEvents({'state_2'}); 
                                       % Hangs here until Bpod enters one of the listed trigger states, 
                                       % then returns current trial's states visited + events captured to this point
    if BpodSystem.Status.BeingUsed == 0; return; end % If user hit console "stop" button, end session 
    [sma, S] = PrepareStateMachine(S); % Prepare next state machine.
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
        
        if mod((currentTrial-1), 20) == 0
            SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
            disp('Data saved');
        end
    end
end

%% Trial specific Matrix outputs

function [sma, S] = PrepareStateMachine(S)
    
   
    %% STATE MATRIX
    sma = NewStateMachine(); % Assemble state matrix
    
    
    sma = AddState(sma, 'Name', 'state_1',...
        'Timer', S.GUI.pulse_duration,...
        'StateChangeConditions', {'Tup', 'state_2'},...
        'OutputActions', {'BNC1', 1,'BNC2',1}...
        );
    
    sma = AddState(sma, 'Name', 'state_2',...
        'Timer', S.GUI.wait_duration,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {}...
        );

    
end