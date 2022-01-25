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
plot(clean_data{1:600000,"Date"},clean_data{1:600000,"ActivePower"});
title('Power vs time');ylabel('Power(W)');xlabel('Date');

fprintf('Press any key to extract features from this REFIT file\n');
pause;
%% Feature extraction
csvpath = "./Refit_files/features"
features = extractFeaturesREFIT(clean_data(1:1000000,:),csvpath);
% features = extractFeaturesREFIT(clean_data,csvpath);

fprintf('Press any key to compare indices of findpeaks and own method\n');
pause;
%% Checking indices
[features,indices] = extractFeaturesREFIT(clean_data(1:1000000,:),csvpath);

[~,LOCS] = findpeaks(clean_data{1:1000000,"ActivePower"},'MinPeakHeight',70,'MinPeakDistance',500);
length(LOCS)

indices = indices - 1;
total = [indices LOCS'];
[C,ia,ic] = unique(total);
a_counts = accumarray(ic,1);
value_counts = [C' a_counts]
idxs = find(value_counts(:,2)==1);
fprintf('Unique values:\n');
uqs = value_counts(idxs,1)