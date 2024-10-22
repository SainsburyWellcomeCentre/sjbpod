%% Testing psychfunction

myfig = figure('Position', [100 100 500 500],'name','Psychometric Curve','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');

myax = axes('Position', [.1 .1 .8 .8]);

%Generate bulshit data
trials = 100;
PercVect = [2, 18, 34, 50, 66, 82, 98];

PsychPerformancePlot(myax, 'init', PercVect);



%%

triTy = zeros(1,trials);
selSide = zeros(1,trials);
optoTrials = WeightedRandomTrials([.6 .4], trials) - 1;
for i=1:trials
    triTy(i) = PercVect(randi(length(PercVect)));
    
    switch triTy(i)
        case 2
            selSide(i) = WeightedRandomTrials([.9 .1], 1);
        case 18
            selSide(i) = WeightedRandomTrials([.8 .2], 1);
        case 34
            selSide(i) = WeightedRandomTrials([.7 .3], 1);
        case 50
            selSide(i) = WeightedRandomTrials([.5 .5], 1);
        case 66
            selSide(i) = WeightedRandomTrials([.3 .7], 1);
        case 82
            selSide(i) = WeightedRandomTrials([.2 .8], 1);
        case 98
            selSide(i) = WeightedRandomTrials([.1 .9], 1);
    end
end
selSide(1:10) = NaN;


%pause(2);

PsychPerformancePlot(myax, 'update', PercVect, triTy, selSide, optoTrials);