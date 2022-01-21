%% Read data
filename = 'CLEAN_House1.csv'

data = ...
    readtable(strcat(...
        'D:\School\Unief\Erasmus Porto\Courses\Erasmus project\Data\Refit_files\REFIT\Data\',...
        filename...
        ));

% display(data(1:10,:));
clean_data = table();
clean_data.Date = data.Time;
clean_data.ActivePower = data.Appliance1;   %Fill in the correct appliance number here
%% Plot data
figure();
plot(clean_data{:,"ActivePower"});
% plot(clean_data{3700:4100,"ActivePower"});  %House1 Cycle

%% Plot data vs time
figure();
% plot(clean_data{:,"Time"},clean_data{:,"ActivePower"});
plot(clean_data{1:500000,"Date"},clean_data{1:500000,"ActivePower"});
title('Power vs time');ylabel('Power(W)');xlabel('Date');

fprintf('Press any key to extract features from this REFIT file\n');
pause;
%% Feature extraction
csvpath = "./Refit_files/features"
%[~,LOCS] = findpeaks(clean_data{1:100000,"ActivePower"},'MinPeakHeight',70,'MinPeakDistance',500);
extractFeaturesSlowstream(clean_data,csvpath);