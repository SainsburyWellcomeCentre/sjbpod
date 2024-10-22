function tone = GenerateWhiteNoise( sampRate, duration, rampTime, amplitude)
time=0:1/sampRate:duration-1/sampRate;
ampl=ones(1,length(time)); % in samples
%get the number of samples to ramp
noOfSamp = sum(time<rampTime);
ampl(1,1:noOfSamp)=linspace(0,1,noOfSamp);
ampl(1,(length(time) - noOfSamp + 1):end)=linspace(1,0,noOfSamp);
amp = amplitude * ampl;
tone = amp.* rand([1 length(time)]);
end