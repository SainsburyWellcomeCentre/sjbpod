% copies over all fields of TrialSettings
% to the global S.GUI.
% note: this only goes 2 levels deep!
% do not make more than S.GUI.test.test

function [] = copy_settings_fields(TrialSettings)

global S

field_names = fieldnames(TrialSettings);
nFields = length(field_names);

for ff = 1:nFields
    thisField = field_names{ff};
    
    % one more level!
    if isstruct(TrialSettings.(thisField)) 
        deepNames = fieldnames(TrialSettings.(thisField));
        for dd = 1:length(deepNames)
            S.GUI.(thisField).(deepNames{dd}) = TrialSettings.(thisField).(deepNames{dd});
        end
    else % no deeper fields
        S.GUI.(thisField) = TrialSettings.(thisField);
    end
end