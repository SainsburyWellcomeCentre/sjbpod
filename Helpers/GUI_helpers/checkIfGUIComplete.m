% check if all the params S.GUI were also added 
% to the GUI Panels
% --- deletes excess fields in S.GUI ---
% (these most likely came from the saved TrialSettings file)
function conflictingParams = checkIfGUIComplete()

global S

thisFieldNames = fieldnames(S.GUIPanels);
nFields = length(thisFieldNames);
allPanelParams = [];
% make a cell array with all parameter names put in the GUI
for ii = 1:nFields
    thisPanelName = thisFieldNames{ii};
    allPanelParams = [allPanelParams S.GUIPanels.(thisPanelName)];
end
allSGUIParams = fieldnames(S.GUI);

% check if the GUI panels have all parameters from S.GUI

% these params are missing in GUI panels
% remove them from S.GUI
conflictingParams = setdiff(allSGUIParams,allPanelParams);
if ~isempty(conflictingParams)
    for cc = 1:length(conflictingParams)
        S.GUI = rmfield(S.GUI,conflictingParams{cc});
        display(['!!removed from S.GUI: ' conflictingParams{cc}])
    end
end

% these params were loaded but are missing in S.GUI / TrialSettings
% we will add the field to S.GUI
conflictingParams = setdiff(allPanelParams,allSGUIParams);
if ~isempty(conflictingParams)
    for cc = 1:length(conflictingParams)            
        S.GUI.(conflictingParams{cc}) = NaN;
        display(['!!added to S.GUI: ' conflictingParams{cc}])
    end
end