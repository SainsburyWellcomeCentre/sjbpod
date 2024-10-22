
% Read the data from the microphone

filepath = '/home/hernandom/data/Calibration_Data/SoundCalibration/Box12019-04-12T13_22_50.wav';
filepath = 'C:\Users\Stimulus\Desktop\sound-calibration-2021';

info = audioinfo(filepath);
info
[y,Fs] = audioread(filepath);
t = 0:seconds(1/Fs):seconds(info.Duration);
t = t(1:end-1);
plot(t,y)
xlabel('Time')
ylabel('Audio Signal')
%%
test = y((12*Fs):(17*Fs));
%%
% this crashes with 160 seconds
figure;
spectrogram(y,256,250,256,Fs,'yaxis')
%%
% Filter the data for the aligning signal
filtdata = bandpass(y,[900 50000],Fs);
figure;
plot(t,filtdata)
%% Select with data cursor the beginning of the sound
Beg = 2.7842;

FreqTimes = linspace(Beg, Beg+40*0.4, 11);
figure;
hax=axes;
plot(t,y);
hold on;
for i=1:length(FreqTimes)
    line(seconds([FreqTimes(i) FreqTimes(i)]),[-1 1])
end






