function save_Trial_Settings(phaseName, settings_to_save)

global BpodSystem

%% save settings for this mouse, Protocol and trainingPhase
%  if your protocol does not have a training phase you can input []
% settings_to_save should look like BpodSystem.Data.TrialSettings
TrialSettings  = settings_to_save;
default_settings_file = strsplit(BpodSystem.Path.Settings,filesep);
settings_folder = fullfile(default_settings_file{1:end-1});
new_settings_filename = [settings_folder filesep 'trialSettings_' phaseName '.mat' ];
try
    save(new_settings_filename, 'TrialSettings', '-v6');
end

