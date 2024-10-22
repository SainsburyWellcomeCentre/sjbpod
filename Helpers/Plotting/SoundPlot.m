function SoundPlot(AxesHandle, Action, sound)
    global BpodSystem
    switch Action
        case 'init'
            axes(AxesHandle);
            BpodSystem.GUIHandles.HM_USP_sound = line(1:length(sound),sound);
            set(gca,'visible','off');
        case 'update'
            set(BpodSystem.GUIHandles.HM_USP_sound, 'ydata', sound);
    end