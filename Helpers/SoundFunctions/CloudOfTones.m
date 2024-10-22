function sound = CloudOfTones(sampRate, duration, rampTime, amplitude, HighFreq, LowFreq, HighPerc, LowPerc, subduration, suboverlap)

%{ 
sound = CloudOfTones(sampRate, duration, rampTime, amplitude, HighFreq, LowFreq, HighPerc, LowPerc, subduration, suboverlap)
Author: Hernando Martinez Vergara
SWC, 2019/02/12
%}

%Generate a cloud of tones
%sound = 1-D Vector containing a sequence of overlaping tones. 
%Each tone is a sum of two tones sampled, with some
%independent probability, from a set of high and low frequencies.
%sampRate = sample rate, in Hz (e.g. 192000)
%duration = duration of the whole sound, in seconds (e.g. 0.5)
%rampTime = how much to ramp-up and ramp-down each tone, in seconds (e.g. 0.005)
%amplitude = median value of amplitude for the sound (can get adjusted to
%the frequency within the function)
%HighFreq = set of frequencies considered high, in Hz (e.g. 20000:2000:40000)
%LowFreq = same for low frequencies
%HighPerc = likelihood of 'filling' a high tone space (e.g. 70)
%LowPerc = likelihood of 'filling' a low tone space (e.g. 40)
%subduration = duration of each tone, in seconds (e.g. 0.03)
%suboverlap = overlap of two consecutive tones, in seconds (e.g. 0.01)

    if nargin ~=10
        disp('*** please enter correct arguments for the CloudOfTones function ***');
        return;
    end
    
    %Calculate the number of different tones to generate
    nonoverlap = subduration - suboverlap;
    if nonoverlap <= 0
        disp('*** the tones overlap is bigger than the duration ***');
        return;
    end
        
    noOfTonesToGen = floor(duration/nonoverlap);
    if noOfTonesToGen < 1
        disp('*** duration and subduration / suboverlap ration might not make sense ***');
        return;
    end
    
    %Generate that number of sounds
    tones = GenerateTones(noOfTonesToGen, sampRate, subduration, rampTime, amplitude, HighFreq, LowFreq, HighPerc, LowPerc);
    
    %time=0:1/sampRate:duration-1/sampRate;
    
    %Generate a matrix to hold the sounds
    %soundMat = zeros(size(tones,1), sampRate*duration);
    
    %Create empty vector to concatenate the tones
    soundLength = sampRate*duration;
    toneLength = sampRate*subduration;
    sound = zeros(1, soundLength+toneLength); %addition of a tail to avoid failures of function
    %Get indexes for sound placement
    spaceLength = sampRate*nonoverlap;
    idx = 1:spaceLength:soundLength;
    %Concatenate
    for i = 1:size(tones,1)
        sound(idx(i):(idx(i)+toneLength-1)) = tones(i,:) + sound(idx(i):(idx(i)+toneLength-1));
    end
    %clipping of the tail
    sound = sound(1:soundLength);
    
    
    
    
    
    
    
    
    
