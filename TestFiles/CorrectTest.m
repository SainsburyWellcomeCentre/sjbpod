%%
figure;
ax1 = axes();
goals = [1 1 1 1 2 2 2 2];
responses = [1 1 1 NaN NaN NaN 1 2];
CorrectPlot(ax1, goals, responses);

%%
figure;
ax1 = axes();
resptime = [100 90 80 70 60 NaN NaN 50 40 30 10 5 2 1 NaN 0.5 0.1];
fpoke = [1 0 1 0 1 NaN 0 1 0 0 0 1 0 1 NaN 0 0];
trialstart = [1 4 5 12 16 22 27 54 66 68 74 76 79 88 89 95 97];
ResponseTimePlot(ax1, resptime, fpoke, trialstart);

%%
figure;
ax1 = axes();
resptime = [100 90 80 70 60 NaN NaN 50 40 30 10 5 2 1 NaN 0.5 0.1];
fpoke = [1 0 1 0 1 NaN 0 1 0 0 0 1 0 1 NaN 0 0];
CorrectFirstPokePlot(ax1,fpoke);