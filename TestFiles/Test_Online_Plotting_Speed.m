function Test_Online_Plotting_Speed

global BpodSystem

%load test data
load 'C:\Users\herny'\Desktop\SWC\Data\Behavioural_Data\Bpod_data\Two_Alternative_Choice\'Session Data'\T02_Two_Alternative_Choice_20190308_172624.mat

tic

%%
BpodSystem.Data.TrialSequence = []; % The trial type of each trial completed will be added here.
BpodSystem.Data.TrialSide = []; % To store the rewarded side (2 means R, 1 means L)
BpodSystem.Data.Stimulus = {}; % To store the presented stimulus
BpodSystem.Data.TrialHighPerc = []; % To store the 'difficulty' of the trial.
BpodSystem.Data.ChosenSide = []; % To store the side chosen by the animal. (2 means R, 1 means L)
BpodSystem.Data.OptoStim = []; % To store the stimulated trial. (0 means no stimulation, 1 means yes)
BpodSystem.Data.Outcomes = []; % To store the outcome of the trial (0 means punish, 1 means success, 2 means early withdrawal, 3 means something else)
BpodSystem.Data.ResponseTime = []; % Time taken to respond
BpodSystem.Data.FirstPoke = []; %get the first poke (1 left, 2 right, NaN if no first poke happened)
BpodSystem.Data.FirstPokeCorrect = []; %get if the first poke is correct (1 correct, 0 incorrect, NaN if no first poke happened)

TrialSide = SessionData.TrialSide;
OptoStim = SessionData.OptoStim;
ZeroSound = zeros(1,192000*0.5);
PercVect = [98, 82, 66, 50, 34, 18, 2];

%% Initialize plots

MultiFigureHM = figure('Position', [10 10 1000 600],'name','Ojete','numbertitle','off', 'MenuBar', 'none', 'Resize', 'on');
%sgtitle(name); % Only for Matlab2018b

BpodSystem.GUIHandles.SideOutcomePlot = subplot(5,6,[1,2,3,4,5,6]);
SideOutcomePlotMod(BpodSystem.GUIHandles.SideOutcomePlot,'init',2-TrialSide,OptoStim);

%Spectrogram and sound wave
figure(MultiFigureHM);
BpodSystem.GUIHandles.SoundPlot = subplot(5,6,[7,8]);
SoundPlot(BpodSystem.GUIHandles.SoundPlot, 'init', ZeroSound);
BpodSystem.GUIHandles.SoundSpectPlot = subplot(5,6,[13,14]);
SoundSpectPlot(BpodSystem.GUIHandles.SoundSpectPlot, 'init', ZeroSound);

%Psychometric performance
figure(MultiFigureHM);
BpodSystem.GUIHandles.PsychPercPlot = subplot(5,6,[9,10,15,16]);
PsychPerformancePlot(BpodSystem.GUIHandles.PsychPercPlot, 'init', PercVect);

%Correct trials
figure(MultiFigureHM);
BpodSystem.GUIHandles.CorrectPlot = subplot(5,6,[11,12,17,18]);
CorrectPlot(BpodSystem.GUIHandles.CorrectPlot, 'init', BpodSystem.Data.TrialSide, BpodSystem.Data.ChosenSide, BpodSystem.Data.OptoStim);

%Response time
figure(MultiFigureHM);
BpodSystem.GUIHandles.ResponseTimePlot = subplot(5,6,[19,20,25,26]);
ResponseTimePlot(BpodSystem.GUIHandles.ResponseTimePlot, 'init', BpodSystem.Data.ResponseTime, BpodSystem.Data.FirstPokeCorrect, 0);

%Correct first poke
figure(MultiFigureHM);
BpodSystem.GUIHandles.CorrectFirstPoke = subplot(5,6,[21,22,27,28]);
CorrectFirstPokePlot(BpodSystem.GUIHandles.CorrectFirstPoke, 'init', BpodSystem.Data.FirstPokeCorrect);

toc

%% Update
%trialsToUpdate
for TTU=10:50:500
    disp(TTU)
    BpodSystem.Data = SessionData;
    tic
    SideOutcomePlotMod(BpodSystem.GUIHandles.SideOutcomePlot,'update',TTU+1,2-TrialSide,BpodSystem.Data.Outcomes(1:TTU));
    SoundPlot(BpodSystem.GUIHandles.SoundPlot, 'update', ZeroSound);        
    SoundSpectPlot(BpodSystem.GUIHandles.SoundSpectPlot, 'update', ZeroSound);
    PsychPerformancePlot(BpodSystem.GUIHandles.PsychPercPlot, 'update', PercVect, BpodSystem.Data.TrialHighPerc(1:TTU), BpodSystem.Data.FirstPoke(1:TTU), BpodSystem.Data.OptoStim(1:TTU));
    CorrectPlot(BpodSystem.GUIHandles.CorrectPlot, 'update', BpodSystem.Data.TrialSide(1:TTU), BpodSystem.Data.ChosenSide(1:TTU), BpodSystem.Data.OptoStim(1:TTU));
    ResponseTimePlot(BpodSystem.GUIHandles.ResponseTimePlot, 'update', BpodSystem.Data.ResponseTime(1:TTU), BpodSystem.Data.FirstPokeCorrect(1:TTU), BpodSystem.Data.TrialStartTimestamp(1:TTU));
    CorrectFirstPokePlot(BpodSystem.GUIHandles.CorrectFirstPoke, 'update', BpodSystem.Data.FirstPokeCorrect(1:TTU));
    toc
    pause(.5);
end
