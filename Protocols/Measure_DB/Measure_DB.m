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
Display sounds of different amplitudes to measure the DB.

once this is done, do the following:
x = linspace(0.005, 0.075, 8) % or whatever your S.Amplitude is
y = [... ...] % put the measured values
dBcalib = [x; y]'
save('...\Bpod Local\Calibration Files\SoundCalibrationHMV.mat', 'dBcalib');
---------------------------------------------------------------------------

%}


%% Definition of the protocol as a function
function Measure_DB
% This makes the BpodSystem object visible in the the MyProtocol function's workspace
global BpodSystem
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S

BpodSystem.ProtocolFigures.SoundFigure = figure;

%% Create sounds and load them

%% Define stable sound parameters: 
sampRate = 192000;
S.Frequency = 13000;
duration = 1;
rampTime = 0.05;
time=0:1/sampRate:duration-1/sampRate;
S.Amplitudes = linspace(0.005, 0.075, 8);


PsychToolboxSoundServer('init');
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';
%MySounds = [ ];

for SoundID = 1:size(S.Amplitudes,2)
    ampli = S.Amplitudes(1,SoundID);
    disp(ampli)
    SoundToPresent = ToneGenerator(time, rampTime, ampli, S.Frequency);
    %PsychToolboxSoundServer('Load', SoundIDcounter, SoundToPresent);
    if SoundID == 1
        MySounds = SoundToPresent;
    else
        MySounds = [MySounds; SoundToPresent];
    end
end


% loop through the trials
for currentTrial=1:size(MySounds,1)
    SoundToPresent = MySounds(currentTrial,:);
    PsychToolboxSoundServer('Load', 1, SoundToPresent);
    disp(currentTrial)
    UpdateSoundSpectPlot(BpodSystem.ProtocolFigures.SoundFigure, MySounds(currentTrial,:));
    %% Assemble state matrix
    sma = NewStateMachine();            
    sma = AddState(sma, 'Name', 'SoundPresentation', ...
        'Timer', duration, ...
        'StateChangeConditions', {'Tup', 'Silence'}, ...
        'OutputActions', {'SoftCode', 1, 'BNCState', 2});
    sma = AddState(sma, 'Name', 'Silence', ...
        'Timer', 2, ...
        'StateChangeConditions', {'Tup', 'exit'}, ...
        'OutputActions', {});
    
    SendStateMachine(sma);    
    RawEvents = RunStateMachine;

    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        BpodSystem.Data.Stimulus{currentTrial} = MySounds(currentTrial); %save the sound
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