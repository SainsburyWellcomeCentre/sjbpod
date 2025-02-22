function [trialsNames, trialsMatrix, ezTrialsSeq]=Cued_Reward_Phase(S,PhaseName)

switch PhaseName
	case 'RwdAB_PunC' 
        trialsNames={'Cue A Reward','Cue A Omission',...
                     'Cue B Reward','Cue B Omission',...
                     'Cue C Punish','Cue C Omission',...
                     'Uncued Reward','Uncued Punishment'};
        trialsMatrix=[...
%         1.type, 2.proba,                      3.sound, 4.delay,   5.valve,                6.Outcome          7.Marker        8. OptoStimCue     9. Delay OptoStimCue      10.OptoStimRwd
            1,   S.GUI.ProbCueARwd,             1,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,        double('o')     0                   S.GUI.OptoStimCueDelay                    0;...   % CueA: big reward trial
            2,   S.GUI.ProbCueAOmission,        1,    S.GUI.Delay,  S.GUI.OmissionValve, 	S.InterRew,        double('s')     0                   S.GUI.OptoStimCueDelay                    0;...   % CueA: omission
            3,   S.GUI.ProbCueBRwd,             2,    S.GUI.Delay,  S.GUI.RewardValve,   	S.InterRew,        double('s')     0                   S.GUI.OptoStimCueDelay                    0;...   % CueB: omission
            4,   S.GUI.ProbCueBOmission,        2,    S.GUI.Delay,  S.GUI.OmissionValve,    S.InterRew,        double('d')     0                   S.GUI.OptoStimCueDelay                    0;...   % Uncued reward
            5,   S.GUI.ProbCueCPunish,          4,    S.GUI.Delay,  S.GUI.PunishValve,   	S.GUI.PunishTime,  double('o')     0                   S.GUI.OptoStimCueDelay                    0;...   % No Cue + no reward
            6,   S.GUI.ProbCueCOmission,        4,    S.GUI.Delay,  S.GUI.PunishValve,	    S.GUI.PunishTime,  double('d')     0                   S.GUI.OptoStimCueDelay                    0;...
            7,   S.GUI.ProbUncuedRwd,           3,    S.GUI.Delay,  S.GUI.RewardValve,   	S.InterRew,        double('o')     0                   S.GUI.OptoStimCueDelay                    0;...   % No Cue + no reward
            8,   S.GUI.ProbUncuedPunish,        3,    S.GUI.Delay,  S.GUI.PunishValve,	    S.GUI.PunishTime,  double('d')     0                   S.GUI.OptoStimCueDelay                    0];     % (CueA+ Stim) + reward 
         
            easyTrials=[1 1 3 3];
        
	case 'RewardBPunishA' 
        trialsNames={'Cue B Reward','Cue B Omission',...
            'Cue A Punishment','Cue A Omission',...
            'Uncued Reward','Uncued Punishment','Uncued Omission'};
        trialsMatrix=[...
        %  1.type, 2.proba, 3.sound, 4.delay,   5.valve,                6.Outcome         	7.Marker
            1,   S.GUI.ProbCueBRwd ,            2,    S.GUI.Delay,   S.GUI.RewardValve,         S.InterRew,         double('o')    0                      1e-6                    0;...   
            2,   S.GUI.ProbCueBOmission,        2,    S.GUI.Delay,   S.GUI.OmissionValve,       S.InterRew,         double('s')    0                     1e-6                    0;...   
            3,   S.GUI.ProbCueAPunishment,      1,    S.GUI.Delay,   S.GUI.PunishValve,         S.GUI.PunishTime,   double('d')    0                     1e-6                    0;...   
            4,   S.GUI.ProbCueAOmission ,       1,    S.GUI.Delay,   S.GUI.OmissionValve,       S.InterRew,         double('s')    0                     1e-6                    0;...    
            5,   S.GUI.ProbUncuedRwd,           3,    S.GUI.Delay,   S.GUI.RewardValve,         S.InterRew,         double('o')    0                     1e-6                    0;...    
            6,   S.GUI.ProbUncuedPunishment,    3,    S.GUI.Delay,   S.GUI.PunishValve,         S.GUI.PunishTime,   double('d')    0                     1e-6                    0;...
            7,   S.GUI.ProbUncuedOmission,      3,    S.GUI.Delay,   S.GUI.OmissionValve,       S.InterRew,         double('s')    0                     1e-6                    0];
        easyTrials=[1 1 1 1 3 3 3 5 5 5 ];
        
    case 'RewardValues' 
        trialsNames={'Cue A Small Reward','Cue A Inter Reward',...
            'Cue A Omission','Cue B Inter Reward',...
            'Cue B Large Reward','Cue B Omission',...
            'Uncued Inter Reward'};
        trialsMatrix=[...
        %  1.type, 2.proba, 3.sound, 4.delay,   5.valve,                6.Outcome         	7.Marker
            1,   S.GUI.ProbCueASmallRwd,     1,    S.GUI.Delay, S.GUI.RewardValve,  	S.SmallRew,         double('o')     0                    1e-6                    0;...   
            2,   S.GUI.ProbCueAInterRwd,     1,    S.GUI.Delay,	S.GUI.RewardValve,      S.InterRew,         double('d')     0                    1e-6                    0;...   
            3,   S.GUI.ProbCueAOmission,     1,    S.GUI.Delay,	S.GUI.OmissionValve,	S.InterRew,         double('s')     0                    1e-6                    0;...   
            4,   S.GUI.ProbCueBInterRwd,     2,    S.GUI.Delay,	S.GUI.RewardValve,      S.InterRew,         double('o')     0                    1e-6                    0;...    
            5,   S.GUI.ProbCueBLargeRwd,     2,    S.GUI.Delay,	S.GUI.RewardValve,      S.LargeRew,         double('d')     0                    1e-6                    0;...    
            6,   S.GUI.ProbCueBOmission ,    2,    S.GUI.Delay,	S.GUI.OmissionValve,	S.InterRew,         double('s')     0                    1e-6                    0;...
            7,   S.GUI.ProbUncuedInterRwd ,  3,    S.GUI.Delay,	S.GUI.RewardValve,      S.InterRew,         double('o')     0                    1e-6                    0];    
        easyTrials=[1 1 2 3 3 4 5 5];
        
	case 'RewardAPunishBValues' 
        trialsNames={'Cue A Reward','Cue A Punishment','Cue A Omission'...
            'Cue B Reward','Cue B Punishment','Cue B Omission',...
            'Uncued Reward','Uncued Punishment','Uncued Omission'};
        trialsMatrix=[...
        %  1.type, 2.proba, 3.sound, 4.delay, 	5.valve,                6.Outcome         	7.Marker
            1,   S.GUI.ProbCueARwd,             1,    S.GUI.Delay,  S.GUI.RewardValve,  	S.InterRew,         double('o')     0                    1e-6                    0;...   
            2,   S.GUI.ProbCueAPunishment,      1,    S.GUI.Delay,  S.GUI.PunishValve,      S.GUI.PunishTime, 	double('d')     0                    1e-6                    0;... 
            3,   S.GUI.ProbCueAOmission,    	1,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s')     0                    1e-6                    0;...   
            4,   S.GUI.ProbCueBRwd,             2,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,         double('o')     0                    1e-6                    0;...    
            5,   S.GUI.ProbCueBPunishment,      2,    S.GUI.Delay,  S.GUI.PunishValve,      S.GUI.PunishTime, 	double('d')     0                    1e-6                    0;...   
            6,   S.GUI.ProbCueBOmission,        2,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s')     0                    1e-6                    0;... 
            7,   S.GUI.ProbUncuedRwd ,          3,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,         double('o')     0                    1e-6                    0;... 
            8,   S.GUI.ProbUncuedPunishment,    3,    S.GUI.Delay,  S.GUI.PunishValve,      S.GUI.PunishTime,	double('d')     0                    1e-6                    0;... 
            9,   S.GUI.ProbUncuedOmission ,     3,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s')     0                    1e-6                    0 ];
        easyTrials=[1 1 1 1 3 3 3 5 5 5 ];
        
	case 'RewardBPunishAValues' 
        trialsNames={'Cue A Reward','Cue A Punishment','Cue A Omission'...
            'Cue B Reward','Cue B Punishment','Cue B Omission',...
            'Uncued Reward','Uncued Punishment','Uncued Omission'};
        trialsMatrix=[...
        %  1.type, 2.proba, 3.sound, 4.delay, 	5.valve,                6.Outcome         	7.Marker
            1,   S.GUI.ProbCueARwd,             1,    S.GUI.Delay,  S.GUI.RewardValve,  	S.InterRew,         double('o')  0                    1e-6                    0;...   % CueA: big reward trial;...   
            2,   S.GUI.ProbCueAPunishment,      1,    S.GUI.Delay,  S.GUI.PunishValve,      S.GUI.PunishTime, 	double('d')  0                    1e-6                    0;...   % CueA: big reward trial;...   
            3,   S.GUI.ProbCueAOmission,    	1,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s')  0                    1e-6                    0;...   % CueA: big reward trial;...   
            4,   S.GUI.ProbCueBRwd ,            2,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,         double('o')  0                    1e-6                    0;...   % CueA: big reward trial;...    
            5,   S.GUI.ProbCueBPunishment ,     2,    S.GUI.Delay,  S.GUI.PunishValve,      S.GUI.PunishTime, 	double('d')  0                    1e-6                    0;...   % CueA: big reward trial;...    
            6,   S.GUI.ProbCueBOmission,        2,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s')  0                    1e-6                    0;...   % CueA: big reward trial;...
            7,   S.GUI.ProbUncuedRwd,           3,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,         double('o')  0                    1e-6                    0;...   % CueA: big reward trial;...
            8,   S.GUI.ProbUncuedPunishment,    3,    S.GUI.Delay,  S.GUI.PunishValve,      S.GUI.PunishTime,	double('d')  0                    1e-6                    0;...   % CueA: big reward trial;...
            9,   S.GUI.ProbUncuedOmission ,     3,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s')  0                    1e-6                    0]; 
        easyTrials=[1 1 1 1 3 3 3 5 5 5 ];

  
    case 'RewardA'  % training
        trialsNames={'Cue A Reward','Cue A Omission',...
                     'Cue B Omission','Uncued Reward',...
                     'Uncued Omission', 'OptoStim at CueA',...
                     'OptoStim at CueB','OptoStim at Reward',...
                     'OptoStim at Omission'};
       trialsMatrix=[...
%         1.type, 2.proba,                      3.sound, 4.delay,   5.valve,                6.Outcome      7.Marker        8. OptoStimCue     9. Delay OptoStimCue      10.OptoStimRwd
            1,   S.GUI.ProbCueARwd,             1,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,    double('o')     0                   S.GUI.OptoStimCueDelay                    0;...   % CueA: big reward trial
            2,   S.GUI.ProbCueAOmission,        1,    S.GUI.Delay,  S.GUI.OmissionValve, 	S.InterRew,    double('s')     0                   S.GUI.OptoStimCueDelay                    0;...   % CueA: omission
            3,   S.GUI.ProbCueBOmission,        2,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,    double('s')     0                   S.GUI.OptoStimCueDelay                    0;...   % CueB: omission
            4,   S.GUI.ProbUncuedRwd,           3,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,    double('o')     0                   S.GUI.OptoStimCueDelay                    0;...   % Uncued reward
            5,   S.GUI.ProbUncuedOmission  ,    3,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,    double('s')     0                   S.GUI.OptoStimCueDelay                    0;...   % No Cue + no reward
            6,   S.GUI.ProbCueAOpto,            1,    S.GUI.Delay,  S.GUI.RewardValve,	S.InterRew,    double('s')     2                   S.GUI.OptoStimCueDelay                       0;...   % (CueA+ Stim) + reward 
            7,   S.GUI.ProbCueBOpto,            2,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,    double('s')     2                   S.GUI.OptoStimCueDelay                       0;...   % (CueB+ Stim) + omission 
            8,   S.GUI.ProbCueARwdOpto,         1,    S.GUI.Delay,  S.GUI.RewardValve,	S.InterRew,    double('s')     0                   S.GUI.OptoStimCueDelay                    2;...   %  CueA  + (reward + stim)
            9,   S.GUI.ProbCueBOmissionOpto,    2,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,    double('s')     0                   S.GUI.OptoStimCueDelay                    2 ];    %  CueB  + (omission + stim)

        easyTrials=[1 1 1 1 3 3 4 4];

          
    case 'RewardARewardB'  % training
        trialsNames={'Cue A Reward', 'Cue A Omission',...
                     'Cue B Reward', 'Cue B Omission',...
                     'Uncued Reward', 'Uncued Omission',... 
                     'OptoStim at CueA', 'OptoStim at CueB',...
                     'OptoStim at Reward', 'OptoStim at Omission', 'OptosStim Uncued Reward'};
                     
       trialsMatrix=[...
%         1.type, 2.proba,                      3.sound, 4.delay,   5.valve,                6.Outcome      7.Marker        8. OptoStimCue     9. Delay OptoStimCue      10.OptoStimRwd
            1,   S.GUI.ProbCueARwd,             1,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,    double('o')     1                   S.GUI.OptoStimCueDelay                    0;...   % CueA: big reward trial
            2,   S.GUI.ProbCueAOmission,        1,    S.GUI.Delay,  S.GUI.OmissionValve, 	S.InterRew,    double('s')     1                   S.GUI.OptoStimCueDelay                    0;...   % CueA: omission
            3,   S.GUI.ProbCueBRwd,             2,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,    double('o')     1                   S.GUI.OptoStimCueDelay                    0;...   
            4,   S.GUI.ProbCueBOmission,        2,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,    double('s')     1                   S.GUI.OptoStimCueDelay                    0;...   % CueB: omission
            5,   S.GUI.ProbUncuedRwd,           3,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,    double('o')     1                   S.GUI.OptoStimCueDelay                    0;...   % Uncued reward
            6,   S.GUI.ProbUncuedOmission  ,    3,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,    double('s')     1                   S.GUI.OptoStimCueDelay                    0;...   % No Cue + no reward
            7,   S.GUI.ProbCueAOpto,            1,    S.GUI.Delay,  S.GUI.RewardValve,	    S.InterRew,    double('s')     3                   S.GUI.OptoStimCueDelay                    0;...   % (CueA+ Stim) + reward 
            8,   S.GUI.ProbCueBOpto,            2,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,    double('s')     3                   S.GUI.OptoStimCueDelay                    0;...   % (CueB+ Stim) + omission 
            9,   S.GUI.ProbCueARwdOpto,         1,    S.GUI.Delay,  S.GUI.RewardValve,	    S.InterRew,    double('s')     1                   S.GUI.OptoStimCueDelay                    2;...   %  CueA  + (reward + stim)
            10,  S.GUI.ProbCueBOmissionOpto,    2,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,    double('s')     1                   S.GUI.OptoStimCueDelay                    2;...    %  CueB  + (omission + stim)
            11,  S.GUI.ProbUncuedRwdOpto,       3,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,    double('o')     3                   S.GUI.OptoStimCueDelay                    0];
        easyTrials=[];
    case 'RewardB'
        trialsNames={'Cue A Omission','Cue B Reward',...
                     'Cue B Omission','Uncued Reward',...
                     'Uncued Omission','blank'};
        trialsMatrix=[...
        % 1.type, 2.proba, 3.sound, 4.delay,    5.valve,                6.Outcome         	7.Marker
            1,   S.GUI.ProbCueAOmission,        1,    S.GUI.Delay,  S.GUI.OmissionValve,    S.InterRew,         double('s')  0                    1e-6                    0;...   % CueA: big reward trial ;...   
            2,   S.GUI.ProbCueBRwd ,            2,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,         double('o')  0                    1e-6                    0;...   % CueA: big reward trial;...   
            3,   S.GUI.ProbCueBOmission ,       2,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s')  0                    1e-6                    0;...   % CueA: big reward trial;...   
            4,   S.GUI.ProbUncuedRwd,           3,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,         double('o')  0                    1e-6                    0;...   % CueA: big reward trial;...    
            5,   S.GUI.ProbUncuedOmission,      3,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s')  0                    1e-6                    0;...   % CueA: big reward trial;...    
            6,   S.GUI.ProbBlank,               3,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s')  0                    1e-6                    0]    % CueA: big reward trial];
        easyTrials=[1 1 2 2 2 2 4 4];
    
    case 'RewardACBValues'
        trialsNames={'Cue A Reward','Cue A Omission',...
                     'Cue B Reward','Cue B Omission',...
                     'Cue C Reward','Cue C Omission'};
        trialsMatrix=[...
        % 1.type, 2.proba, 3.sound, 4.delay,    5.valve,                6.Outcome         	7.Marker
            1,    S.GUI.ProbCueARwd ,               1,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,        double('o')  0                    1e-6                    0;...   % CueA: big reward trial;...   
            2,    S.GUI.ProbCueAOmission ,          1,    S.GUI.Delay,  S.GUI.OmissionValve,    S.InterRew,        double('s')  0                    1e-6                    0;...   % CueA: big reward trial;...   
            3,    S.GUI.ProbCueBRwd,                4,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,        double('o')  0                    1e-6                    0;...   % CueA: big reward trial;...   
            4,    S.GUI.ProbCueBOmission ,          4,    S.GUI.Delay,  S.GUI.OmissionValve,    S.InterRew,        double('s')  0                    1e-6                    0;...   % CueA: big reward trial;...    
            5,    S.GUI.ProbCueCRwd ,               2,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,        double('o')  0                    1e-6                    0;...   % CueA: big reward trial;...    
            6,    S.GUI.ProbCueCOmission,           2,    S.GUI.Delay,  S.GUI.OmissionValve,    S.InterRew,        double('s')  0                    1e-6                    0]   % CueA: big reward trial];
        easyTrials=[1 1 2 3 3 4 5 5];
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
