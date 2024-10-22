function [trialsNames, trialsMatrix, ezTrialsSeq]=Cued_Puff_Phase(S,PhaseName)

switch PhaseName

    case 'PuffA'  % training
        trialsNames={'Cue A Puff','Cue A Omission',...
                     'Cue B Omission','Uncued Puff',...
                     'Uncued Omission', 'OptoStim at CueA',...
                     'OptoStim at CueB'};
       trialsMatrix=[...
%         1.type, 2.proba,                      3.sound, 4.delay,   5.valve,                6.Outcome      7.Marker        8. OptoStimCue     9. Delay OptoStimCue      10.OptoStimRwd
            1,   S.GUI.ProbCueAPuff,             1,    S.GUI.Delay,  S.GUI.AirValve,        S.LargePuff,    double('o')     0                   S.GUI.OptoStimCueDelay                    0;...   % CueA: big reward trial
            2,   S.GUI.ProbCueAOmission,         1,    S.GUI.Delay,  S.GUI.OmissionValve, 	S.LargePuff,    double('s')     0                   S.GUI.OptoStimCueDelay                    0;...   % CueA: omission
            3,   S.GUI.ProbCueBOmission,         2,    S.GUI.Delay,  S.GUI.OmissionValve,	S.LargePuff,    double('s')     0                   S.GUI.OptoStimCueDelay                    0;...   % CueB: omission
            4,   S.GUI.ProbUncuedPuff,           3,    S.GUI.Delay,  S.GUI.AirValve,        S.LargePuff,    double('o')     0                   S.GUI.OptoStimCueDelay                    0;...   % Uncued reward
            5,   S.GUI.ProbUncuedOmission  ,     3,    S.GUI.Delay,  S.GUI.OmissionValve,	S.LargePuff,    double('s')     0                   S.GUI.OptoStimCueDelay                    0;...   % No Cue + no reward
            6,   S.GUI.ProbCueAOpto,             1,    S.GUI.Delay,  S.GUI.AirValve,	    S.LargePuff,    double('s')     2                   S.GUI.OptoStimCueDelay                       0;...   % (CueA+ Stim) + reward 
            7,   S.GUI.ProbCueBOpto,             2,    S.GUI.Delay,  S.GUI.OmissionValve,	S.LargePuff,    double('s')     2                   S.GUI.OptoStimCueDelay                       0];...   % (CueB+ Stim) + omission
        easyTrials=[1 1 1 1 3 3 4 4];

          
    case 'BigPuffASmallPuffB'  % training
        trialsNames={'Cue A Puff', 'Cue A Omission',...
                     'Cue B Puff', 'Cue B Omission',...
                     'Uncued Puff', 'Uncued Omission',... 
                     'OptoStim at CueA', 'OptoStim at CueB'};
                     
       trialsMatrix=[...
%         1.type, 2.proba,                      3.sound, 4.delay,   5.valve,                6.Outcome      7.Marker        8. OptoStimCue     9. Delay OptoStimCue      10.OptoStimRwd
            1,   S.GUI.ProbCueAPuff,            1,    S.GUI.Delay,  S.GUI.AirValve,         S.LargePuff,    double('o')     1                   S.GUI.OptoStimCueDelay                    0;...   % CueA: big reward trial
            2,   S.GUI.ProbCueAOmission,        1,    S.GUI.Delay,  S.GUI.OmissionValve, 	S.LargePuff,    double('s')     1                   S.GUI.OptoStimCueDelay                    0;...   % CueA: omission
            3,   S.GUI.ProbCueBPuff,            2,    S.GUI.Delay,  S.GUI.AirValve,         S.SmallPuff,    double('o')     1                   S.GUI.OptoStimCueDelay                    0;...   
            4,   S.GUI.ProbCueBOmission,        2,    S.GUI.Delay,  S.GUI.OmissionValve,	S.LargePuff,    double('s')     1                   S.GUI.OptoStimCueDelay                    0;...   % CueB: omission
            5,   S.GUI.ProbUncuedPuff,          3,    S.GUI.Delay,  S.GUI.AirValve,         S.LargePuff,    double('o')     1                   S.GUI.OptoStimCueDelay                    0;...   % Uncued reward
            6,   S.GUI.ProbUncuedOmission  ,    3,    S.GUI.Delay,  S.GUI.OmissionValve,	S.LargePuff,    double('s')     1                   S.GUI.OptoStimCueDelay                    0;...   % No Cue + no reward
            7,   S.GUI.ProbCueAOpto,            1,    S.GUI.Delay,  S.GUI.AirValve,	        S.LargePuff,    double('s')     3                   S.GUI.OptoStimCueDelay                    0;...   % (CueA+ Stim) + reward 
            8,   S.GUI.ProbCueBOpto,            2,    S.GUI.Delay,  S.GUI.AirValve,	        S.SmallPuff,    double('s')     3                   S.GUI.OptoStimCueDelay                    0];   % (CueB+ Stim) + omission 
        easyTrials=[];
    
    
    end
ezTrialsSeq=easyTrials(randperm(length(easyTrials),length(easyTrials)));



end

%% ------------------- OLD PHASES ---------------------- %%
% 
% case 'Pavlovian1Cue'  % training
%     trialsNames={'Cue A Small Reward ','Cue A Omission',...
%         'Cue A Large Reward','Cue B Omission',...
%         'Uncued Reward','blank'};
%     trialsMatrix=[...
%     %  type, proba,  sound,     delay,       valve,      Pav/Inst 0/1    Marker
%         1,   0.4,     1,    S.GUI.Delay,   S.Valve,    0,              double('o'), S.SmallRew   ;...   % 
%         2,   0.1,     1,    S.GUI.Delay,   S.noValve,  0,              double('s'), S.SmallRew   ;...   % 
%         3,   0.1,     1,    S.GUI.Delay,   S.Valve,    0,              double('d'), S.LargeRew   ;...   % 
%         4,   0.3,     2,    S.GUI.Delay,   S.noValve,  0,              double('s'), S.LargeRew   ;...   % 
%         5,   0.1,     3,    S.GUI.Delay,   S.Valve,    0,              double('o'), S.UncuedRew  ;...   % 
%         6,   0.0,     3,    S.GUI.Delay,   S.Valve,    0,              double('s'), S.UncuedRew];       % 
% 
% case 'Pavlovian2CuesA'
%     trialsNames={'Cue A Small Reward ','Cue A Omission',...
%         'Cue A Large Reward','Cue B Large Reward',...
%         'Cue B Omission','Uncued Small Reward'};
%    trialsMatrix=[...
%     %  type, proba,  sound,     delay,       valve,      Pav/Inst 0/1    Marker
%         1,   0.3,      1,    S.GUI.Delay,   S.Valve,    0,              double('o'), S.SmallRew   ;...   %
%         2,   0.1,      1,    S.GUI.Delay,   S.noValve,  0,              double('s'), S.SmallRew   ;...   %
%         3,   0.1,      1,    S.GUI.Delay,   S.Valve,    0,              double('d'), S.LargeRew   ;...   %
%         4,   0.1,  	   2,    S.GUI.Delay,   S.Valve,    0,              double('d'), S.LargeRew   ;...   %
%         5,   0.3,      2,    S.GUI.Delay,   S.noValve,  0,              double('o'), S.LargeRew   ;...   % 
%         6,   0.1,      3,    S.GUI.Delay,   S.Valve,    0,              double('s'), S.UncuedRew];       % 
% 
%  case 'Pavlovian2CuesB'
%     trialsNames={'Cue A Small Reward ','Cue A Omission',...
%         'Cue A Large Reward','Cue B Large Reward',...
%         'Cue B Omission','Uncued Small Reward'};
%    trialsMatrix=[...
%     %  type, proba,  sound,     delay,       valve,      Pav/Inst 0/1    Marker
%         1,   0.3,      1,    S.GUI.Delay,   S.Valve,    0,              double('o'), S.SmallRew   ;...   %
%         2,   0.1,      1,    S.GUI.Delay,   S.noValve,  0,              double('s'), S.SmallRew   ;...   %
%         3,   0.1,      1,    S.GUI.Delay,   S.Valve,    0,              double('d'), S.LargeRew   ;...   %
%         4,   0.3,  	   2,    S.GUI.Delay,   S.Valve,    0,              double('d'), S.LargeRew   ;...   %
%         5,   0.1,      2,    S.GUI.Delay,   S.noValve,  0,              double('s'), S.LargeRew   ;...   % 
%         6,   0.1,      3,    S.GUI.Delay,   S.Valve,    0,              double('o'), S.UncuedRew];       % 
% 
% case 'Inversion'
%     trialsNames={'Cue A Large Reward ','Cue A Omission',...
%         'Cue B Small Reward','Cue B Omission',...
%         'Uncued Small Reward','blank'};
%    trialsMatrix=[...
%     %  type, proba,  sound,     delay,       valve,      Pav/Inst 0/1    Marker
%         1,   0.35,      1,    S.GUI.Delay,   S.Valve,    0,              double('o'), S.LargeRew   ;...   %
%         2,   0.1,       1,    S.GUI.Delay,   S.noValve,  0,              double('s'), S.LargeRew   ;...   %
%         3,   0.35,      2,    S.GUI.Delay,   S.Valve,    0,              double('v'), S.SmallRew   ;...   %
%         4,   0.1,  	    2,    S.GUI.Delay,   S.noValve,  0,              double('s'), S.SmallRew   ;...   %
%         5,   0.1,       3,    S.GUI.Delay,   S.Valve,    0,              double('o'), S.UncuedRew  ;...   % 
%         6,   0,         3,    S.GUI.Delay,   S.Valve,    0,              double('s'), S.UncuedRew];       %    
