function Random_WN_GUIParameters
    global S %BpodSystem
    
    %% General tab:
    S.GUITabs.General = {'General'};
        % Fields
    S.GUIPanels.General = {'SoundAmplitude','SoundDuration', 'ITI'};
    % Define
    S.GUI.SoundAmplitude = 0.005;
    S.GUI.SoundDuration = 0.5;
    S.GUI.ITI = 5;
    
end