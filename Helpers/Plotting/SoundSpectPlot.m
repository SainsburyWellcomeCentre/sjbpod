function SoundSpectPlot(AxesHandle, Action, sound)
    global BpodSystem
    [~,~,~,pxx,fc,tc] = spectrogram(sound,1000,800,2000,192000,'yaxis','MinThreshold',-100);
    switch Action
        case 'init'
            axes(AxesHandle);
            BpodSystem.GUIHandles.HM_SSP_sound = line(0,0, 'Color', 'b', 'LineStyle','none','Marker','.');
            %plot(tc(pxx>0),fc(pxx>0),'.');
            set(gca, 'YScale', 'log');
            set(AxesHandle,'YLim', [4500, 45000]);
            set(AxesHandle,'XLim', [0, .5]);
            set(gca,'box','off', 'color', 'none');
            hold(AxesHandle, 'on');
            
        case 'update'
            %axes(AxesHandle);
            set(BpodSystem.GUIHandles.HM_SSP_sound, 'xdata', tc(pxx>0), 'ydata', fc(pxx>0));
            %plot(tc(pxx>0),fc(pxx>0),'.');

    end