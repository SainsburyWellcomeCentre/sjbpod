%UpdateOnlinePlot 
%Created by EJT 2020
%adapted by SN 2021
%Updates trial tracking plot

function OnlinePlot(BpodSystem, Action, FigureName)
%global BpodSystem


%%
%IntialisePlottingParams
switch Action
    case('Init')
        %update every trial
        BpodSystem.Data.OnlinePlotParams.Reward = nan(1,80);            %Was this particular trial i rewarded?
        BpodSystem.Data.OnlinePlotParams.ReactionTime = nan(1,80);      %Reaction time on each trial. NaN if no response.
        BpodSystem.Data.OnlinePlotParams.Tone = nan (1,80);             %Either Sound 1 or 2
        %update only when conditions are met
        BpodSystem.Data.OnlinePlotParams.FACount = 0;                   %Total number of wrong pokes
        BpodSystem.Data.OnlinePlotParams.CWCount = 0;                   %Total number of correct withhold
        BpodSystem.Data.OnlinePlotParams.CPCount = 0;                   %Total number of correct Pokes
        BpodSystem.Data.OnlinePlotParams.MTCount = 0;                   %Total number of missed reward trials
        BpodSystem.Data.OnlinePlotParams.PokeCount = 0;                 %Total number of responses
        %calculate at the end of every trial
        BpodSystem.Data.OnlinePlotParams.Correct = zeros(1,80);         %Percent of correct responses
        BpodSystem.Data.OnlinePlotParams.ResponseRate = zeros(1,80);    %Percent of incorrect withholding
        
    case('Update')
        % CurrentTrial
        i = BpodSystem.Data.nTrials;
        Sound = BpodSystem.Data.Sound(i);
        TimeOut = BpodSystem.Data.TrialSettings(1).GUI.Timeout;
        
        % For every trial after the first: Calculate reaction time as time between start and end of Cue,
        % count up the cumulative trials, and save which tone it was
        
        RT = BpodSystem.Data.RawEvents.Trial{1,i}.States.Cue(2) - BpodSystem.Data.RawEvents.Trial{1,i}.States.Cue(1);
        BpodSystem.Data.OnlinePlotParams.Tone(1, i) = Sound;
        
        %Save the Reaction Time if its smaller than Timeout
        if RT < TimeOut %i.e. if it didn't time out
            BpodSystem.Data.OnlinePlotParams.ReactionTime (1, i) = RT;
        else %if it did time out, don't count this as a 'reaction'
            BpodSystem.Data.OnlinePlotParams.ReactionTime (1, i) = nan;
        end
        
        %if RT is not-nan, it was a reaction trial
        if ~isnan(BpodSystem.Data.OnlinePlotParams.ReactionTime(1, i))
            %that means the poke count should go one up
            BpodSystem.Data.OnlinePlotParams.PokeCount = BpodSystem.Data.OnlinePlotParams.PokeCount + 1;
            if ~isnan(BpodSystem.Data.RawEvents.Trial{1,i}.States.Water(1))
                % if trial was rewarded, this was a correct-reaction trial
                BpodSystem.Data.OnlinePlotParams.CPCount = BpodSystem.Data.OnlinePlotParams.CPCount + 1;
                BpodSystem.Data.OnlinePlotParams.Reward(1,i) = 1;
            elseif ~isnan(BpodSystem.Data.RawEvents.Trial{1,i}.States.AirPuff(1))
                % if the trial was airpuffed, it was an incorrect-reaction
                % trial
                BpodSystem.Data.OnlinePlotParams.Reward(1,i) = 0;
                BpodSystem.Data.OnlinePlotParams.FACount = BpodSystem.Data.OnlinePlotParams.FACount + 1;
            end
        %if the RT is nan, the mouse didn't poke    
        elseif isnan(BpodSystem.Data.OnlinePlotParams.ReactionTime(1, i))
            %Timeout trials cannot be rewarded
            BpodSystem.Data.OnlinePlotParams.Reward(1,i) = 0;
            %whether a timeout is correct or incorrect depends on the
            %contingency: it can either be a correct withholding
            if (BpodSystem.Data.TrialSettings(1).GUI.TaskType == 1 && Sound == 2) || (BpodSystem.Data.TrialSettings(1).GUI.TaskType == 2 && Sound == 1)
                BpodSystem.Data.OnlinePlotParams.CWCount = BpodSystem.Data.OnlinePlotParams.CWCount + 1;
            else %if neither of the above is true that means a potentially rewarded trial timed out: incorrect
                BpodSystem.Data.OnlinePlotParams.MTCount = BpodSystem.Data.OnlinePlotParams.MTCount + 1;
            end
        end
        
        %Determine Prcnt correct and update params
        BpodSystem.Data.OnlinePlotParams.Correct(1,i) = (BpodSystem.Data.OnlinePlotParams.CWCount + BpodSystem.Data.OnlinePlotParams.CPCount)/i;
        BpodSystem.Data.OnlinePlotParams.ResponseRate(1,i) = BpodSystem.Data.OnlinePlotParams.PokeCount/i;
        
        
        %plot stuff but not on the first trial
        figure(FigureName);
        
        %Plot all trials + whether mouse responds or not
        subplot(2,1,1)
        hold on;
        colour = ['r' 'b'];
        for ii = 1:i
            SoundX = BpodSystem.Data.Sound(ii);
            c = colour(SoundX);
            %Tone 1 is red, Tone 2 is blue
            if ~isnan(BpodSystem.Data.OnlinePlotParams.ReactionTime(ii))
                React = 1;
            else
                React = 0;
            end
            plot(ii, React, 'o', 'Color', c);
            xlabel('Trial','FontSize',12,'FontWeight','bold');
            ylabel('ReactionTime','FontSize',12,'FontWeight','bold');
            xlim([1 60]);
            ylim([0 1]);
        end
        
        %Plot %Correct and %Poke
        subplot(2,2,3)
        hold on;
        xlabel('Trial','FontSize',12,'FontWeight','bold');
        ylabel('% Reaction','FontSize',12,'FontWeight','bold');
        ylim([0 1]);
        plot(BpodSystem.Data.OnlinePlotParams.Correct(1:i), 'Color', 'r');
        plot(BpodSystem.Data.OnlinePlotParams.ResponseRate(1:i), 'Color', 'b');  
        legend('Correct Response', 'Response Rate');
           
        %Plot ratio of Tone 1 and Tone 2 trials
        subplot(2,2,4)
        x = categorical({'7kHz', '10kHz'});
        NoOfSound2 = sum(BpodSystem.Data.OnlinePlotParams.Tone(1:i))-i;
        NoOfSound1 = i - NoOfSound2;
        y = [NoOfSound1 NoOfSound2];
        b = bar(x, y);
        b.FaceColor = 'flat';
        b.CData(2,:) = [.5 0 .5];
        
       
    case('CleanUp')
        if BpodSystem.Data.TrialSettings(1).GUI.TaskType == 1
            t = 'A';
        else
            t = 'B';
        end
        c = clock;
        date = strcat(string(c(1)), string(c(2)), string(c(3)), string(c(4)), t);
        Name = strcat('SN', string(BpodSystem.Data.TrialSettings(1).GUI.SubjectName));
        path = strcat('D:\data_bpod_raw\', Name);
        figname = strcat(path, '\',Name, '_', date,'.fig');
        filename = strcat(path, '\',Name, '_', date,'.csv');
        savefig(FigureName, figname);
        i = BpodSystem.Data.nTrials;
        n = i-1;
        correct = BpodSystem.Data.OnlinePlotParams.Correct(1,n);
        CSplus = BpodSystem.Data.OnlinePlotParams.CPCount/(BpodSystem.Data.OnlinePlotParams.CPCount+BpodSystem.Data.OnlinePlotParams.MTCount);
        CSminus = BpodSystem.Data.OnlinePlotParams.CWCount/(BpodSystem.Data.OnlinePlotParams.CWCount+BpodSystem.Data.OnlinePlotParams.FACount);
        Result = [n correct CSplus CSminus];
        csvwrite(filename, Result);
        return
        
end


