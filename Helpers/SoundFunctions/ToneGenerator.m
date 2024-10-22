function tone = ToneGenerator(time, rampTime, amplitude, frequency)
%{ 
tone = ToneGenerator(time, rampTime, amplitude, frequency)
Author: Hernando Martinez Vergara
SWC, 2019/02/12
%}
%Generates a simple tone
%time = 1D vector of time (time events, duration*samplingRate)
%rampTime = how much to ramp-up and ramp-down each tone, in seconds (e.g. 0.005)
%amplitude = median value of amplitude for the sound (can get adjusted to
%the frequency within the function)
%frequency = frequency of the sound in Hz (e.g. 20000)

    ampl=ones(1,length(time)); % in samples
    %get the number of samples to ramp
    noOfSamp = sum(time<rampTime);
    ampl(1,1:noOfSamp)=linspace(0,1,noOfSamp);
    ampl(1,(length(time) - noOfSamp + 1):end)=linspace(1,0,noOfSamp);
    
    % This is a hack used for calibration.
    % Amplitude value is calculated using two tables to produce a 70dB
    % sound. Use Measure_DB.m and Sound_Calibration.m to produce these
    % tables. 
    
    
    amp = amplitude * ampl;
    tone = amp.* sin(time * 2 * pi * frequency);
    