function tones = GenerateTones(noOfTonesToGen, sampRate, duration, rampTime, amplitude, HighFreq, LowFreq, HighPerc, LowPerc)
%{ 
tones = GenerateTones(noOfTonesToGen, sampRate, duration, rampTime, amplitude, HighFreq, LowFreq, HighPerc, LowPerc)
Author: Hernando Martinez Vergara
SWC, 2019/02/12
%}
%Generate 'noOfTonexToGen' number of tones
%tones = array of tones. Each tone is a sum of two tones sampled, with some
%independent probability, from a set of high and low frequencies.
%sampRate = sample rate, in Hz (e.g. 192000)
%duration = duration of each sound, in seconds (e.g. 0.03)
%rampTime = how much to ramp-up and ramp-down each tone, in seconds (e.g. 0.005)
%amplitude = median value of amplitude for the sound (can get adjusted to
%the frequency within the function)
%HighFreq = set of frequencies considered high, in Hz (e.g. 20000:2000:40000)
%LowFreq = same for low frequencies
%HighPerc = likelihood of 'filling' a high tone space (e.g. 70)
%LowPerc = likelihood of 'filling' a low tone space (e.g. 40)

    if nargin ~=9
        disp('*** please enter correct arguments for the GenerateTones function ***');
        return;
    end
    %calculate how long the sounds are
    time=0:1/sampRate:duration-1/sampRate;
    %generate empty matrix to contain the sounds
    tones = zeros(noOfTonesToGen, size(time,2)); 
    
    for i = 1:noOfTonesToGen
        amplitude_modulator = 1; % in case both sounds are played
        %Determine the frequencies to generate
        Hfreq = 0;
        Lfreq = 0;
        pickH = randi(100);
        pickL = randi(100);
        %Flags to check if both sounds are combined to reduce the amplitude
        Hflag = 0;
        Lflag = 0;
        if pickH <= HighPerc
            Hfreq = HighFreq(randi(length(HighFreq)));
            Hflag = 1;
        end
        if pickL <= LowPerc
            Lfreq = LowFreq(randi(length(LowFreq)));
            Lflag = 1;
        end 
        
        if Hflag && Lflag
            amplitude_modulator = 2;
        end
        
        HighTone = ToneGenerator(time, rampTime, amplitude/amplitude_modulator, Hfreq);
        LowTone = ToneGenerator(time, rampTime, amplitude/amplitude_modulator, Lfreq);
        tones(i,:) = HighTone + LowTone;
    end

    
    
    
    
    
    
    
    
    
    
    