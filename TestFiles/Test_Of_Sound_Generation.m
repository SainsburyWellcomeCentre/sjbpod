%% Frequency band


%Test_Of_Sound_Generation.m
sampRate = 192000;
meanFreq = 45000;
widthFreq = 1.002; % as in Jaramillo paper
nbOfFreq = 14;
duration = 0.5;
rampTime = 0.005;
amplitude = 1;

Mysound = SoundGenerator(sampRate, meanFreq, widthFreq, nbOfFreq, duration, rampTime, amplitude);
spectrogram(Mysound,256,250,256,192000,'yaxis') % Display the spectrogram
%plot(Mysound)
%sound(Mysound)
%}
%{
PsychToolboxSoundServer('init'); % Initialize sound server
PsychToolboxSoundServer('load', 1, Mysound); % load the sound
PsychToolboxSoundServer('play', 1); % Play the sound
pause(1);
PsychToolboxSoundServer('close'); % Close sound server
%}
%%

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

PsychToolboxSoundServer('init');
MySounds = [ ];
for SoundID = 1:size(Frequencies,2)
    meanFreq = Frequencies(1,SoundID);
    MySound = SoundGenerator(sampRate, meanFreq, widthFreq, nbOfFreq, duration, rampTime);
    MySound = [MySound; MySound];
    MySound(1,:) = 0;
    PsychToolboxSoundServer('Load', SoundID, MySound);
    MySounds = [MySounds, Amp.*MySound];
end

%spectrogram(MySounds,256,250,256,192000,'yaxis') % Display the spectrogram
%ylim([0 25]);
%caxis([-30 30]);





for SoundID = 1:size(Frequencies,2)
    PsychToolboxSoundServer('play', SoundID); % Play the sound
    pause(1);
end
PsychToolboxSoundServer('close'); % Close sound server


%% Cloud of tones
tic
HighFreq = logspace(log10(20000), log10(40000), 6);
LowFreq = logspace(log10(5000), log10(10000), 6);
HighPerc = 50;
LowPerc = 50;

sampRate = 192000;
duration = 10;
rampTime = 0.01; 
amplitude = .001;
subduration = 0.03;
suboverlap = 0.01;


%{
% Test ToneGenerator
time=0:1/sampRate:duration-1/sampRate;
sound = ToneGenerator(time, rampTime, amplitude, 10000);
plot(time,sound);
figure;
spectrogram(sound,256,250,256,192000,'yaxis') % Display the spectrogram
%}

%{
% Test GenerateTones
noOfTonesToGen = 100;
tones = GenerateTones(noOfTonesToGen, sampRate, subduration, rampTime, amplitude, HighFreq, LowFreq, HighPerc, LowPerc);
concsounds = reshape(tones', [], 1);
spectrogram(concsounds,256,250,256,192000,'yaxis') % Display the spectrogram
%}

% Test CloudOfTones
MySound = CloudOfTones(sampRate, duration, rampTime, amplitude, HighFreq, LowFreq, HighPerc, LowPerc, subduration, suboverlap);

toc %Elapsed time is 0.012967 seconds. for 0.5s duration

PsychToolboxSoundServer('init'); % Initialize sound server
PsychToolboxSoundServer('load', 1, MySound); % load the sound
PsychToolboxSoundServer('play', 1); % Play the sound
pause(10);
PsychToolboxSoundServer('close'); % Close sound server

spectrogram(MySound,256,250,256,'yaxis') % Display the spectrogram
%ylim([0 45]);

%Amplitude modulation
Amp = randomAmplitudeModulation(duration,sampRate,37,0.8);
figure;
plot(MySound);
hold on
plot(Amp.*MySound);
hold off

%% Calibration tests
sampRate = 192000;
duration = 2;
rampTime = 0.005; 
amplitude = 1;
time=0:1/sampRate:duration-1/sampRate;
freqs = 1000 * [40];
PsychToolboxSoundServer('init'); % Initialize sound server
concsounds = [];
for i = 1:length(freqs)
    sound = ToneGenerator(time, rampTime, amplitude, freqs(i));
    PsychToolboxSoundServer('load', 1, sound); % load the sound
    PsychToolboxSoundServer('play', 1); % Play the sound
    pause(duration+0.2);
    concsounds = [concsounds sound];
    disp(freqs(i));
end
PsychToolboxSoundServer('close'); % Close sound server
%spectrogram(concsounds,256,250,256,192000,'yaxis');

%% Stop the sound

sampRate = 192000;
duration = 20;
rampTime = 0.005; 
amplitude = 1;
time=0:1/sampRate:duration-1/sampRate;
freqA = 1000;
soundA = ToneGenerator(time, rampTime, amplitude, freqA);
freqB = 100;
soundB = ToneGenerator(time, rampTime, amplitude, freqB);

PsychToolboxSoundServer('init'); % Initialize sound server
PsychToolboxSoundServer('load', 1, soundA);
PsychToolboxSoundServer('load', 2, soundB);
PsychToolboxSoundServer('play', 1);
pause(1);
PsychToolboxSoundServer('stop', 1);

PsychToolboxSoundServer('play', 2);
PsychToolboxSoundServer('close'); % Close sound server

%% Amplitude test
%percentage of high tones (difficulty). High-Left, Low-Right
HighFreq = logspace(log10(20000), log10(40000), 16);
LowFreq = logspace(log10(5000), log10(10000), 16);
sampRate = 192000;
duration = 5;
rampTime = 0.01; 
amplitude = 0.005; %Calibrate properly! 
subduration = 0.03;
suboverlap = 0.01;
HighPerc = 0;
LowPerc = 100;

COTSound = CloudOfTones(sampRate, duration, rampTime, amplitude, HighFreq, LowFreq, HighPerc, LowPerc, subduration, suboverlap);
% Modulate amplitude randomly
modAmp = randomAmplitudeModulation(duration,sampRate,15,0.8);
ModCOTSound = modAmp.*COTSound;
SoundID = 1;
PsychToolboxSoundServer('init'); % Initialize sound server
PsychToolboxSoundServer('Load', SoundID, ModCOTSound);
PsychToolboxSoundServer('play', 1);
pause(duration);
PsychToolboxSoundServer('close'); % Close sound server