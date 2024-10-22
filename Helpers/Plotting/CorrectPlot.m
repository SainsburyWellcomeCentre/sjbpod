function CorrectPlot(AxesHandle, Action, goal, response, opto)
    global BpodSystem
    %Hernando Martinez Vergara, SWC
    correct = goal == response;
    noresponse = isnan(response);
    incorrect = ~correct & ~noresponse;    
    %separate trials by opto stimulation
    NumOpto = sum(opto); 
    NumNormal = length(goal) - NumOpto;
    normalC = 100*sum(correct & ~opto)/NumNormal;
    normalI = 100*sum(incorrect & ~opto)/NumNormal;
    normalN = 100*sum(noresponse & ~opto)/NumNormal;
    optoC = 100*sum(correct & opto)/NumOpto; 
    optoI = 100*sum(incorrect & opto)/NumOpto; 
    optoN = 100*sum(noresponse & opto)/NumOpto;
    
    switch Action
        case 'init'
            axes(AxesHandle);
            c = categorical({'correct','incorrect','noresponse'});
            BpodSystem.GUIHandles.HM_CP_bar = bar(c, [normalC optoC; normalI optoI; normalN optoN]);
            set(gca,'box','off', 'color', 'none')
            hold(AxesHandle, 'on');
        case 'update'
            BpodSystem.GUIHandles.HM_CP_bar(1).YData = [normalC normalI normalN];
            BpodSystem.GUIHandles.HM_CP_bar(2).YData = [optoC optoI optoN];
    end

    
    