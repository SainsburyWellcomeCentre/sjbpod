function amplitudeMod = randomAmplitudeModulation(duration, sampleRate, npoints, minVal)
%{ 
amplitudeMod = randomAmplitudeModulation(duration, sampleRate, npoints)
Author: Hernando Martinez Vergara
SWC, 2019/02/25
%}
%Generates an amplitude modulation curve
%amplitudeMod = vector from minVal to 1
%duration = in seconds
%sampleRate = in Hz
%npoints = ups and downs of the curve
%minVal = minimum value in the curve (from 0 to 1, with maximum 3 decimals)

    % generate random ups and downs
    UpsAndDowns = zeros(1,npoints);
    for i = 1:npoints
        UpsAndDowns(i) = randi([minVal 1]*1000)/1000;
    end
    

%     % generate the vector of points to make
%     amplitudeMod = ones(1,duration*sampleRate);

    % distribute the ups and downs evenly within the vector
    timeChunks = floor(duration*sampleRate/npoints);
    firstPoint = floor(timeChunks/2);
    if firstPoint<1 % this can be because the number of points is too big compared to the duration and samprate
        disp('Amplitude not modulated as parameters are wrong')
        return
    end
    lastPoint = duration*sampleRate;
    idx = [1 firstPoint:timeChunks:lastPoint];
    UpsAndDowns = [1 UpsAndDowns];
    if idx(end) ~= lastPoint
        idx = [idx lastPoint];
        UpsAndDowns = [UpsAndDowns 1];
    end
    
    amplitudeMod = spline(idx,UpsAndDowns,1:duration*sampleRate);
% 
%     for i = 1:length(UpsAndDowns)
%         % amplitudeMod(idx(i)) = UpsAndDowns(i);
%         % transition from one to the other smoothly
%         if i==1
%             % fill the first chunk
%             amplitudeMod(1:idx(1)) = linspace(1, UpsAndDowns(i), idx(i));
%         end
%         if i == length(UpsAndDowns)
%             % fill the last chunk
%             amplitudeMod(idx(i):end) = linspace(UpsAndDowns(i), 1, length(amplitudeMod) - idx(i) + 1);
%         else
%             % fill the chunk
%             amplitudeMod(idx(i):idx(i+1)) = linspace(UpsAndDowns(i), UpsAndDowns(i+1), idx(i+1) - idx(i) + 1);
%         end
%     end



