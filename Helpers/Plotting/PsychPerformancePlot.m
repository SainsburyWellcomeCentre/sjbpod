function PsychPerformancePlot(AxesHandle, Action, varargin)
    %Hernando Martinez Vergara, SWC
    %% Code Starts Here
    global BpodSystem
    
    difficulty = varargin{1}; % dificulty levels
    %data to 50%
    performance = repelem(50, length(difficulty));
    %optoStimulation
    optoPer = repelem(50, length(difficulty));
    
    %for the logistic regression
    NormalCount = repelem(0, length(difficulty));
    NormalRightChoice = repelem(0, length(difficulty));
    OptoCount = repelem(0, length(difficulty));
    OptoRightChoice = repelem(0, length(difficulty));
    
    if nargin > 3
        trialsDif = varargin{2}; % in difficulty level
    else
        trialsDif = 50; %vertical default line
    end
    
    if nargin > 4
        sideSelected = varargin{3}; % 1 or 2 (or NaN)
        optoStim = varargin{4}; % 0s or 1s if optostimulation happens

        if sum(optoStim == 0) > 0 %if there are normal trials
            trialsDifNormal = trialsDif(optoStim == 0);
            sideSelNormal = sideSelected(optoStim == 0);
        else
            trialsDifNormal = NaN;
            sideSelNormal = NaN;
        end
        if sum(optoStim == 1) > 0 %if there are opto trials
            trialsDifOpto = trialsDif(optoStim == 1);
            sideSelOpto = sideSelected(optoStim == 1);
        else
            trialsDifOpto = NaN;
            sideSelOpto = NaN;
        end

        for i = 1:length(difficulty)
            if nansum(sideSelNormal(trialsDifNormal==difficulty(i)))>0
                performance(i) = 100 * (nanmean(sideSelNormal(trialsDifNormal==difficulty(i))) - 1);
                NormalCount(i) = sum(trialsDifNormal==difficulty(i));
                NormalRightChoice(i) = sum(sideSelNormal(trialsDifNormal==difficulty(i)) == 2);
            end
            if nansum(sideSelOpto(trialsDifOpto==difficulty(i)))>0
                optoPer(i) = 100 * (nanmean(sideSelOpto(trialsDifOpto==difficulty(i))) - 1);
                OptoCount(i) = sum(trialsDifOpto==difficulty(i));
                OptoRightChoice(i) = sum(sideSelOpto(trialsDifOpto==difficulty(i)) == 2);
            end
        end
    end
    
%     %polynomial fit
%     mdl = fitlm(difficulty,performance,'poly3');
%     mdlOpto = fitlm(difficulty,optoPer,'poly3');
    
%     %Spline fit
%     splineIdx = linspace(difficulty(1),difficulty(end),100);
%     mdl = spline(difficulty, performance, splineIdx);
%     mdlOpto = spline(difficulty, optoPer, splineIdx);
    
    %logistic regression
    LRmdl = glmfit(difficulty',[NormalRightChoice' NormalCount'],'binomial','link','probit');
    yfit = glmval(LRmdl,0:1:100,'probit');
    mdl = 100 * yfit;
    
    LRmdlOpto = glmfit(difficulty',[OptoRightChoice' OptoCount'],'binomial','link','probit');
    yfitOpto = glmval(LRmdlOpto,0:1:100,'probit');
    mdlOpto = 100 * yfitOpto;
        
    switch Action
        case 'init'
            %initialize pokes plot
            axes(AxesHandle);
            BpodSystem.GUIHandles.HM_PPP_NormalDots = line(difficulty, performance, 'Marker', '.', 'LineStyle', 'none', 'Color', 'b', 'MarkerSize', 28);
            %BpodSystem.GUIHandles.HM_PPP_NormalLine = line(splineIdx, mdl, 'LineStyle', '-', 'Color', 'b', 'LineWidth', 2);
            BpodSystem.GUIHandles.HM_PPP_NormalLine = line(0:1:100, mdl, 'LineStyle', '-', 'Color', 'b', 'LineWidth', 2);
            BpodSystem.GUIHandles.HM_PPP_OptoDots = line(difficulty, optoPer, 'Marker', '.', 'LineStyle', 'none', 'Color', [0.9100 0.4100 0.1700], 'MarkerSize', 24);
            %BpodSystem.GUIHandles.HM_PPP_OptoLine = line(splineIdx, mdlOpto, 'LineStyle', '-', 'Color', [0.9100 0.4100 0.1700], 'LineWidth', 2);
            BpodSystem.GUIHandles.HM_PPP_OptoLine = line(0:1:100, mdlOpto, 'LineStyle', '-', 'Color', [0.9100 0.4100 0.1700], 'LineWidth', 2);
            set(AxesHandle,'TickDir', 'out','YLim', [0, 100], 'YTick', [0 50 100], 'YTickLabel', {'0', '50', '100'}, 'FontSize', 6);
            xlabel(AxesHandle, '%High Tones', 'FontSize', 9);
            ylabel(AxesHandle, '%Rightward choices', 'FontSize', 9);
            %title(AxesHandle, 'Psychometric performance', 'FontSize', 12);
            %plot current trial difficulty level
            BpodSystem.GUIHandles.HM_PPP_DifLevel = line([trialsDif(end) trialsDif(end)], [0 100]);
            set(gca,'box','off', 'color', 'none')
            hold(AxesHandle, 'on');
%             legend('off');
        case 'update'
            set(BpodSystem.GUIHandles.HM_PPP_NormalDots, 'ydata', performance);
            set(BpodSystem.GUIHandles.HM_PPP_NormalLine, 'ydata', mdl);
            set(BpodSystem.GUIHandles.HM_PPP_OptoDots, 'ydata', optoPer);
            set(BpodSystem.GUIHandles.HM_PPP_OptoLine, 'ydata', mdlOpto);
            set(BpodSystem.GUIHandles.HM_PPP_DifLevel, 'xdata', [trialsDif(end) trialsDif(end)]);
    end
    
    
%     mdlPlot = plot(mdl);
%     set(mdlPlot, 'Color', 'b');
%     mdlPlot(1).Marker = '.';
%     mdlPlot(1).MarkerSize = 28;
%     hold on;
%     mdlPlotOpto = plot(mdlOpto);
%     set(mdlPlotOpto, 'Color', [ 0.9100 0.4100 0.1700]); %orange
%     mdlPlotOpto(1).Marker = '.';
%     mdlPlotOpto(1).MarkerSize = 24;
    

%     hold off;


end
