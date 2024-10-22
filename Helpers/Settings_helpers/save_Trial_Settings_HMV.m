function save_Trial_Settings_HMV(path_to_data, settings_to_save)

%% save settings for this mouse, Protocol and trainingPhase
%  if your protocol does not have a training phase you can input []
% settings_to_save should look like BpodSystem.Data.TrialSettings
TrialSettings  = settings_to_save;
path_parts = strsplit(path_to_data, filesep);
settings_folder = [fullfile(path_parts{1:end-2}) filesep 'Session Settings'];
name_parts = strsplit(path_parts{end}, '_');
settings_name = [name_parts{end-1} '_' name_parts{end}];
new_settings_filename = [settings_folder filesep settings_name];
save(new_settings_filename, 'TrialSettings', '-v6');


