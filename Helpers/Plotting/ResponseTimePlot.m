function ResponseTimePlot(AxesHandle, Action, responseTimes, firstPokes, startTrialTimes)
    %Hernando Martinez Vergara, SWC
    global BpodSystem
    
    %split data into correct and incorrect first pokes
    TrialNum = 1:length(responseTimes);
    correctRT = responseTimes(firstPokes == 1);
    XaxCorrect = TrialNum(firstPokes == 1);
    incorrectRT = responseTimes(firstPokes == 0);
    XaxIncorrect = TrialNum(firstPokes == 0);
    
    switch Action
        case 'init'
            % plot
            axes(AxesHandle);
            yyaxis left
            BpodSystem.GUIHandles.HM_RTP_CorrectFP = line(0, 0, 'Marker','.','LineStyle', 'none','Color', 'g', 'MarkerSize', 13);
            BpodSystem.GUIHandles.HM_RTP_IncorrectFP = line(0, 0, 'Marker','.','LineStyle', 'none','Color', 'r', 'MarkerSize', 13);
            set(AxesHandle,'YLim', [0, 10]);
            set(gca, 'YScale', 'log');
            %xlabel(AxesHandle, 'Trial number', 'FontSize', 9);
            %title(AxesHandle, 'Response Time', 'FontSize', 12);

            % Time in between trials
            yyaxis right
            BpodSystem.GUIHandles.HM_RTP_TrialTime = line(1.5, 0, 'LineWidth', 1, 'Color', 'k', 'LineStyle', '-');
            set(AxesHandle,'YLim', [0, 100]);
            set(gca, 'YScale', 'log');
            set(AxesHandle,'XLim', [1, 10]);
            set(gca,'box','off', 'color', 'none')
            hold(AxesHandle, 'on');
            
        case 'update'
            set(BpodSystem.GUIHandles.HM_RTP_CorrectFP, 'xdata', XaxCorrect, 'ydata', correctRT);
            set(BpodSystem.GUIHandles.HM_RTP_IncorrectFP, 'xdata', XaxIncorrect, 'ydata', incorrectRT);
            if length(startTrialTimes) < 2
                Ydata = 0;
                Xdata = 1.5;
            else
                Ydata = diff(startTrialTimes);
                Xdata = 1.5:length(startTrialTimes);
            end
            set(BpodSystem.GUIHandles.HM_RTP_TrialTime, 'xdata', Xdata, 'ydata', Ydata);
            
            trialsToDisplay = max([10 length(TrialNum)]);
            set(AxesHandle,'XLim', [1, trialsToDisplay]);
            %AxesHandle.YAxis(1).Limits = [0, max([correctFP(end) incorrectFP(end)])];
    end
    
