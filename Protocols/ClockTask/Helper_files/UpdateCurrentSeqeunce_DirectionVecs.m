function [Port_1,Port_2] = UpdateCurrentSeqeunce_DirectionVecs(CurrentTrialType,Sequence)
%Set the port order based on the trial type and the GUI settings
    Port_1 = num2str(Sequence((CurrentTrialType*2)-1));
    Port_2 = num2str(Sequence(CurrentTrialType*2));
