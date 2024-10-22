%{
---------------------------------------------------------------------------
Sound_Presentation.m
2019/03/03
Hernando Martinez Vergara
Stephenson-Jones Lab
Sainsbury Wellcome Center
---------------------------------------------------------------------------
%}
%{
---------------------------------------------------------------------------
Display sounds of different frequencies to calculate the tuning of cells.
Sends BNC outputs to align to ephys data
---------------------------------------------------------------------------

TODO:

- Change stimuli to cloud of tones that I would use?? Discuss with T and M
%}


%% Definition of the protocol as a function
function Sound_And_Stimulation

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

% This makes the BpodSystem object visible in the the MyProtocol function's workspace
global BpodSystem S
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    Sound_And_Stimulation_GUIParameters();
end

S.LowFreq = S.GUI.LowFrequency;
S.HighFreq = S.GUI.HighFrequency;
S.Amplitude = S.GUI.SoundAmplitude;
S.SoundDuration = S.GUI.SoundDuration;
S.Silence = S.GUI.Silence;
% Initialize parameter GUI plugin
BpodParameterGUI_with_tabs('init', S);
%set(BpodSystem.ProtocolFigures.ParameterGUI, 'Position', [40 200 500 500]);

%% Pause to get GUI parameters
BpodSystem.Status.Pause=1;
HandlePauseCondition;
% Sync S to the changed GUI parameters
S = BpodParameterGUI_with_tabs('sync', S);

%% Figure
BpodSystem.ProtocolFigures.SoundFigure = figure;

%% Create sounds and load them
% Define stable sound parameters: 
sampRate = 192000;
S.Frequencies = logspace(log10(S.LowFreq),log10(S.HighFreq),10);
duration = S.SoundDuration;
rampTime = 0.05;
time=0:1/sampRate:duration-1/sampRate;
% For striatum
%amplitude = 0.05;
% For cortex
%amplitude = 0.02;

%Amplitude modulation
ModFreq = 10;
AmpMOD = cos((time * 2 * pi * ModFreq))*0.2 + 0.8;

PsychToolboxSoundServer('init');
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';
MySounds = [ ];
for SoundID = 1:size(S.Frequencies,2)
    meanFreq = S.Frequencies(1,SoundID);
    SoundToPresent = AmpMOD.*ToneGenerator(time, rampTime, S.Amplitude, meanFreq);
    PsychToolboxSoundServer('Load', SoundID, SoundToPresent);
    disp('Sound loaded')
    MySounds = [MySounds; SoundToPresent];
end

% Create trials defined by a sequence of tones presentations. Loop 10 times
% through the sequence of tones
SoundIDLoop = repmat(1:size(S.Frequencies,2), 1, 10);

%% Initialize pulsepal
OptoStim = zeros(1,size(SoundIDLoop, 2));
switch S.GUI.OptoStim
    case 1 %no optostimulation
        disp('No optostimulation selected')
    case 2
        % Determine the optostimulation trials
        for tr=1:size(SoundIDLoop, 2)
            if rand(1) < S.GUI.OptoChance
                OptoStim(tr) = 1;
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

        try
            ProgramPulsePalParam(1, 'Phase1Voltage', 5); % Set output channel 1 to produce 5V pulses
            ProgramPulsePalParam(1, 'Phase1Duration', S.GUI.PulseDuration); % Set output channel 1 to produce Xms pulses
            ProgramPulsePalParam(1, 'InterPulseInterval', S.GUI.PulseInterval); % Set pulse interval to produce XHz pulses
            ProgramPulsePalParam(1, 'PulseTrainDuration', S.GUI.TrainDuration); % Set pulse train to last X seconds
            %The following fails to load
            %ProgramPulsePalParam(1, 'LinkedToTriggerCH1', 1); % Set output channel 1 to respond to trigger ch 1
            ProgramPulsePalParam(1, 'TriggerMode', 0); % Set trigger channel 1 to toggle mode
        catch
            disp('Pulsepal specific parameters failed to load')
        end
end
    

%%
% loop through the trials
for currentTrial=1:size(SoundIDLoop, 2)
    
    OptionalStim = OptoStim(currentTrial);

    disp(strcat('SoundID: ', num2str(SoundIDLoop(currentTrial)), '. OptionalStim: ', num2str(OptionalStim)))
    UpdateSoundSpectPlot(BpodSystem.ProtocolFigures.SoundFigure, MySounds(SoundIDLoop(currentTrial),:));
    %% Assemble state matrix
    sma = NewStateMachine();            
    sma = AddState(sma, 'Name', 'SoundPresentation', ...
        'Timer', duration, ...
        'StateChangeConditions', {'Tup', 'Silence1'}, ...
        'OutputActions', {'SoftCode', SoundIDLoop(currentTrial), 'BNCState', 2});
    sma = AddState(sma, 'Name', 'Silence1', ...
        'Timer', S.Silence/2, ...
        'StateChangeConditions', {'Tup', 'Stimulation'}, ...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'Stimulation', ...
        'Timer', S.GUI.TrainDuration, ...
        'StateChangeConditions', {'Tup', 'Silence2'}, ...
        'OutputActions', {'BNCState', OptionalStim});    
    sma = AddState(sma, 'Name', 'Silence2', ...
        'Timer', S.Silence/2, ...
        'StateChangeConditions', {'Tup', 'exit'}, ...
        'OutputActions', {});
    
    SendStateMachine(sma);    
    RawEvents = RunStateMachine;

    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        BpodSystem.Data.Stimulus{currentTrial} = SoundIDLoop(currentTrial); %save the sound ID
        SaveBpodSessionData;
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0 %stop button pressed        
        PsychToolboxSoundServer('close'); % Close sound server
        return
    end   
end


function UpdateSoundSpectPlot(AxesHandle, sound)
    figure(AxesHandle);
    spectrogram(sound,1000,800,2000,192000,'yaxis') % Display the spectrogram
    ylim([0 60]);
    %legend('off');
    %colorbar('off');