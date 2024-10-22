function Excit_opsin_20Hz_tag

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

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    BpodSystem.Path.CurrentProtocol = mfilename;
    %S.GUI.OptoFreq = 20; % Hz
    %S.GUI.OptoStimDuration = 1; % seconds 
    S.GUI.BreakBetweenStimTime = 10; % seconds
    S.GUI.MaxTrials = 200;
end

% Initialize parameter GUI plugin
BpodParameterGUI('init', S);

BpodSystem.Status.Pause = 1;
HandlePauseCondition;
S = BpodParameterGUI_with_tabs('sync', S);

save_Trial_Settings(['inhib_stim'], S);

%% Pulse Pal initialization
% Blank Pulse Pal Parameters

S.InitialPulsePalParameters = struct;
load PulsePal_ParameterMatrix;
try
    ProgramPulsePal(ParameterMatrix);
    S.InitialPulsePalParameters = ParameterMatrix;
catch
    disp('Pulsepal not connected')
end
%% Define stimuli and send to sound server
S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI_with_tabs plugin


%% Main trial loop
for currentTrial = 1:S.GUI.MaxTrials
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI_with_tabs plugin 
    
%% Pulsepal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ProgramPulsePalParam(1, 'Phase1Voltage', 5); % Set output channel 1 to produce 5V pulses
ProgramPulsePalParam(1, 'Phase1Duration', 0.2); % Set output channel 1 to produce 5ms pulses
try
    ProgramPulsePalParam(1, 'InterPulseInterval', 0.1); % Set pulse interval to produce 20Hz pulses
catch
    ProgramPulsePalParam(1, 'InterPulseInterval', 0.01);
    disp('IPI = 0.015s')
    S.GUI.OptoFreq = 1/0.015;
end
ProgramPulsePalParam(1, 'PulseTrainDuration', 0.3); % Set pulse train to last 0.5 seconds
ProgramPulsePalParam(1, 'TriggerMode', 0); % Set output channel 1 to respond to trigger ch 1


%% Assemble State matrix
 	sma = NewStateMatrix();
    %Pre task states
     sma = AddState(sma, 'Name','PhotostimOn',...
        'Timer', 0.3,...s
        'StateChangeConditions',{'Tup','InterStimInterval'},...
        'OutputActions',{'BNCState', 2});%outputs to BNC 2 to drive pulse pal
    sma = AddState(sma, 'Name','InterStimInterval',...
        'Timer', S.GUI.BreakBetweenStimTime,...
        'StateChangeConditions',{'Tup','exit'},...
        'OutputActions',{'BNCState', 0});
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
%% Save
if ~isempty(fieldnames(RawEvents))                                          % If trial data was returned
    BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);            % Computes trial events from raw data
    [~,git_hash_string] = system('git rev-parse HEAD');
    BpodSystem.Data.GitHash = git_hash_string;
    SaveBpodSessionData;  % Saves the field BpodSystem.Data to the current data file
end

HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.

if BpodSystem.Status.BeingUsed == 0
    return
end
end
end


