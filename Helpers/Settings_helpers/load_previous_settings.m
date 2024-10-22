function TrialSettings = load_previous_settings(phaseName)

global BpodSystem

%% load previous trial settings or defaults

DefaultSettings_file= BpodSystem.Path.Settings;
split_path_name = strsplit(DefaultSettings_file,filesep);
task_settings_path = fullfile(split_path_name{1:end-1});

current_protocol_path = [BpodSystem.Path.ProtocolFolder BpodSystem.Path.CurrentProtocol];
current_protocol_default_path = [current_protocol_path filesep 'Protocol_default_settings'];

phase_settings_filename = [ task_settings_path filesep 'trialSettings_' phaseName '.mat' ];
default_phase_settings_filename = [ current_protocol_default_path filesep 'TrialSettings_' phaseName '_Default.mat' ];

if exist(phase_settings_filename,'file')==2
    loaded_settings = load(phase_settings_filename);
    disp('loaded previous settings')
elseif exist(default_phase_settings_filename,'file')==2
    loaded_settings = load(default_phase_settings_filename);
    disp('loaded default settings')
end
TrialSettings = loaded_settings.TrialSettings;
