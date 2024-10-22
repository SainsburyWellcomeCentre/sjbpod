%{
---------------------------------------------------------------------------
This is an example of how to use Bpod with PulsePal. It contains minimal
code to show some of the capabilities, and you are expected to populate the
script with more functionalities to adjust it to your desired behavioural
task.
The task coded here is that whenever the animal pokes in a port, the
light of the laser is turned on.
You might want to look into other protocols to get ideas once you want to
change something.
Try adding water reward for example.

See https://sites.google.com/site/bpoddocumentation/
---------------------------------------------------------------------------
%}


%% Definition of the protocol as a function
function SelfStimulation_Minimal

%Check if PulsePal is connected 
try 
    evalin('base', 'PulsePalSystem;') 
catch
    try
        PulsePal;
    catch
        disp('Pulsepal not connected')
    end
end

global BpodSystem

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    
    S.GUI.RewardAmount = 5; %ul
    S.GUI.LaserSide = 2; % only one port, but you could add more
    S.GUI.LaserDuration = 5;
        
    S.GUI.TrainingLevel = 1; % Only one training level by default, but you can include more
    S.GUIMeta.TrainingLevel.Style = 'popupmenu'; % the GUIMeta field is used by the ParameterGUI plugin to customize UI objects.
    S.GUIMeta.TrainingLevel.String = {'LaserStimulation'}; %Write here more levels if you want

end

% Initialize parameter GUI plugin
BpodParameterGUI('init', S);
% TotalRewardDisplay('init');

%% Define trials
MaxTrials = 1000; %Number of maximum trials
% LaserSide refers to which condition (left or right port) will trigger the
% laser. We will populate all trials with one case, but this can change
% along the experiment depending on the behaviour of the animals, for
% example.
switch S.GUI.LaserSide
    case 2
        TrialTypes = 2*ones(1,MaxTrials);
end
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.

%% Initialize plots if you want to use them. You are encuraged to do it
BpodSystem.ProtocolFigures.SideOutcomePlotFig = figure('Position', [200 200 1000 300],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.SideOutcomePlot = axes('Position', [.075 .3 .89 .6]);
OptoStim = zeros(1,MaxTrials); % In case you want to plot other stuff, dive into the function
SideOutcomePlotMod(BpodSystem.GUIHandles.SideOutcomePlot,'init',2-TrialTypes,OptoStim);

%% Initialize pulsepal
S.InitialPulsePalParameters = struct;
load PulsePal_ParameterMatrix;
try
    ProgramPulsePal(ParameterMatrix);
    S.InitialPulsePalParameters = ParameterMatrix;
catch
    disp('Pulsepal parameters failed to load')
end


%% Main trial loop
for currentTrial = 1:MaxTrials
    
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    
    %% Pulsepal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    try
        ProgramPulsePalParam(1, 'Phase1Duration', .5)%S.GUI.Phase1Duration);
        ProgramPulsePalParam(1, 'Phase2Duration', .5)%  S.GUI.Phase2Duration);
        ProgramPulsePalParam(1, 'Phase1Voltage', 5)%S.GUI.Phase1Voltage);
        ProgramPulsePalParam(1, 'Phase2Voltage', -5)%; S.GUI.Phase2Voltage);
        ProgramPulsePalParam(1, 'InterPulseInterval',.001)% S.GUI.PulseInterval);
        ProgramPulsePalParam(1, 'PulseTrainDelay', 0)% S.GUI.PulseTrainDelay);
        ProgramPulsePalParam(1, 'InterPhaseInterval', .005)% S.GUI.InterPhaseInterval);
        ProgramPulsePalParam(1, 'PulseTrainDuration', 2)% S.GUI.PulseTrainDuration);
        ProgramPulsePalParam(1, 12, 1)%S.GUI.LinkedToTriggerCH1);
        ProgramPulsePalParam(1, 13, 0)%  S.GUI.LinkedToTriggerCH2);
    catch
        disp('Pulsepal specific parameters failed to load')

    end
    
    % With more complex cases you could select different arguments (see
    % below)
    if S.GUI.LaserSide==2 % right port
        laser_arg = {'Port3In','Laser','Port1In','Punish','Tup','exit'}; %exit finishes the trial
    end
    
    sma = NewStateMatrix(); % Assemble state matrix
    switch S.GUI.TrainingLevel % Include more if you want
        case 1 % Self-Stimulation
            
            %TrialStart
            sma = AddState(sma, 'Name', 'TrialStart', ... % Name of state
                'Timer', 0,... % Duration of the timer of the state
                'StateChangeConditions', {'Tup', 'WaitForResponse'},... %state conditions go in pairs. If the condition happens, go to the state
                'OutputActions', {});
            
            %WaitForResponse
            sma = AddState(sma, 'Name', 'WaitForResponse', ...
                'Timer', 30,...
                'StateChangeConditions', laser_arg,...
                'OutputActions', {'PWM1', 0.05, 'PWM3', 0.05}); % this is how you turn on LEDs
            
            %Laser
            sma = AddState(sma, 'Name', 'Laser', ...
                'Timer', S.GUI.LaserDuration,...
                'StateChangeConditions', {'Tup', 'exit'},...
                'OutputActions', {'BNCState', 2}); % this is how you turn on the laser
            
            %'Punish' finishes the trial after a 3 seconds delay
            sma = AddState(sma, 'Name', 'Punish', ...
                'Timer', 3, ...
                'StateChangeConditions', {'Tup', 'exit'}, ...
                'OutputActions', {}); %think about outputing something
    end
    
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    
    
    %% Get events from the system and save the data
    
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        BpodSystem.Data.TrialTypes(currentTrial) = TrialTypes(currentTrial); % Adds the trial type of the current trial to data
        BpodSystem.Data.Outcomes(currentTrial) = CalculateOutcome(BpodSystem.Data.RawEvents.Trial{currentTrial}.States); %outcome of trial

       if ~isnan(BpodSystem.Data.RawEvents.Trial{currentTrial}.States.Laser(1))
           BpodSystem.Data.Outcomes(currentTrial) = 2;
       else
           BpodSystem.Data.Outcomes(currentTrial) = 0;
       end
       
       % Update plot
       SideOutcomePlotMod(BpodSystem.GUIHandles.SideOutcomePlot,'update',BpodSystem.Data.nTrials+1,2-TrialTypes,BpodSystem.Data.Outcomes);

       
       SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0
        return
    end
end

function Outcome = CalculateOutcome(State)
    if ~isnan(State.Laser(1))
        Outcome = 1;
    elseif ~isnan(State.Punish(1))
        Outcome = 0;
    elseif ~isnan(State.EarlyWithdrawal(1))
        Outcome = 2;
    else
        Outcome = 3;
    end