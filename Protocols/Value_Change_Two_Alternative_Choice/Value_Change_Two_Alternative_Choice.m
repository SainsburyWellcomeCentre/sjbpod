
%% Definition of the protocol as a function
function Value_Change_Two_Alternative_Choice

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

    Value_Change_Two_Alternative_Choice_GUIParameters();

end

S.RewardDelay = 0; % How long the mouse must wait in the goal port for reward to be delivered
S.PunishDelay = S.GUI.PunishDelay; % Extra time after there is a wrong poke
S.CueDelay = S.GUI.CenterPortDuration; % How long the mouse must poke in the center to activate the goal port
S.LedIntensity = S.GUI.LEDIntensity; %Up to 255. Brightness of the LED in the port
S.DrinkingGraceTime = 0; %Seconds to go back to the port to drink (cannot initiate trials in this time though)
S.BiasWindow = 10; %Number of trials in the recent past to calculate the bias, as well as to modify in the future
% Initialize parameter GUI plugin
BpodParameterGUI_with_tabs('init', S);
%set(BpodSystem.ProtocolFigures.ParameterGUI, 'Position', [40 200 500 500]);

%% Pause to get GUI parameters
BpodSystem.Status.Pause=1;
HandlePauseCondition;
% Sync S to the changed GUI parameters
S = BpodParameterGUI_with_tabs('sync', S);

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


%% Difficulty
% Default difficulty (High-left)
S.PercVect = [98, 82, 66, 50, 34, 18, 2];
if S.ContingencyBlock == -1
    S.PercVect = fliplr(S.PercVect);
end

%% Define stable sound parameters: 
%percentage of high tones (difficulty). High-Left, Low-Right
HighFreq = logspace(log10(20000), log10(40000), 16);
MidFreq = logspace(log10(10000), log10(20000), 16);
LowFreq = logspace(log10(5000), log10(10000), 16);
sampRate = 192000;
duration = 0.5;
rampTime = 0.01; 
amplitude = S.GUI.SoundAmplitude; %Calibrate properly! 
subduration = 0.03;
suboverlap = 0.01;

ZeroSound = zeros(1,sampRate*duration); % This is for non-audition training levels, for the plotting

if S.GUI.TrainingLevel == 3 || S.GUI.TrainingLevel == 4
    PsychToolboxSoundServer('init');
    BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';
end

%% Define trials
MaxTrials = 1500;
% Different TrialSequence depending on the TrainingLevel
switch S.GUI.TrainingLevel
    case {1, 2, 3} % Habituation, Visual and Auditory
        TrialsProb = [0.5, 0.5];
        TrialSequence = WeightedRandomTrials(TrialsProb, MaxTrials);
        %Switch the 2s for 7s (to be coherent with case 4 trainingLevel)
        TrialSequence(TrialSequence==2) = 7;
        RewardSequence =  WeightedRandomTrials([S.GUI.RewardProb, 1 - S.GUI.RewardProb], MaxTrials);

    case 4 % Aud_Psycho
        % Create vector of probabilities to generate the psychometric curve trials
        % In this case we have 7 different trial types
        TrialsProb = [0.143, 0.1428, 0.1428, 0.1428, 0.1428, 0.1428, 0.143];
        TrialSequence = WeightedRandomTrials(TrialsProb, MaxTrials);
        RewardSequence =  WeightedRandomTrials([S.GUI.RewardProb, 1 - S.GUI.RewardProb], MaxTrials);
end

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
end

%% Initialize plots
[filepath,name,~] = fileparts(BpodSystem.Path.CurrentDataFile);

MultiFigureHM = figure('Position', [10 10 1000 600],'name',name,'numbertitle','off', 'MenuBar', 'none', 'Resize', 'on');
%sgtitle(name); % Only for Matlab2018b

% side outcome plot
BpodSystem.GUIHandles.SideOutcomePlot = subplot(5,6,[1,2,3,4,5,6]);
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

%% Main trial loop
for currentTrial = 1:S.GUI.OriginalRewardsBlockLength
    
    S = BpodParameterGUI_with_tabs('sync', S); % Sync parameters with BpodParameterGUI plugin
    % update training parameters if needed
    S.PunishDelay = S.GUI.PunishDelay; % Extra time after there is a wrong poke
    S.CueDelay = S.GUI.CenterPortDuration; % How long the mouse must poke in the center to activate the goal port
    
    %% Update reward amounts
    R = GetValveTimes(S.GUI.RewardAmount, [1 3]);    
    LeftValveTime = R(1); 
    RightValveTime = R(2);
    % hack the contingency switching for the plotting
    switch S.RewardChangeBlock
        case 0
            RewChOneIdx = [RewChOneIdx,currentTrial];
        case 1
            RewChTwoIdx = [RewChTwoIdx,currentTrial];
        case 5
            RewChTwoIdx = [RewChTwoIdx,currentTrial];
    end

    
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
                
            case 4 % Aud_Psycho
                % Not implemented yet!!!!!!
                disp('Bias correction not implemented for psychometric version')
                % Create vector of probabilities to generate the psychometric curve trials
                % In this case we have 7 different trial types
                %TrialsProb = [0.143, 0.1428, 0.1428, 0.1428, 0.1428, 0.1428, 0.143];
                %TrialSequence = WeightedRandomTrials(TrialsProb, MaxTrials);
                TrialSequencePiece = TrialSequence(currentTrial:currentTrial+(S.BiasWindow-1));
        end
        
        % Change it in the trial sequence and trial side
        TrialSequence(currentTrial:currentTrial+(S.BiasWindow-1)) = TrialSequencePiece;
        TrialSide(currentTrial:currentTrial+(S.BiasWindow-1)) = ConvertVector(TrialSequence(currentTrial:currentTrial+(S.BiasWindow-1)));

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
            WrongSideCondition = 'Punish';
            EarlyWithdrawalCondition = 'WaitForPoke';
        case 3 % Punish wrong side and early withdrawal
            WrongSideCondition = 'Punish';
            EarlyWithdrawalCondition = 'EarlyWithdrawal'; % Trial ends
    end   
       
    % Independent opto-stimulation
    switch OptoStim(currentTrial)
        case 0 % No opto
            OptoCondition = 0;
            
        case 1 % Opto
            OptoCondition = 1; % BNC number 1
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
            end  
        case 2 % go Right
            PortID = 'PWM3';
            LeftPokeAction = WrongSideCondition;
            RightPokeAction = 'RightReward';
            
            switch RewardSequence(currentTrial)
                case 2 % Omit reward (goes to punish state)
                    RightPokeAction = 'Omission';
            end  
    end
    

    % Independent training level
    switch S.GUI.TrainingLevel
        case 1 % Habituation
            S.ResponseTime = S.GUI.ResponseTime; % Time to respond, otherwise incomplete trial
            WaitForResponseOutput = {'PWM1', S.LedIntensity, 'PWM3', S.LedIntensity}; %LED ON
            %WaitForResponseOutput = {}; %LED OFF (otherwise light might not be recognized as important)
            MiddlePortOutput = {'PWM2', S.LedIntensity, 'BNCState', OptoCondition};
            %override the wrong side
            LeftPokeAction = 'LeftReward';
            RightPokeAction = 'RightReward';
            WaitForPokeOutput = {'PWM2', S.LedIntensity, 'BNCState', 0}; %middle light ON, TTL to sync with OpenEphys
            EarlyWithdrawalOutput = {};
            ModCOTSound = ZeroSound; % For the plotting
         
        case 2 % Visual
            S.ResponseTime = S.GUI.ResponseTime;
            WaitForResponseOutput = {PortID, S.LedIntensity}; %LED ON 
            MiddlePortOutput = {'PWM2', S.LedIntensity, 'BNCState', OptoCondition};
            WaitForPokeOutput = {'PWM2', S.LedIntensity, 'BNCState', 0};
            EarlyWithdrawalOutput = {};
            ModCOTSound = ZeroSound; % For the plotting
 
        case {3, 4} % Auditory
            % Determine trial-specific SoundIDs and parameters  
            COTSound = CloudOfTones(sampRate, duration, rampTime, amplitude, HighFreq, LowFreq, HighPerc, LowPerc, subduration, suboverlap);
            % Modulate amplitude randomly
            modAmp = randomAmplitudeModulation(duration,sampRate,15,0.8);
            ModCOTSound = modAmp.*COTSound;
            SoundID = 1;
            PsychToolboxSoundServer('Load', SoundID, ModCOTSound);
    
            S.ResponseTime = S.GUI.ResponseTime;
            WaitForResponseOutput = {};
            MiddlePortOutput = {'PWM2', S.LedIntensity, 'SoftCode', SoundID, 'BNCState', OptoCondition};
            WaitForPokeOutput = {'PWM2', S.LedIntensity, 'BNCState', 0, 'SoftCode', 255}; % Stop sounds
            EarlyWithdrawalOutput = {'SoftCode', 255};
    end    
    
    %% Assemble state matrix
    sma = NewStateMachine(); 
    sma = AddState(sma, 'Name', 'TrialStart', ...
        'Timer', 0.01, ...
        'StateChangeConditions', {'Tup', 'WaitForPoke'}, ...
        'OutputActions', {'BNCState', 2}); 
    %'WaitForPoke' is the initial state.
    sma = AddState(sma, 'Name', 'WaitForPoke', ...
        'Timer', 0, ...
        'StateChangeConditions', {'Port2In', 'CueDelay'}, ...
        'OutputActions', WaitForPokeOutput); 
    %'CueDelay' is the second automatic state
    %If the mouse does not hold the head enough time in the central port,
    %it jumps back to 'WaitForPoke'. If 'CueDelay' timer is reached, it jumps to
    %'WaitForPortOut'.
    sma = AddState(sma, 'Name', 'CueDelay', ...
        'Timer', S.CueDelay, ...
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
        'StateChangeConditions', {'Tup', 'Drinking'}, ...
        'OutputActions', {'ValveState', 1}); 
    sma = AddState(sma, 'Name', 'RightReward', ...
        'Timer', RightValveTime, ...
        'StateChangeConditions', {'Tup', 'Drinking'},...
        'OutputActions', {'ValveState', 4}); 
    %Drinking is a mock state to check that the animal has drunk. It is
    %used to plot stuff and calculate correct trials
    sma = AddState(sma, 'Name', 'Drinking', ...
        'Timer', 0, ...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {});
    %'Punish' finishes the trial after a delay
    sma = AddState(sma, 'Name', 'Punish', ...
        'Timer', S.PunishDelay, ...
        'StateChangeConditions', {'Tup', 'exit'}, ...
        'OutputActions', {}); %think about outputing something
    %'Omission' acts as if it's a reward state but no valve 
    sma = AddState(sma, 'Name', 'Omission', ...
        'Timer', RightValveTime, ...
        'StateChangeConditions', {'Tup', 'Drinking'},...
        'OutputActions', {});  
    %'EarlyWithdrawal finishes the trial
    sma = AddState(sma, 'Name', 'EarlyWithdrawal', ...
        'Timer', 0, ...
        'StateChangeConditions', {'Tup', 'exit'}, ...
        'OutputActions', EarlyWithdrawalOutput);
    
    SendStateMachine(sma);
    
    RawEvents = RunStateMachine;
    
    %% Calculate stuff, save and update plots
    
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        
        %BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        BpodSystem.Data.TrialSequence(currentTrial) = TrialSequence(currentTrial); % Adds the trial type of the current trial to data
        BpodSystem.Data.TrialHighPerc(currentTrial) = HighPerc; %'difficulty'
        BpodSystem.Data.TrialSide(currentTrial) = TrialSide(currentTrial);
        BpodSystem.Data.Stimulus{currentTrial} = ModCOTSound; %save the sound
        BpodSystem.Data.OptoStim(currentTrial) = OptoStim(currentTrial); %opto stimulation
        BpodSystem.Data.ChosenSide(currentTrial) = CalculateChosenSide(BpodSystem.Data.RawEvents.Trial{currentTrial}, TrialSide(currentTrial)); %mouse response
        BpodSystem.Data.Outcomes(currentTrial) = CalculateOutcome(BpodSystem.Data.RawEvents.Trial{currentTrial}.States); %outcome of trial
        BpodSystem.Data.ResponseTime(currentTrial) = CalculateResponseTime(BpodSystem.Data.RawEvents.Trial{currentTrial}.States); %get response time
        BpodSystem.Data.FirstPoke(currentTrial) = CalculateFirstPoke(BpodSystem.Data.RawEvents.Trial{currentTrial}); %get the first poke (1 L, 2 R)
        BpodSystem.Data.FirstPokeCorrect(currentTrial) = IsFirstPokeCorrect(BpodSystem.Data.FirstPoke(currentTrial), TrialSide(currentTrial)); %get the first poke (1correct and 0incorrect)

        UpdateTotalRewardDisplay(S.GUI.RewardAmount, currentTrial);
        SideOutcomePlotMod(BpodSystem.GUIHandles.SideOutcomePlot,'update',BpodSystem.Data.nTrials+1,2-TrialSide,BpodSystem.Data.Outcomes);
        SoundPlot(BpodSystem.GUIHandles.SoundPlot, 'update', ModCOTSound);        
        SoundSpectPlot(BpodSystem.GUIHandles.SoundSpectPlot, 'update', ModCOTSound);
        % update the psychometric curve plots
        % if displaying contingency switch

        switch S.RewardChangeBlock
            case 0
                PsychPerformancePlot(BpodSystem.GUIHandles.PsychPercPlotContOne, 'update', S.PercVect, BpodSystem.Data.TrialHighPerc(RewChOneIdx), BpodSystem.Data.FirstPoke(RewChOneIdx), BpodSystem.Data.OptoStim(RewChOneIdx));
            case 1
                PsychPerformancePlot_Two(BpodSystem.GUIHandles.PsychPercPlotContTwo, 'update', S.PercVect, BpodSystem.Data.TrialHighPerc(RewChTwoIdx), BpodSystem.Data.FirstPoke(RewChTwoIdx), BpodSystem.Data.OptoStim(RewChTwoIdx));
            case 5
                PsychPerformancePlot_Two(BpodSystem.GUIHandles.PsychPercPlotContTwo, 'update', S.PercVect, BpodSystem.Data.TrialHighPerc(RewChTwoIdx), BpodSystem.Data.FirstPoke(RewChTwoIdx), BpodSystem.Data.OptoStim(RewChTwoIdx));
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
MaxSwitchedTrials = 1500;

% we are now in the uneven reward amounts part of the session
if rand > 0.5
    left_side_large = 1;
else
    left_side_large = 2;
end
    
for currentTrial = S.GUI.OriginalRewardsBlockLength + 1:MaxSwitchedTrials
    
    S = BpodParameterGUI_with_tabs('sync', S); % Sync parameters with BpodParameterGUI plugin
    % update training parameters if needed
    S.PunishDelay = S.GUI.PunishDelay; % Extra time after there is a wrong poke
    S.CueDelay = S.GUI.CenterPortDuration; % How long the mouse must poke in the center to activate the goal port
    
    %% Update reward amounts
    switch left_side_large
        case 1 %reward larger on left
            S.RewardChangeBlock = 1;
            R(1) = GetValveTimes(S.GUI.RewardAmount * 3, 1);
            R(2) = GetValveTimes(S.GUI.RewardAmount, 3);
            disp(['reward on L: ', num2str(S.GUI.RewardAmount * 3),' reward on R: ', num2str(S.GUI.RewardAmount)])
        case 2 % reward larger on right
            S.RewardChangeBlock = 5; % to make compatible with old code 
            R(1) = GetValveTimes(S.GUI.RewardAmount, 1);
            R(2) = GetValveTimes(S.GUI.RewardAmount * 3, 3);
            disp(['reward on L: ', num2str(S.GUI.RewardAmount),' reward on R: ', num2str(S.GUI.RewardAmount * 3)])
    end
    
    LeftValveTime = R(1); 
    RightValveTime = R(2);
    % hack the contingency switching for the plotting
    switch S.RewardChangeBlock
        case 0
            RewChOneIdx = [RewChOneIdx,currentTrial];
        case 1
            RewChTwoIdx = [RewChTwoIdx,currentTrial];
        case 5
            RewChTwoIdx = [RewChTwoIdx,currentTrial];
    end
    
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
                
            case 4 % Aud_Psycho
                % Not implemented yet!!!!!!
                disp('Bias correction not implemented for psychometric version')
                % Create vector of probabilities to generate the psychometric curve trials
                % In this case we have 7 different trial types
                %TrialsProb = [0.143, 0.1428, 0.1428, 0.1428, 0.1428, 0.1428, 0.143];
                %TrialSequence = WeightedRandomTrials(TrialsProb, MaxTrials);
                TrialSequencePiece = TrialSequence(currentTrial:currentTrial+(S.BiasWindow-1));
        end
        
        % Change it in the trial sequence and trial side
        TrialSequence(currentTrial:currentTrial+(S.BiasWindow-1)) = TrialSequencePiece;
        TrialSide(currentTrial:currentTrial+(S.BiasWindow-1)) = ConvertVector(TrialSequence(currentTrial:currentTrial+(S.BiasWindow-1)));

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
            WrongSideCondition = 'Punish';
            EarlyWithdrawalCondition = 'WaitForPoke';
        case 3 % Punish wrong side and early withdrawal
            WrongSideCondition = 'Punish';
            EarlyWithdrawalCondition = 'EarlyWithdrawal'; % Trial ends
    end   
       
    % Independent opto-stimulation
    switch OptoStim(currentTrial)
        case 0 % No opto
            OptoCondition = 0;
            
        case 1 % Opto
            OptoCondition = 1; % BNC number 1
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
            end  
        case 2 % go Right
            PortID = 'PWM3';
            LeftPokeAction = WrongSideCondition;
            RightPokeAction = 'RightReward';
            
            switch RewardSequence(currentTrial)
                case 2 % Omit reward (goes to punish state)
                    RightPokeAction = 'Omission';
            end  
    end
    

    % Independent training level
    switch S.GUI.TrainingLevel
        case 1 % Habituation
            S.ResponseTime = S.GUI.ResponseTime; % Time to respond, otherwise incomplete trial
            WaitForResponseOutput = {'PWM1', S.LedIntensity, 'PWM3', S.LedIntensity}; %LED ON
            %WaitForResponseOutput = {}; %LED OFF (otherwise light might not be recognized as important)
            MiddlePortOutput = {'PWM2', S.LedIntensity, 'BNCState', OptoCondition};
            %override the wrong side
            LeftPokeAction = 'LeftReward';
            RightPokeAction = 'RightReward';
            WaitForPokeOutput = {'PWM2', S.LedIntensity, 'BNCState', 0}; %middle light ON, TTL to sync with OpenEphys
            EarlyWithdrawalOutput = {};
            ModCOTSound = ZeroSound; % For the plotting
         
        case 2 % Visual
            S.ResponseTime = S.GUI.ResponseTime;
            WaitForResponseOutput = {PortID, S.LedIntensity}; %LED ON 
            MiddlePortOutput = {'PWM2', S.LedIntensity, 'BNCState', OptoCondition};
            WaitForPokeOutput = {'PWM2', S.LedIntensity, 'BNCState', 0};
            EarlyWithdrawalOutput = {};
            ModCOTSound = ZeroSound; % For the plotting
 
         case {3, 4} % Auditory
            % Determine trial-specific SoundIDs and parameters  
            COTSound = CloudOfTones(sampRate, duration, rampTime, amplitude, HighFreq, LowFreq, HighPerc, LowPerc, subduration, suboverlap);
            % Modulate amplitude randomly
            modAmp = randomAmplitudeModulation(duration,sampRate,15,0.8);
            ModCOTSound = modAmp.*COTSound;
            SoundID = 1;
            PsychToolboxSoundServer('Load', SoundID, ModCOTSound);
    
            S.ResponseTime = S.GUI.ResponseTime;
            WaitForResponseOutput = {};
            MiddlePortOutput = {'PWM2', S.LedIntensity, 'SoftCode', SoundID, 'BNCState', OptoCondition};
            WaitForPokeOutput = {'PWM2', S.LedIntensity, 'BNCState', 0, 'SoftCode', 255}; % Stop sounds
            EarlyWithdrawalOutput = {'SoftCode', 255};
    end    
    
    %% Assemble state matrix
    sma = NewStateMachine(); 
    sma = AddState(sma, 'Name', 'TrialStart', ...
        'Timer', 0.01, ...
        'StateChangeConditions', {'Tup', 'WaitForPoke'}, ...
        'OutputActions', {'BNCState', 2}); 
    %'WaitForPoke' is the initial state.
    sma = AddState(sma, 'Name', 'WaitForPoke', ...
        'Timer', 0, ...
        'StateChangeConditions', {'Port2In', 'CueDelay'}, ...
        'OutputActions', WaitForPokeOutput); 
    %'CueDelay' is the second automatic state
    %If the mouse does not hold the head enough time in the central port,
    %it jumps back to 'WaitForPoke'. If 'CueDelay' timer is reached, it jumps to
    %'WaitForPortOut'.
    sma = AddState(sma, 'Name', 'CueDelay', ...
        'Timer', S.CueDelay, ...
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
        'StateChangeConditions', {'Tup', 'Drinking'}, ...
        'OutputActions', {'ValveState', 1}); 
    sma = AddState(sma, 'Name', 'RightReward', ...
        'Timer', RightValveTime, ...
        'StateChangeConditions', {'Tup', 'Drinking'},...
        'OutputActions', {'ValveState', 4}); 
    %Drinking is a mock state to check that the animal has drunk. It is
    %used to plot stuff and calculate correct trials
    sma = AddState(sma, 'Name', 'Drinking', ...
        'Timer', 0, ...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {});
    %'Punish' finishes the trial after a delay
    sma = AddState(sma, 'Name', 'Punish', ...
        'Timer', S.PunishDelay, ...
        'StateChangeConditions', {'Tup', 'exit'}, ...
        'OutputActions', {}); %think about outputing something
    %'Omission' acts as if it's a reward state but no valve 
    sma = AddState(sma, 'Name', 'Omission', ...
        'Timer', RightValveTime, ...
        'StateChangeConditions', {'Tup', 'Drinking'},...
        'OutputActions', {});  
    %'EarlyWithdrawal finishes the trial
    sma = AddState(sma, 'Name', 'EarlyWithdrawal', ...
        'Timer', 0, ...
        'StateChangeConditions', {'Tup', 'exit'}, ...
        'OutputActions', EarlyWithdrawalOutput);
    
    SendStateMachine(sma);
    
    RawEvents = RunStateMachine;
    
    %% Calculate stuff, save and update plots
    
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        
        %BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        BpodSystem.Data.TrialSequence(currentTrial) = TrialSequence(currentTrial); % Adds the trial type of the current trial to data
        BpodSystem.Data.TrialHighPerc(currentTrial) = HighPerc; %'difficulty'
        BpodSystem.Data.TrialSide(currentTrial) = TrialSide(currentTrial);
        BpodSystem.Data.Stimulus{currentTrial} = ModCOTSound; %save the sound
        BpodSystem.Data.OptoStim(currentTrial) = OptoStim(currentTrial); %opto stimulation
        BpodSystem.Data.ChosenSide(currentTrial) = CalculateChosenSide(BpodSystem.Data.RawEvents.Trial{currentTrial}, TrialSide(currentTrial)); %mouse response
        BpodSystem.Data.Outcomes(currentTrial) = CalculateOutcome(BpodSystem.Data.RawEvents.Trial{currentTrial}.States); %outcome of trial
        BpodSystem.Data.ResponseTime(currentTrial) = CalculateResponseTime(BpodSystem.Data.RawEvents.Trial{currentTrial}.States); %get response time
        BpodSystem.Data.FirstPoke(currentTrial) = CalculateFirstPoke(BpodSystem.Data.RawEvents.Trial{currentTrial}); %get the first poke (1 L, 2 R)
        BpodSystem.Data.FirstPokeCorrect(currentTrial) = IsFirstPokeCorrect(BpodSystem.Data.FirstPoke(currentTrial), TrialSide(currentTrial)); %get the first poke (1correct and 0incorrect)

        UpdateTotalRewardDisplay(S.GUI.RewardAmount, currentTrial);
        SideOutcomePlotMod(BpodSystem.GUIHandles.SideOutcomePlot,'update',BpodSystem.Data.nTrials+1,2-TrialSide,BpodSystem.Data.Outcomes);
        SoundPlot(BpodSystem.GUIHandles.SoundPlot, 'update', ModCOTSound);        
        SoundSpectPlot(BpodSystem.GUIHandles.SoundSpectPlot, 'update', ModCOTSound);
        % update the psychometric curve plots
        % if displaying contingency switch
        switch S.RewardChangeBlock
            case 0
                PsychPerformancePlot(BpodSystem.GUIHandles.PsychPercPlotContOne, 'update', S.PercVect, BpodSystem.Data.TrialHighPerc(RewChOneIdx), BpodSystem.Data.FirstPoke(RewChOneIdx), BpodSystem.Data.OptoStim(RewChOneIdx));
            case 1
                PsychPerformancePlot_Two(BpodSystem.GUIHandles.PsychPercPlotContTwo, 'update', S.PercVect, BpodSystem.Data.TrialHighPerc(RewChTwoIdx), BpodSystem.Data.FirstPoke(RewChTwoIdx), BpodSystem.Data.OptoStim(RewChTwoIdx));
            case 5
                PsychPerformancePlot_Two(BpodSystem.GUIHandles.PsychPercPlotContTwo, 'update', S.PercVect, BpodSystem.Data.TrialHighPerc(RewChTwoIdx), BpodSystem.Data.FirstPoke(RewChTwoIdx), BpodSystem.Data.OptoStim(RewChTwoIdx));
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
        if isnan(Data.States.Drinking(1)) && isnan(Data.States.Punish(1))
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
    if ~isnan(State.Drinking(1))
        Outcome = 1;
    elseif ~isnan(State.Punish(1))
        Outcome = 0;
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
    if ~isnan(BpodSystem.Data.RawEvents.Trial{currentTrial}.States.Drinking(1))
        TotalRewardDisplay('add', RewardAmount);
    end

function Outcome = CalculateChosenSide(Data, goal)
    % get the side selected by the animal
    % handle the condition where the animal does not respond
    Outcome = NaN;
    if goal==1 %goal is left
        if ~isnan(Data.States.Drinking(1))
            Outcome = 1; %it went to the left
        elseif ~isnan(Data.States.Punish(1))
            Outcome = 2; %it went to the right
        end
    elseif goal==2 %goal is right
        if ~isnan(Data.States.Drinking(1))
            Outcome = 2; %it went to the right
        elseif ~isnan(Data.States.Punish(1))
            Outcome = 1; %it went to the left
        end
    end
    
function OutVector = ConvertVector(InVector)
    % TrialTypes 1,2,3 are poke left
    % TrialTypes 5,6,7 are poke right
    % TrialType 4 is random
    OutVector = ones(size(InVector));
    OutVector(1,InVector>4) = 2;
    OutVector(1,InVector==4) = randi([1, 2], 1);

    

