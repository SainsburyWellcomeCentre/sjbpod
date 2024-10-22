%{
---------------------------------------------------------------------------
    Two_Alternative_Choice_Tones_On_Return.m
    2023/01/26
    Francesca Greenstreet
    Stephenson-Jones Lab
    Sainsbury Wellcome Center

    Based on: Light2AFC.m from Sandworks
---------------------------------------------------------------------------
%}
%{
---------------------------------------------------------------------------
Two Alternative Choice task for freely moving and three ports. The stimulus
can be either visual (LED light on top of either of the side ports), or
auditory (low tones vs high tones to indicate right or left port, respectively).
There is a habituation version, where mouse gets rewarded either side.
There is a psychometric version of the auditory task.

- The mouse initiates the trial by poking on the middle port. This triggers
the stimulus.
- There is a time limit to respond ('ResponseTime'). If time up is reached
there is a punishment time ('PunishDelay') before any more trial
can start.
- On a certain percentage of trials, the stimulus is given as the animal
returns to centre port

---------------------------------------------------------------------------
%}


%% Definition of the protocol as a function
function Two_Alternative_Choice_Tones_On_Return

%Save version control
[~,git_hash_string] = system('git rev-parse HEAD');

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

% This makes the BpodSystem and S objects visible in the the MyProtocol function's workspace
global BpodSystem S

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings

    Two_Alternative_Choice_Tones_On_ReturnGUIParameters();

end

% Initialize parameter GUI plugin
BpodParameterGUI_with_tabs('init', S);
%set(BpodSystem.ProtocolFigures.ParameterGUI, 'Position', [40 200 500 500]);

%% Pause to get GUI parameters
BpodSystem.Status.Pause=1;
HandlePauseCondition;
% Sync S to the changed GUI parameters
S = BpodParameterGUI_with_tabs('sync', S);

S.RewardDelay = 0; % How long the mouse must wait in the goal port for reward to be delivered
S.PunishDelay = S.GUI.PunishDelay; % Extra time after there is a wrong poke
S.CueDelay = S.GUI.CenterPortDuration; % How long the mouse must poke in the center to activate the goal port
S.LedIntensity = S.GUI.LEDIntensity; %Up to 255. Brightness of the LED in the port
S.DrinkingGraceTime = 0; %Seconds to go back to the port to drink (cannot initiate trials in this time though)
S.BiasWindow = 10; %Number of trials in the recent past to calculate the bias, as well as to modify in the future

%% Contingency
S.ContingencyBlock = 1;
switch S.GUI.Contingency
    case 1
        %do nothing
    case 2
        %reverse
        disp('Reversing contingency');
        S.ContingencyBlock = - S.ContingencyBlock;
    case 3
        %switch blocks
        % Create a random start
        if rand > 0.5
            S.ContingencyBlock = - S.ContingencyBlock;
        end
end

%% Reward Amounts
S.RewardChangeBlock = 0; % this can change between -1, 0 and 1
switch S.GUI.RewardChange
    case 1
        %do nothing
    case 2
        %switch blocks
        % Create a random start
        S.RewardChangeBlock = 1;
        if rand > 0.5
            S.RewardChangeBlock = - S.RewardChangeBlock;
        end
    case 3
        %blocks with mulitiple different values
        S.RewardChangeBlock = 1;
        S.RewardChangeBlock = randsample(5, 1);
end

%% Difficulty
% Default difficulty (High-left)
S.PercVect = [98, 82, 66, 50, 34, 18, 2];
S.ToneOptions = fliplr(logspace(log10(7500), log10(30000), 7));
if S.ContingencyBlock == -1
    S.PercVect = fliplr(S.PercVect);
    S.ToneOptions = fliplr(S.ToneOptions);
end

%% Define stable sound parameters: 
%percentage of high tones (difficulty). High-Left, Low-Right
HighFreq = logspace(log10(20000), log10(40000), 16);
LowFreq = logspace(log10(5000), log10(10000), 16);
sampRate = 192000;
duration = 1;
rampTime = 0.01; 
amplitude = S.GUI.SoundAmplitude; %Calibrate properly! 
subduration = 0.03;
suboverlap = 0.01;

%for inference:
meanFreq = 14142; % for Click only
widthFreq = 1.5; % for Click only
nbOfFreq = 15; % for Click only
click_duration = 0.5;
click_rampTime = 0.01;
click_amplitude = S.GUI.SoundAmplitude; % 0.0001

ZeroSound = zeros(1,sampRate*duration); % This is for non-audition training levels, for the plotting

if S.GUI.TrainingLevel == 3 || S.GUI.TrainingLevel == 4 || S.GUI.TrainingLevel == 5
    PsychToolboxSoundServer('init');
    BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';
end

% Include random sound if desired. For example, for PH3 controls
if S.GUI.TrainingLevel == 2 && S.GUI.IncludeSoundInVisual
    PsychToolboxSoundServer('init');
    BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';
end    

%% Define trials
MaxTrials = 20000;
% Different TrialSequence depending on the TrainingLevel
switch S.GUI.TrainingLevel
    case {1, 2, 3} % Habituation, Visual and Auditory
        TrialsProb = [0.5, 0.5];
        TrialSequence = WeightedRandomTrials(TrialsProb, MaxTrials);
        %Switch the 2s for 7s (to be coherent with case 4 trainingLevel)
        TrialSequence(TrialSequence==2) = 7;
        RewardSequence =  WeightedRandomTrials([S.GUI.RewardProb, 1 - (S.GUI.RewardProb + S.GUI.LargeRewardProb), S.GUI.LargeRewardProb], MaxTrials);
    case {4, 5} % Aud_Psycho
        % Create vector of probabilities to generate the psychometric curve trials
        % In this case we have 7 different trial types
        TrialsProb = [0.143, 0.1428, 0.1428, 0.1428, 0.1428, 0.1428, 0.143];
        TrialSequence = WeightedRandomTrials(TrialsProb, MaxTrials);
        RewardSequence =  WeightedRandomTrials([S.GUI.RewardProb, 1 - S.GUI.RewardProb], MaxTrials);
        
end

switch S.GUI.FiberSideForNewTrials
    case{1} % Left fiber side so changing tones associated with right choices (normally low)
        SideToChange = 7; % trial sequence 1 is high 7 is low
    case{2} % Right
        SideToChange = 1;
end
NumTrialsToChange = size(find(TrialSequence==SideToChange));
TrialTypeProb = [1 - S.GUI.ProportionNewTrials, S.GUI.ProportionNewTrials];
TrialTypeSequence = ones(size(TrialSequence));
TrialsToChange =  WeightedRandomTrials(TrialTypeProb, NumTrialsToChange(2));
TrialTypeSequence(TrialSequence==SideToChange) = TrialsToChange;
TrialTypeSequence(1) = 1; % the first trial should always be sound in the centre
%% Implementation of increamental centre port hold
if S.GUI.VariableCueDelay == 1
    CueDelay = [S.CueDelay];
    for i = 1:MaxTrials
        CueDelay(end+1) = CueDelay(i)*1.01; % this gets adjusted later
    end
end
if S.GUI.VariableCueDelay == 0
    CueDelay = [];
    for i = 1:MaxTrials
        CueDelay(i) = S.CueDelay;
    end
end

%%
% ********************* High-Left, Low-Right ******************
%Create a vector that contains the side that the animal has to go to
% TrialTypes 1,2,3 are poke left (1)
% TrialTypes 5,6,7 are poke right (2)
% 4 is random
TrialSide = ConvertVector(TrialSequence);
% Preallocation does the calculations faster when trial number is big ??
emptyVector = nan(1, length(TrialSide));
BpodSystem.Data.TrialSequence = emptyVector; % The trial type of each trial completed will be added here.
BpodSystem.Data.TrialSide = emptyVector; % To store the rewarded side (2 means R, 1 means L)
BpodSystem.Data.Stimulus = {}; % To store the presented stimulus
BpodSystem.Data.TrialHighPerc = emptyVector; % To store the 'difficulty' of the trial.
BpodSystem.Data.ChosenSide = emptyVector; % To store the side chosen by the animal. (2 means R, 1 means L)
BpodSystem.Data.OptoStim = emptyVector; % To store the stimulated trial. (0 means no stimulation, 1 means yes)
BpodSystem.Data.Outcomes = emptyVector; % To store the outcome of the trial (0 means punish, 1 means success, 2 means early withdrawal, 3 means something else)
BpodSystem.Data.ResponseTime = emptyVector; % Time taken to respond
BpodSystem.Data.FirstPoke = emptyVector; %get the first poke (1 left, 2 right, NaN if no first poke happened)
BpodSystem.Data.FirstPokeCorrect = emptyVector; %get if the first poke is correct (1 correct, 0 incorrect, NaN if no first poke happened)
BpodSystem.Data.GitHash = git_hash_string; % Saves version control
BpodSystem.Data.SoundAmplitude = emptyVector; % Saves the amplitude of the sound for each trial

%% Initialize pulsepal
switch S.GUI.OptoStim
    case 1 %no optostimulation
        disp('No optostimulation selected')
        OptoStim = zeros(1,MaxTrials);
    case {2, 3, 4}
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
        
        %Generate trials with optostimulation
        OptoStim = WeightedRandomTrials([1-S.GUI.OptoChance S.GUI.OptoChance], MaxTrials);
        OptoStim = OptoStim - 1; % 0s or 1s
        
        
        % Override initial trials that have opto
        % TODO
        OptoStim(1:S.GUI.FreeOptoIniTrials) = 0;
        
        %Definition of in which port to stimulate
        OptoState = S.GUI.OptoState;
       
end

%% Initialize plots
[filepath,name,~] = fileparts(BpodSystem.Path.CurrentDataFile);

MultiFigureHM = figure('Position', [10 10 1000 600],'name',name,'numbertitle','off', 'MenuBar', 'none', 'Resize', 'on');
%sgtitle(name); % Only for Matlab2018b

% side outcome plot
BpodSystem.GUIHandles.SideOutcomePlot = subplot(5,6,[1,2,3,4,5,6]);

% TODO: This won't be faithful if only one side gets stimulated!!
SideOutcomePlotMod(BpodSystem.GUIHandles.SideOutcomePlot,'init',2-TrialSide,OptoStim);

%BpodNotebook('init');

TotalRewardDisplay('init');

%Spectrogram and sound wave
figure(MultiFigureHM);
BpodSystem.GUIHandles.SoundPlot = subplot(5,6,[7,8]);
SoundPlot(BpodSystem.GUIHandles.SoundPlot, 'init', ZeroSound);
BpodSystem.GUIHandles.SoundSpectPlot = subplot(5,6,[13,14]);
SoundSpectPlot(BpodSystem.GUIHandles.SoundSpectPlot, 'init', ZeroSound);

%Psychometric performance
figure(MultiFigureHM);
BpodSystem.GUIHandles.PsychPercPlotContOne = subplot(5,6,[11,12,17,18]);
PsychPerformancePlot(BpodSystem.GUIHandles.PsychPercPlotContOne, 'init', S.PercVect);
ContOneIdx = []; % array for storing the trial indexes of the contingency
RewChOneIdx = []; % array for storing the trial indexes of the reward change
figure(MultiFigureHM);
BpodSystem.GUIHandles.PsychPercPlotContTwo = subplot(5,6,[23,24,29,30]);
PsychPerformancePlot_Two(BpodSystem.GUIHandles.PsychPercPlotContTwo, 'init', S.PercVect);
ContTwoIdx = []; % array for storing the trial indexes of the contingency
RewChTwoIdx = []; % array for storing the trial indexes of the reward change

%Correct trials
figure(MultiFigureHM);
BpodSystem.GUIHandles.CorrectPlot = subplot(5,6,[9,10,15,16]);
CorrectPlot(BpodSystem.GUIHandles.CorrectPlot, 'init', [], [], []);

%Response time
figure(MultiFigureHM);
BpodSystem.GUIHandles.ResponseTimePlot = subplot(5,6,[19,20,25,26]);
ResponseTimePlot(BpodSystem.GUIHandles.ResponseTimePlot, 'init', [], [], 0);

%Correct first poke
figure(MultiFigureHM);
BpodSystem.GUIHandles.CorrectFirstPoke = subplot(5,6,[21,22,27,28]);
CorrectFirstPokePlot(BpodSystem.GUIHandles.CorrectFirstPoke, 'init', []);

%Create an object that is called on cleanup to save stuff
finishup = onCleanup(@() myCleanupFun(MultiFigureHM, filepath, name, BpodSystem.Path.CurrentDataFile, S));
didnothearlastsound = 0;



%% load the sound on return in advance to prevent buffering issues
S = BpodParameterGUI_with_tabs('sync', S);
returnDuration = S.GUI.NewTypeTrialsSoundDuration;
ReturnCueDelayTime = exprnd(S.GUI.NewTypeTrialsMeanSoundDelay);
ReturnHighPerc = S.PercVect(SideToChange);
ReturnLowPerc = 100 - ReturnHighPerc;
returnCOTSound = CloudOfTones(sampRate, returnDuration, rampTime, amplitude, HighFreq, LowFreq, ReturnHighPerc, ReturnLowPerc, subduration, suboverlap);
returnModAmp = randomAmplitudeModulation(returnDuration,sampRate,15,0.8);
returnModCOTSound = returnModAmp.*returnCOTSound;
returnSoundID = 2;
PsychToolboxSoundServer('Load', returnSoundID, returnModCOTSound);

defaultCOTSound = CloudOfTones(sampRate, duration, rampTime, amplitude, HighFreq, LowFreq, ReturnHighPerc, ReturnLowPerc, subduration, suboverlap);
ModAmp = randomAmplitudeModulation(duration,sampRate,15,0.8);
defaultModCOTSound = ModAmp.*defaultCOTSound;

%% Main trial loop
for currentTrial = 1:MaxTrials

    S = BpodParameterGUI_with_tabs('sync', S); % Sync parameters with BpodParameterGUI plugin
    % update training parameters if needed
    S.PunishDelay = S.GUI.PunishDelay; % Extra time after there is a wrong poke
    S.CueDelay = S.GUI.CenterPortDuration; % How long the mouse must poke in the center to activate the goal port
    S.LedIntensity = S.GUI.LEDIntensity; %Up to 255. Brightness of the LED in the port
    
    %% Change sound amplitude if asked for TODO
    if S.GUI.RandomizeAmplitude
        amplitute_vector = logspace(log10(S.GUI.AmplitudeLowerBound), log10(S.GUI.AmplitudeUpperBound), S.GUI.NumberOfAmplitudes);
        amplitude = amplitute_vector(randperm(S.GUI.NumberOfAmplitudes, 1));
    end
    disp(['Amplitude: ', num2str(amplitude)])
    %% Update reward amounts
    switch S.GUI.RewardChange
        case 1 %No change
            R = GetValveTimes(S.GUI.RewardAmount, [1 3]); 
            if S.GUI.LargeRewardProb > 0
                R_long = GetValveTimes(S.GUI.RewardAmount * 3, [1 3]); 
            end
        case 2 %every x trials, give 3 times more reward in one port
            % Check if block needs reversing
            if mod(currentTrial, S.GUI.RewardChangeBlockLength) == 0
                S.RewardChangeBlock = -S.RewardChangeBlock;
                disp('Switching reward amount block')
            end
            
            if S.RewardChangeBlock == 1 % more reward on the left
                R(1) = GetValveTimes(S.GUI.RewardAmount * 3, 1);
                R(2) = GetValveTimes(S.GUI.RewardAmount, 3);
            elseif S.RewardChangeBlock == -1 %more reward on the right
                R(1) = GetValveTimes(S.GUI.RewardAmount, 1);
                R(2) = GetValveTimes(S.GUI.RewardAmount * 3, 3);
            end
        case 3 %blocks with mulitiple different values
            if mod(currentTrial, S.GUI.RewardChangeBlockLength) == 0
                all_blocks = [1:5];
                not_current_block = all_blocks(all_blocks ~= S.RewardChangeBlock);
                S.RewardChangeBlock = randsample(not_current_block, 1);
                disp('Switching reward amount block')
            end
            if S.RewardChangeBlock == 1 %3* more reward on the left
                R(1) = GetValveTimes(S.GUI.RewardAmount * 3, 1);
                R(2) = GetValveTimes(S.GUI.RewardAmount, 3);
                disp('L reward: 6, R reward: 2');
            elseif S.RewardChangeBlock == 2 %2* more reward on the leftt
                R(1) = GetValveTimes(S.GUI.RewardAmount * 2, 1);
                R(2) = GetValveTimes(S.GUI.RewardAmount, 3);
                disp('L reward: 4, R reward: 2');
            elseif S.RewardChangeBlock == 3 %equal
                R(1) = GetValveTimes(S.GUI.RewardAmount, 1);
                R(2) = GetValveTimes(S.GUI.RewardAmount, 3);
                disp('L reward: 2, R reward: 2');
            elseif S.RewardChangeBlock == 4 % 2* more reward on the right
                R(1) = GetValveTimes(S.GUI.RewardAmount, 1);
                R(2) = GetValveTimes(S.GUI.RewardAmount * 2, 3);
                disp('L reward: 2, R reward: 4');
            elseif S.RewardChangeBlock == 5  %3*more reward on the right
                R(1) = GetValveTimes(S.GUI.RewardAmount, 1);
                R(2) = GetValveTimes(S.GUI.RewardAmount * 3, 3);
                disp('L reward: 2, R reward: 6');
            end
            
    end
    LeftValveTime = R(1); 
    RightValveTime = R(2);
    if S.GUI.LargeRewardProb > 0
        LeftValveLongTime = R_long(1);
        RightValveLongTime = R_long(2);
    else
        LeftValveLongTime = 0;
        RightValveLongTime = 0;
    end
    % hack the contingency switching for the plotting
    switch S.RewardChangeBlock
        case 1
            RewChOneIdx = [RewChOneIdx,currentTrial];
        case -1
            RewChTwoIdx = [RewChTwoIdx,currentTrial];
        case 2 
            RewChOneIdx = [RewChOneIdx,currentTrial];
        case 3
            RewChOneIdx = [RewChOneIdx,currentTrial];
        case 4
            RewChTwoIdx = [RewChTwoIdx,currentTrial];
        case 5
            RewChTwoIdx = [RewChTwoIdx,currentTrial];
            
    end
    
    %% Update Cue Delay time if max criteria is reached    
    if CueDelay(currentTrial) > S.GUI.MaxCenterPortDuration
        disp('MOUSE HAS REACHED WAIT CRITERIA')
        CueDelay(currentTrial) = S.GUI.MaxCenterPortDuration;
    end
   
    disp('CueDelay is:') 
    disp(CueDelay(currentTrial))
    
    %% Check for bias correction
    if S.GUI.BiasCorrection && mod(currentTrial-1,S.BiasWindow)==0 && currentTrial > 1 %every x trials do this, skip first trial on the counting
        BiasCalcWindow = currentTrial-(S.BiasWindow-1):currentTrial;
        RightBias = CalculateRightBias(BpodSystem.Data.FirstPoke(BiasCalcWindow), BpodSystem.Data.FirstPokeCorrect(BiasCalcWindow));
        
        %Conversion of the right bias to trial probability
        LeftProb = (RightBias + 1)/2;
       
        % Over-write future trials based on the bias
        % Different TrialSequence depending on the TrainingLevel
        switch S.GUI.TrainingLevel
            case {1, 2, 3} % Habituation, Visual and Auditory
                TrialsProbCorrected = [LeftProb, 1 - LeftProb];
                TrialSequencePiece = WeightedRandomTrials(TrialsProbCorrected, S.BiasWindow);
                %Switch the 2s for 7s (to be coherent with case 4 trainingLevel)
                TrialSequencePiece(TrialSequencePiece==2) = 7;
                disp(['Correcting bias using probabilities [L R] ', num2str(TrialsProbCorrected)])
                % Also sort out the trialtypesequence
                TrialTypeSequencePiece = ones(size(TrialSequencePiece));
                NumTrialsToChangeInPiece = size(find(TrialSequencePiece==SideToChange));
                TrialsToChangeInPiece =  WeightedRandomTrials(TrialTypeProb, NumTrialsToChangeInPiece(2));
                TrialTypeSequencePiece(TrialSequencePiece==SideToChange) = TrialsToChangeInPiece;
                
                
            case {4, 5} % Aud_Psycho
                % Not implemented yet!!!!!!
                disp('Bias correction not implemented for psychometric version')
                % Create vector of probabilities to generate the psychometric curve trials
                % In this case we have 7 different trial types
                %TrialsProb = [0.143, 0.1428, 0.1428, 0.1428, 0.1428, 0.1428, 0.143];
                %TrialSequence = WeightedRandomTrials(TrialsProb, MaxTrials);
                TrialSequencePiece = TrialSequence(currentTrial:currentTrial+(S.BiasWindow-1));
        end
        
        % Change it in the trial sequence and trial side
        TrialSequence(currentTrial + 1:currentTrial+(S.BiasWindow-1) + 1) = TrialSequencePiece;
        TrialSide(currentTrial + 1:currentTrial+(S.BiasWindow-1) + 1) = ConvertVector(TrialSequence(currentTrial + 1:currentTrial+(S.BiasWindow-1) + 1));
        TrialTypeSequence(currentTrial + 1:currentTrial+(S.BiasWindow-1) + 1) = TrialTypeSequencePiece;
        
    end
    
    %% Determinte difficulty and deal with contingency
    % If the contingency is in blocks, reverse the difficulty vector, and
    % change the contingency variable
    switch S.GUI.Contingency
        case 3
            if mod(currentTrial, S.GUI.ContingencyBlockLength) == 0
                S.ContingencyBlock = -S.ContingencyBlock;
                S.PercVect = fliplr(S.PercVect);
                disp('Switching contingency block')
            end       
    end
    HighPerc = S.PercVect(TrialSequence(currentTrial));
    LowPerc = 100 - HighPerc;
    ToneForThisTrial = S.ToneOptions(TrialSequence(currentTrial));
    
    % add trial index to their corresponding array for the plotting of
    % psychometric curves
    switch S.ContingencyBlock
        case 1
            ContOneIdx = [ContOneIdx,currentTrial];
        case -1
            ContTwoIdx = [ContTwoIdx,currentTrial];
    end
    
    
    %% Determine trial-specific state matrix fields
    
    % Independent punish condition
    switch S.GUI.Punish
        case 1 % No punish
            WrongSideCondition = 'WaitForResponse';
            EarlyWithdrawalCondition = 'WaitForPoke';
        case 2 % Punish wrong side
            WrongSideCondition = 'WaitForSidePortOut';
            EarlyWithdrawalCondition = 'WaitForPoke';
        case 3 % Punish wrong side and early withdrawal
            WrongSideCondition = 'WaitForSidePortOut';
            EarlyWithdrawalCondition = 'EarlyWithdrawal'; % Trial ends
    end   


    % Independent opto-stimulation
    switch OptoStim(currentTrial)
        case 0 % No opto
            OptoCondition_onCenterPort = 0;
            OptoCondition_onLeftPort = 0;
            OptoCondition_onRightPort = 0;
            OptoCondition_onPunishedPort = 0;
            
        case 1 % Opto
            switch OptoState
                case 1 %'CenterPort'
                    OptoCondition_onCenterPort = 1; % BNC number 1
                    % Override if stimulation is selected only on one side
                    if S.GUI.JustOnePort && S.GUI.JOPSide ~= TrialSide(currentTrial)
                        OptoCondition_onCenterPort = 0;
                    end
                    OptoCondition_onLeftPort = 0;
                    OptoCondition_onRightPort = 0;
                    OptoCondition_onPunishedPort = 0;
                case 2 %'SidePort' % THIS IS ONLY TRIGGERED IN REWARDED TRIALS AND IN PUNISH CONDITION
                    OptoCondition_onCenterPort = 0;
                    OptoCondition_onLeftPort = 1;
                    OptoCondition_onRightPort = 1;
                    OptoCondition_onPunishedPort = 1;
                    % Override if stimulation is selected only on one side
                    if S.GUI.JustOnePort
                        switch TrialSide(currentTrial)
                            case 1 % Left trial
                                switch S.GUI.JOPSide
                                    case 1 % opto only in left
                                        OptoCondition_onLeftPort = 1;
                                        OptoCondition_onRightPort = 0; % this won't get triggered when punishing
                                        OptoCondition_onPunishedPort = 0;
                                    case 2 % opto only in right
                                        OptoCondition_onLeftPort = 0;
                                        OptoCondition_onRightPort = 0;
                                        OptoCondition_onPunishedPort = 1;
                                end
                                
                            case 2 % Right trial
                                switch S.GUI.JOPSide
                                    case 1 % opto only in left
                                        OptoCondition_onLeftPort = 0;
                                        OptoCondition_onRightPort = 0; % this won't get triggered when punishing
                                        OptoCondition_onPunishedPort = 1;
                                    case 2 % opto only in right
                                        OptoCondition_onLeftPort = 0;
                                        OptoCondition_onRightPort = 1;
                                        OptoCondition_onPunishedPort = 0;
                                end
                        end
                    end
            end
    end

    
    % Independent trial side
    switch TrialSide(currentTrial)
        case 1 % go Left
            PortID = 'PWM1';
            LeftPokeAction = 'LeftReward';
            RightPokeAction = WrongSideCondition;
            
            switch RewardSequence(currentTrial)
                case 2 % Omit reward (goes to punish state)
                    LeftPokeAction = 'Omission';
                case 3 % Large reward
                    LeftPokeAction = 'LeftLargeReward';
            end  
        case 2 % go Right
            PortID = 'PWM3';
            LeftPokeAction = WrongSideCondition;
            RightPokeAction = 'RightReward';
            
            switch RewardSequence(currentTrial)
                case 2 % Omit reward (goes to punish state)
                    RightPokeAction = 'Omission';
                case 3 % large reward
                    RightPokeAction = 'RightLargeReward';
            end  
    end
    

    % Independent training level
    switch S.GUI.TrainingLevel
        case 1 % Habituation
            S.ResponseTime = S.GUI.ResponseTime; % Time to respond, otherwise incomplete trial
            WaitForResponseOutput = {'PWM1', S.LedIntensity, 'PWM3', S.LedIntensity}; %LED ON
            %WaitForResponseOutput = {}; %LED OFF (otherwise light might not be recognized as important)
            %override the wrong side
            LeftPokeAction = 'LeftReward';
            RightPokeAction = 'RightReward';
            WaitForPokeOutput = {'PWM2', S.LedIntensity, 'BNCState', 0}; %middle light ON, TTL to sync with OpenEphys
            EarlyWithdrawalOutput = {};
            ModCOTSound = ZeroSound; % For the plotting
            %SoundType = 0; % SoundType: 0 = NA; 1 = COT; 2 = WN; 3 = Click;
            SoundType = 'NA';
         
        case 2 % Visual
            S.ResponseTime = S.GUI.ResponseTime;
            WaitForResponseOutput = {PortID, S.LedIntensity}; %LED ON 
            WaitForPokeOutput = {'PWM2', S.LedIntensity, 'BNCState', 0};
            EarlyWithdrawalOutput = {};
            ModCOTSound = ZeroSound; % For the plotting
            SoundType = 0;
            
            % Include random sound if desired. For example, for PH3 controls
            if S.GUI.IncludeSoundInVisual
                % Determine trial-specific SoundIDs and parameters
                % Random percentage of easy trials (1s or 7s)
                FakeTrial = randperm(2,1);
                if FakeTrial == 2
                    FakeTrial = 7;
                end
                HighPerc = S.PercVect(FakeTrial);
                LowPerc = 100 - HighPerc;
                COTSound = CloudOfTones(sampRate, duration, rampTime, amplitude, HighFreq, LowFreq, HighPerc, LowPerc, subduration, suboverlap);
                % Modulate amplitude randomly
                modAmp = randomAmplitudeModulation(duration,sampRate,15,0.8);
                ModCOTSound = modAmp.*COTSound;
                SoundID = 1;
                PsychToolboxSoundServer('Load', SoundID, ModCOTSound);

                WaitForPokeOutput = {'PWM2', S.LedIntensity, 'BNCState', 0, 'SoftCode', 255}; % Stop sounds
                EarlyWithdrawalOutput = {'SoftCode', 255};
            end
 
        case {3, 4} % Auditory
            S.WNOnset = S.GUI.WNOnset;
            S.ClickOnset = S.GUI.ClickOnset;
            S.SilenceOnset = S.GUI.SilenceOnset;
            switch S.GUI.Inference
                case 1 % No Inference       
                SoundType = 'COT'; 

                case 2 % Simple_WN Inference  
                    if (TrialSide(currentTrial) == S.GUI.WNSide && currentTrial >= S.WNOnset)
                            SoundType = 'WN';
                    else    
                            SoundType = 'COT'; 
                    end
                
                case 3 % Simple_Click Inference         
                    if (TrialSide(currentTrial) ==S.GUI.ClickSide && currentTrial >= S.ClickOnset)
                            SoundType = 'Click'; 
                    else    
                            SoundType = 'COT'; 
                    end
                 
                case 4 % Dual Inference
                    if (TrialSide(currentTrial) ==S.GUI.WNSide && currentTrial >= S.WNOnset) 
                            SoundType = 'WN';
                    elseif (TrialSide(currentTrial) ==S.GUI.ClickSide && currentTrial >= S.ClickOnset)
                            SoundType = 'Click'; 
                    else    
                            SoundType = 'COT'; 
                    end
                case 5 % Silence          
                    if (TrialSide(currentTrial) ==S.GUI.SilenceSide && currentTrial >= S.SilenceOnset)
                            SoundType = 'NA'; 
                    else    
                            SoundType = 'COT'; 
                    end
            end 
            
                %% If tone was played on the return last time
            if TrialTypeSequence(currentTrial) == 2
                if didnothearlastsound == 0
                    SoundType = 'NA';
                else
                    display('did not hear last sound')
                    TrialTypeSequence(currentTrial) = 1;
                    SoundType = 'COT';
                    ModCOTSound = defaultModCOTSound;
                end
            end
            
            if strcmp(SoundType, 'COT') == 1 && didnothearlastsound == 0 % checks if SoundType is 'COT'
                % Determine trial-specific SoundIDs and parameters 
                COTSound = CloudOfTones(sampRate, duration, rampTime, amplitude, HighFreq, LowFreq, HighPerc, LowPerc, subduration, suboverlap);
                modAmp = randomAmplitudeModulation(duration,sampRate,15,0.8);
                ModCOTSound = modAmp.*COTSound;

            elseif strcmp(SoundType, 'WN') == 1
                ModCOTSound = GenerateWhiteNoise(sampRate, duration, rampTime, amplitude);
                    
            elseif strcmp(SoundType, 'Click') == 1
                ModCOTSound = SoundGenerator(sampRate, meanFreq, widthFreq, nbOfFreq, click_duration, click_rampTime, click_amplitude);
                
            elseif strcmp(SoundType, 'NA') == 1
                ModCOTSound = ZeroSound;
                SoundType
            end
            
            SoundID = 1;
            PsychToolboxSoundServer('Load', SoundID, ModCOTSound);
    
            S.ResponseTime = S.GUI.ResponseTime;
            WaitForResponseOutput = {};
            WaitForPokeOutput = {'PWM2', S.LedIntensity, 'BNCState', 0, 'SoftCode', 255}; % Stop sounds
            EarlyWithdrawalOutput = {'SoftCode', 255};
        
        case 5 % Auditory psychometric with different frequency clouds not mixtures of the two clouds
             % Determine trial-specific SoundIDs and parameters
            
            COTSound = CloudOfTones(sampRate, duration, rampTime, amplitude, ToneForThisTrial, 0, 100, 0, subduration, suboverlap);
            % Modulate amplitude randomly
            modAmp = randomAmplitudeModulation(duration,sampRate,15,0.8);
            ModCOTSound = modAmp.*COTSound;
            SoundID = 1;
            PsychToolboxSoundServer('Load', SoundID, ModCOTSound);
    
            S.ResponseTime = S.GUI.ResponseTime;
            WaitForResponseOutput = {};
            WaitForPokeOutput = {'PWM2', S.LedIntensity, 'BNCState', 0, 'SoftCode', 255}; % Stop sounds
            EarlyWithdrawalOutput = {'SoftCode', 255};
    end    
    
    % Independent extra time before sound onset for optostimulation
    JumpToStateAfterMiddlePoke = 'CueDelay';
    WaitAfterMiddlePokeOutput = {};
    switch S.GUI.TrainingLevel
        case {1,2} %Visual
            MiddlePortOutput = {'PWM2', S.LedIntensity, 'BNCState', OptoCondition_onCenterPort};
        case {3,4,5} %Auditory
            MiddlePortOutput = {'PWM2', S.LedIntensity, 'SoftCode', SoundID, 'BNCState', OptoCondition_onCenterPort};           
    end
    % If the option is selected, override to include another state to do
    % opto before
    pre_cue_waiting_time = 0; % allocate it so code does not break
    if S.GUI.TimeBeforeOnset
        % if this state is allways the same time
        pre_cue_waiting_time = S.GUI.TimeBeforeOnsetDuration;
        % if a truncated exponential is selected draw from it:
        if S.GUI.AddTruncExp
            % pass the parameters from the GUI field to the exponential
            % function
            pre_cue_waiting_time = truncExp(S.GUI.Exp_offset, S.GUI.Exp_rate, S.GUI.Exp_trunc);
        end
        %disp(['Waiting: ', num2str(pre_cue_waiting_time)])
        
        JumpToStateAfterMiddlePoke = 'WaitAfterMiddlePoke';
        WaitAfterMiddlePokeOutput = {'PWM2', S.LedIntensity, 'BNCState', OptoCondition_onCenterPort};
        switch S.GUI.TrainingLevel %Optostimulation is removed from them
            case {1,2} %Visual
                MiddlePortOutput = {'PWM2', S.LedIntensity};
            case {3,4,5} %Auditory
                MiddlePortOutput = {'PWM2', S.LedIntensity, 'SoftCode', SoundID};           
        end
    end
    returnDuration = S.GUI.NewTypeTrialsSoundDuration;
    if TrialTypeSequence(currentTrial + 1) == 1
        ReturnCueCondition = 'Saving';
        ReturnCueDelayTime = 0;
        returnSoundID = 0
        returnModCOTSound = nan;
    else
        ReturnCueCondition = 'ReturnCueDelay';
        currentTrial 
        returnSoundID = 2;
        %ReturnHighPerc = S.PercVect(TrialSequence(currentTrial + 1));
        %ReturnLowPerc = 100 - ReturnHighPerc
        %returnCOTSound = CloudOfTones(sampRate, returnDuration, rampTime, amplitude, HighFreq, LowFreq, ReturnHighPerc, ReturnLowPerc, subduration, suboverlap);
        %returnModAmp = randomAmplitudeModulation(returnDuration,sampRate,15,0.8);
        %returnModCOTSound = returnModAmp.*returnCOTSound;
        %returnSoundID = 2;
        %PsychToolboxSoundServer('Load', returnSoundID, returnModCOTSound);
    
    end
    
    if TrialTypeSequence(currentTrial) == 1
        FirstStateCondition = 'WaitForPoke'
    else
        FirstStateCondition = 'CueDelay'
    end
    %% Assemble state matrix
    sma = NewStateMachine(); 
    sma = AddState(sma, 'Name', 'TrialStart', ...
        'Timer', 0.01, ...
        'StateChangeConditions', {'Tup', FirstStateCondition}, ...
        'OutputActions', {'BNCState', 2,  'SoftCode', 255}); %ttl and stops sounds
    %'WaitForPoke' is the initial state.
    sma = AddState(sma, 'Name', 'WaitForPoke', ...
        'Timer', 5, ...
        'StateChangeConditions', {'Port2In', JumpToStateAfterMiddlePoke, 'Tup', 'DidNotPokeInTime'}, ...
        'OutputActions', WaitForPokeOutput); 
    %'CueDelay' is the second automatic state
    %If the mouse does not hold the head enough time in the central port,
    %it jumps back to 'WaitForPoke'. If 'CueDelay' timer is reached, it jumps to
    %'WaitForPortOut'.
    sma = AddState(sma, 'Name', 'CueDelay', ...
        'Timer', CueDelay(currentTrial), ...
        'StateChangeConditions', {'Port2Out', EarlyWithdrawalCondition, 'Tup', 'WaitForPortOut'}, ...
        'OutputActions', MiddlePortOutput);
    %'WaitForPortOut' changes when the mouse removes the head from the
    %central port.
    sma = AddState(sma, 'Name', 'WaitForPortOut', ...
        'Timer', 0, ...
        'StateChangeConditions', {'Port2Out', 'WaitForResponse'}, ...
        'OutputActions', {});
    %'WaitForResponse' changes with a timer, or when the mouse pokes in one
    %of the side ports. LED on. It either goes to 'Punish' or to
    %'L/R_RewardDelay'
    sma = AddState(sma, 'Name', 'WaitForResponse', ...
        'Timer', S.ResponseTime, ...
        'StateChangeConditions', {'Port1In', LeftPokeAction, 'Port3In', RightPokeAction, 'Tup', 'exit'}, ...
        'OutputActions', WaitForResponseOutput); 
    %'L/R_Reward' opens the valve for some time and goes to drinking state.
    sma = AddState(sma, 'Name', 'LeftReward', ...
        'Timer', LeftValveTime, ...
        'StateChangeConditions', {'Tup', 'WaitForSidePortOut'}, ...
        'OutputActions', {'ValveState', 1, 'BNCState', OptoCondition_onLeftPort}); 
    sma = AddState(sma, 'Name', 'RightReward', ...
        'Timer', RightValveTime, ...
        'StateChangeConditions', {'Tup', 'WaitForSidePortOut'},...
        'OutputActions', {'ValveState', 4, 'BNCState', OptoCondition_onRightPort}); 
  
    sma = AddState(sma, 'Name', 'WaitForSidePortOut',...
        'Timer', 0, ...
        'StateChangeConditions', {'Port1Out', ReturnCueCondition, 'Port3Out', ReturnCueCondition}, ...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'ReturnCueDelay', ...
        'Timer', ReturnCueDelayTime, ...
        'StateChangeConditions', {'Tup', 'ReturnCuePlay'}, ...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'ReturnCuePlay', ...
        'Timer', returnDuration, ...
        'StateChangeConditions', {'Port2In', 'Saving', 'Tup', 'Saving'}, ...
        'OutputActions', {'SoftCode', returnSoundID});
        %Saving is a mock state to check that the animal has drunk. It is
    %used to plot stuff and calculate correct trialsS
    sma = AddState(sma, 'Name', 'Saving', ...
        'Timer', 0, ...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {});
    
 
    %'EarlyWithdrawal finishes the trial
    sma = AddState(sma, 'Name', 'EarlyWithdrawal', ...
        'Timer', 0, ...
        'StateChangeConditions', {'Tup', 'exit'}, ...
        'OutputActions', EarlyWithdrawalOutput);

    
    %'WaitAfterMiddlePoke' is a waiting period for optostimulation to begin.
    sma = AddState(sma, 'Name', 'WaitAfterMiddlePoke', ...
        'Timer', pre_cue_waiting_time, ...
        'StateChangeConditions', {'Port2Out', EarlyWithdrawalCondition, 'Tup', 'CueDelay'}, ...
        'OutputActions', WaitAfterMiddlePokeOutput); 

    sma = AddState(sma, 'Name', 'DidNotPokeInTime', ...
    'Timer', 0, ...
    'StateChangeConditions', {'Tup', 'exit'}, ...
    'OutputActions', {});


    
    
    SendStateMachine(sma);
    
    RawEvents = RunStateMachine;
    
    %% Calculate stuff, save and update plots
    
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        
        %BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        BpodSystem.Data.TrialSequence(currentTrial) = TrialSequence(currentTrial); % Adds the trial type of the current trial to data
        BpodSystem.Data.TrialTypeSequence(currentTrial) = TrialTypeSequence(currentTrial); 
        BpodSystem.Data.TrialHighPerc(currentTrial) = HighPerc; %'difficulty'
        BpodSystem.Data.TrialSide(currentTrial) = TrialSide(currentTrial);
        BpodSystem.Data.Stimulus{currentTrial} = ModCOTSound; %save the sound
        BpodSystem.Data.ReturnStimulus{currentTrial} = returnModCOTSound; %save the sound
        %BpodSystem.Data.OptoStim(currentTrial) = OptoStim(currentTrial); %opto stimulation
        
        BpodSystem.Data.ChosenSide(currentTrial) = CalculateChosenSide(BpodSystem.Data.RawEvents.Trial{currentTrial}, TrialSide(currentTrial)); %mouse response
        BpodSystem.Data.Outcomes(currentTrial) = CalculateOutcome(BpodSystem.Data.RawEvents.Trial{currentTrial}.States); %outcome of trial
        BpodSystem.Data.ResponseTime(currentTrial) = CalculateResponseTime(BpodSystem.Data.RawEvents.Trial{currentTrial}.States); %get response time
        BpodSystem.Data.FirstPoke(currentTrial) = CalculateFirstPoke(BpodSystem.Data.RawEvents.Trial{currentTrial}); %get the first poke (1 L, 2 R)
        BpodSystem.Data.FirstPokeCorrect(currentTrial) = IsFirstPokeCorrect(BpodSystem.Data.FirstPoke(currentTrial), TrialSide(currentTrial)); %get the first poke (1correct and 0incorrect)
        
        BpodSystem.Data.OptoStim(currentTrial) = CheckIfOpto(BpodSystem.Data.ChosenSide(currentTrial), OptoStim(currentTrial), S.GUI.JustOnePort, S.GUI.JOPSide);
        
        BpodSystem.Data.SoundAmplitude(currentTrial) = amplitude; %sound amplitude
        BpodSystem.Data.SoundType{currentTrial} = SoundType; % sound type
        if ~isnan(BpodSystem.Data.RawEvents.Trial{currentTrial}.States.DidNotPokeInTime)
            didnothearlastsound = 1;
        else
            didnothearlastsound = 0;
        end
        UpdateTotalRewardDisplay(S.GUI.RewardAmount, currentTrial);
        SideOutcomePlotMod(BpodSystem.GUIHandles.SideOutcomePlot,'update',BpodSystem.Data.nTrials+1,2-TrialSide,BpodSystem.Data.Outcomes);
        SoundPlot(BpodSystem.GUIHandles.SoundPlot, 'update', ModCOTSound);        
        SoundSpectPlot(BpodSystem.GUIHandles.SoundSpectPlot, 'update', ModCOTSound);
        % update the psychometric curve plots
        % if displaying contingency switch
        if S.GUI.RewardChange == 2
            switch S.RewardChangeBlock
                case 1
                    PsychPerformancePlot(BpodSystem.GUIHandles.PsychPercPlotContOne, 'update', S.PercVect, BpodSystem.Data.TrialHighPerc(RewChOneIdx), BpodSystem.Data.FirstPoke(RewChOneIdx), BpodSystem.Data.OptoStim(RewChOneIdx));
                case -1
                    PsychPerformancePlot_Two(BpodSystem.GUIHandles.PsychPercPlotContTwo, 'update', S.PercVect, BpodSystem.Data.TrialHighPerc(RewChTwoIdx), BpodSystem.Data.FirstPoke(RewChTwoIdx), BpodSystem.Data.OptoStim(RewChTwoIdx));
            end            
        else
            switch S.ContingencyBlock
                case 1
                    PsychPerformancePlot(BpodSystem.GUIHandles.PsychPercPlotContOne, 'update', S.PercVect, BpodSystem.Data.TrialHighPerc(ContOneIdx), BpodSystem.Data.FirstPoke(ContOneIdx), BpodSystem.Data.OptoStim(ContOneIdx));
                case -1
                    PsychPerformancePlot_Two(BpodSystem.GUIHandles.PsychPercPlotContTwo, 'update', S.PercVect, BpodSystem.Data.TrialHighPerc(ContTwoIdx), BpodSystem.Data.FirstPoke(ContTwoIdx), BpodSystem.Data.OptoStim(ContTwoIdx));
            end
        end
        CorrectPlot(BpodSystem.GUIHandles.CorrectPlot, 'update', BpodSystem.Data.TrialSide(1:currentTrial), BpodSystem.Data.ChosenSide(1:currentTrial), BpodSystem.Data.OptoStim(1:currentTrial));
        ResponseTimePlot(BpodSystem.GUIHandles.ResponseTimePlot, 'update', BpodSystem.Data.ResponseTime(1:currentTrial), BpodSystem.Data.FirstPokeCorrect(1:currentTrial), BpodSystem.Data.TrialStartTimestamp);
        CorrectFirstPokePlot(BpodSystem.GUIHandles.CorrectFirstPoke, 'update', BpodSystem.Data.FirstPokeCorrect(1:currentTrial));
        
        % Save only every 50 trials to avoid delay between trials
        if mod(currentTrial, 50) == 0
            SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
            disp('Data saved');
        end
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0 %stop button pressed        
        if S.GUI.TrainingLevel == 3 || S.GUI.TrainingLevel == 4
            PsychToolboxSoundServer('close'); % Close sound server
        end
        return
    end
end



%% Functions

function myCleanupFun(f, filepath, name, pathToSave, setToSave)
    SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
    disp('Data saved');
    %save figure at the end of the session
    figure(f);
    savefig([filepath '\' name '.fig']);
    close(f);
    disp('Figure saved')
    save_Trial_Settings_HMV(pathToSave, setToSave);
    disp('Settings saved')
    


function firstPoke = CalculateFirstPoke(Data)
    % This function can be written in a smarter way
    Events = Data.Events;    
    trialInitTime = Data.States.WaitForPortOut(2);
    firstPoke = NaN; % Default. If the mouse does not respond
    if ~isnan(trialInitTime) % If there is a proper trial initiation
        %First, leave firstPoke to NaN if there is no drinking or punish
        %state
        if isnan(Data.States.LeftReward(1)) && isnan(Data.States.RightReward(1))&& isnan(Data.States.WaitForSidePortOut(1))
            firstPoke = NaN;

        %Second, determine the side the mouse poked first
        elseif isfield(Events, 'Port1In') && ~isfield(Events, 'Port3In')
            firstPoke = 1;
        elseif isfield(Events, 'Port3In') && ~isfield(Events, 'Port1In')
            firstPoke = 2;
        elseif isfield(Events, 'Port3In') && isfield(Events, 'Port1In')
            % both ports have been poked.
            %Get the first event, for each port, that happened during the waiting for response time
            LeftPortEv = Events.Port1In(find(Events.Port1In > trialInitTime, 1));
            RightPortEv = Events.Port3In(find(Events.Port3In > trialInitTime, 1));
            %Check that they are not empty            
            if ~isempty(LeftPortEv) && isempty(RightPortEv)
                firstPoke = 1;
            elseif isempty(LeftPortEv) && ~isempty(RightPortEv)
                firstPoke = 2;
            elseif ~isempty(LeftPortEv) && ~isempty(RightPortEv)
                %Mouse has poked in both after initiating the trial
                if LeftPortEv < RightPortEv
                    firstPoke = 1;
                elseif LeftPortEv > RightPortEv
                    firstPoke = 2;
                else
                    firstPoke = NaN;
                end
            end
        else
            firstPoke = NaN;
        end
    else
        firstPoke = NaN;
    end
    
function firstPokeCorrect = IsFirstPokeCorrect(firstPoke, goal)
    firstPokeCorrect = NaN;
    if firstPoke == goal
        firstPokeCorrect = 1;
    elseif isnan(firstPoke)
        firstPokeCorrect = NaN;       
    elseif firstPoke ~= goal
        firstPokeCorrect = 0;
    end   
    
function Outcome = CalculateOutcome(State)
    if ~isnan(State.LeftReward(1)) || ~isnan(State.RightReward(1))
        Outcome = 1;
    elseif (isnan(State.LeftReward(1)) || isnan(State.RightReward(1))) && isnan(State.DidNotPokeInTime(1)) && ~isnan(State.WaitForSidePortOut(1)) 
        Outcome = 0; 
    elseif ~isnan(State.DidNotPokeInTime(1)) 
        Outcome = 3;
    elseif ~isnan(State.EarlyWithdrawal(1))
        Outcome = 2;
    else
        Outcome = 3;
    end

function ResponseTime = CalculateResponseTime(State)
    if ~isnan(State.WaitForResponse)
        ResponseTime = State.WaitForResponse(2) - State.WaitForResponse(1);
    else
        ResponseTime = NaN;
    end
    
function UpdateTotalRewardDisplay(RewardAmount, currentTrial)
    % If rewarded based on the state data, update the TotalRewardDisplay
    global BpodSystem
    if ~isnan(BpodSystem.Data.RawEvents.Trial{currentTrial}.States.LeftReward(1)) || ~isnan(BpodSystem.Data.RawEvents.Trial{currentTrial}.States.RightReward(1))
        TotalRewardDisplay('add', RewardAmount);
    end

function Outcome = CalculateChosenSide(Data, goal)
    % get the side selected by the animal
    % handle the condition where the animal does not respond
    Outcome = NaN;
    if goal==1 %goal is left
        if ~isnan(Data.States.LeftReward(1))
            Outcome = 1; %it went to the left
        elseif ~isnan(Data.States.WaitForSidePortOut(1))
            Outcome = 2; %it went to the right
        end
    elseif goal==2 %goal is right
        if ~isnan(Data.States.RightReward(1))
            Outcome = 2; %it went to the right
        elseif ~isnan(Data.States.WaitForSidePortOut(1))
            Outcome = 1; %it went to the left
        end
    end

function opto = CheckIfOpto(firstpoke, ini_opto, jop, opto_side)
    opto = ini_opto;
    % there will be cases in which there won't be opto
    if ini_opto == 1 % if stimulation was suppossed to happen
        if jop == 1 % if only optostimulation on one side
            % mouse went the way that unmatched the stimulation side
            if firstpoke ~= opto_side
                opto = 0;
            end           
        end
    end
    
    
function OutVector = ConvertVector(InVector)
    % TrialTypes 1,2,3 are poke left
    % TrialTypes 5,6,7 are poke right
    % TrialType 4 is random
    OutVector = ones(size(InVector));
    OutVector(1,InVector>4) = 2;
    OutVector(1,InVector==4) = randi([1, 2], 1);

    
