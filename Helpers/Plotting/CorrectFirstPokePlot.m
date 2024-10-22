function CorrectFirstPokePlot(AxesHandle, Action, firstPokes)
    %Hernando Martinez Vergara, SWC
    global BpodSystem
    %split data into correct and incorrect first pokes
    correctFP = cumsum(firstPokes == 1);
    incorrectFP = cumsum(firstPokes == 0);
    
    switch Action
        case 'init'
            % plot
            axes(AxesHandle);
            yyaxis left
            BpodSystem.GUIHandles.CFPP_CorrectFP = line(0, 0, 'Color', 'g', 'LineWidth',3, 'LineStyle', '-');
            BpodSystem.GUIHandles.CFPP_IncorrectFP = line(0, 0, 'Color', 'r', 'LineWidth',3, 'LineStyle', '-');
            set(AxesHandle,'YLim', [0, 1]);
            %xlabel(AxesHandle, 'Trial number', 'FontSize', 9);
            %ylabel(AxesHandle, 'Number of trials', 'FontSize', 9);
            %title(AxesHandle, 'First Poke cumulative responses', 'FontSize', 10);
            %plot performance in the other axis
            yyaxis right
            BpodSystem.GUIHandles.CFPP_Ratio = line(0, 0, 'Color', 'k', 'LineWidth',3, 'LineStyle', '-');
            set(AxesHandle,'YLim', [0, 100]);
            set(AxesHandle,'XLim', [1, 10]);
            set(gca,'box','off', 'color', 'none')
            hold(AxesHandle, 'on');
        case 'update'
            NewYMax = max([correctFP(end) incorrectFP(end)]);
            trialsToDisplay = max([10 length(firstPokes)]);
            % plot
            set(BpodSystem.GUIHandles.CFPP_CorrectFP, 'xdata', 1:length(firstPokes), 'ydata', correctFP);
            set(BpodSystem.GUIHandles.CFPP_IncorrectFP, 'xdata', 1:length(firstPokes), 'ydata', incorrectFP);
            if NewYMax>0
                AxesHandle.YAxis(1).Limits = [0, NewYMax];
            end
            %plot performance in the other axis
            set(BpodSystem.GUIHandles.CFPP_Ratio, 'xdata', 1:length(firstPokes), 'ydata', 100*correctFP./(correctFP + incorrectFP));            
            set(AxesHandle,'XLim', [1, trialsToDisplay]);
    end
