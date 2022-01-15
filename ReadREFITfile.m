%% Read data
filename = 'CLEAN_House1.csv'

data = ...
    readtable(strcat(...
        'D:\School\Unief\Erasmus Porto\Courses\Erasmus project\Data\Refit_files\REFIT\Data',...
        filename...
        ));

display(data(1:10,:));
clean_data = table(data.Time,data.Appliance1);  %Fill in the correct number here
%% Plot data
figure();
% plot(clean_data{:,2});
plot(clean_data{3700:4100,2});  %House1 Cycle

%% Plot data vs time
figure();
plot(timeseries(clean_data{3700:4100,2},datenum(clean_data{3700:4100,1})));datetick('x','HH:MM:ss');  %House1 Cycle
title('Power vs time');ylabel('Power(W)');xlabel('Time');