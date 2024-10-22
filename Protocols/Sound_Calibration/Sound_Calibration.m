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
Display sounds of different frequencies at an amplitude calculated using
Measure_DB.m
---------------------------------------------------------------------------

%}


%% Definition of the protocol as a function
function Sound_Calibration
% This makes the BpodSystem object visible in the the MyProtocol function's workspace
global BpodSystem
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S

BpodSystem.ProtocolFigures.SoundFigure = figure;

%% Create sounds and load them

%% Define stable sound parameters: 
sampRate = 192000;
S.Frequency = logspace(log10(4000),log10(45000),20);
duration = 0.2;
rampTime = 0.05;
time=0:1/sampRate:duration-1/sampRate;
%S.Amplitudes = [0.005 0.01 0.02];

% Get the amplitude value for 70dB
load('SoundCalibrationHMV.mat')
% fit a spline model to calculate
amplitude = spline(dBcalib(:,2),dBcalib(:,1),70);

PsychToolboxSoundServer('init');
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';
MySounds = [ ];
%SoundIDcounter = 1;
for FreqID = 1:size(S.Frequency,2)
    freq = S.Frequency(1,FreqID);
    % Characteristic sound to align: at 1kHz and 0.03 amplitude
    %AlignSound = ToneGenerator(time, rampTime, 0.03, 1000);
    %PsychToolboxSoundServer('Load', SoundIDcounter, AlignSound);
    %SoundIDcounter = SoundIDcounter + 1;
    %MySounds = [MySounds; AlignSound];
    %ampli = S.Amplitudes(1,SoundID);
    %disp(ampli)
    SoundToPresent = ToneGenerator(time, rampTime, amplitude, freq);
    PsychToolboxSoundServer('Load', FreqID, SoundToPresent);
    %SoundIDcounter = SoundIDcounter + 1;
    %disp(SoundIDcounter)
    MySounds = [MySounds; SoundToPresent];
end


% loop through the trials
for currentTrial=1:size(S.Frequency,2)
    SoundToPresent = MySounds(currentTrial,:);
    %PsychToolboxSoundServer('Load', 1, SoundToPresent);
    disp(currentTrial)
    UpdateSoundSpectPlot(BpodSystem.ProtocolFigures.SoundFigure, MySounds(currentTrial,:));
    %% Assemble state matrix
    sma = NewStateMachine();            
    sma = AddState(sma, 'Name', 'SoundPresentation', ...
        'Timer', duration, ...
        'StateChangeConditions', {'Tup', 'Silence'}, ...
        'OutputActions', {'SoftCode', currentTrial, 'BNCState', 2});
    sma = AddState(sma, 'Name', 'Silence', ...
        'Timer', 0.1, ...
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