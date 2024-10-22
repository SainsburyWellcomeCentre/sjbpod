
%PA = PsychToolboxAudio;

sampRate = 192000;
Frequencies = 5000:2000:19000;
widthFreq = 1.2; % as in Jaramillo paper
nbOfFreq = 12;
duration = 0.5;
rampTime = 0.005; 

%Amplitude modulation
ModFreq = 8000;
AmpDB = 10;
AmpWidth = AmpDB * 5.5;
Amp = sin((1:sampRate*duration)/ModFreq)*AmpWidth+AmpDB;
%%
MySounds = [ ];
for SoundID = 1:size(Frequencies,2)
    meanFreq = Frequencies(1,SoundID);
    MySound = SoundGenerator(sampRate, meanFreq, widthFreq, nbOfFreq, duration, rampTime);
    %PsychToolboxAudio.load(SoundID, MySound)
    load(PsychToolboxAudio,SoundID, MySound)
    MySounds = [MySounds, Amp.*MySound];
end
%%
spectrogram(MySounds,256,250,256,192000,'yaxis') % Display the spectrogram
ylim([0 25]);
caxis([-30 30]);
%% PLAY SOUND

PsychToolboxAudio.play(1)
clear PsychToolboxAudio



