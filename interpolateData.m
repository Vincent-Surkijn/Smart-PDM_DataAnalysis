%% Erasmus project - Slowstream Data visualisation
% This script tries to interpolate lost data in slowstreams
% It works in 2 parts:  1)  Interpolate the big missing chunks via a
%                           self-defined method
%                       2)  Interpolate smaller missing parts using the
%                           MATLAB funcion fillmissing

%% Initialization
clear ;
% Enter the filename ending in _clean!
filename = '25_10 - 31_10';

% Read data
data = readtable(strcat('VPS_Software\98F4AB08E738\Slowstreams\',filename,'.csv'), 'TextType','string');
%% Main part
% Sort data by time first
data = sortrows(data,2,"ascend");

% Delete duplicate entries
[uq,i,j] = unique(data{:,"Date"});
ixDupRows = setdiff(1:size(data,1), i);
data(ixDupRows,:) = [];

interpolatedData = data;
%TODO: add cycles in big gap
if(max(diff(data{:,"Date"}))>hours(1))
    features = extractFeaturesSlowstream(data);
end
count = 1;
while(max(diff(interpolatedData{:,"Date"}))>hours(1))
    % Find index of the data loss
    idx = find(diff(interpolatedData{:,"Date"})>hours(1),1);
    % Save the timestamp of the data loss and the one after
    timestamp = interpolatedData{idx,"Date"};
    timestamp2 = interpolatedData{idx+1,"Date"};
    % Divide it in year, month and day
    t1 = [year(timestamp) month(timestamp) day(timestamp)];
    % Find the features for that day
    idx2 = find(all(([year(features{:,"date"}) month(features{:,"date"})...
        day(features{:,"date"})]==t1)'));
    % Calculate the time of avg on + off cycle, but first delete all zeros and
    % the outliers caused by the data loss
    onTimes = features{idx2,"onTimes"};
    zeroValues = onTimes==0;
    onTimes(zeroValues) = [];
    outliersOn = isoutlier(onTimes)==1;
    onTimes(outliersOn) = [];

    offTimes = features{idx2,"offTimes"};
    zeroValues = offTimes==0;
    offTimes(zeroValues) = [];
    outliersOff = isoutlier(offTimes)==1;
    offTimes(outliersOff) = [];

    avgTimeOnOffCycle = round(mean(onTimes)) + round(mean(offTimes));
    % Calculate how much data/time was lost
    timeLost = diff(interpolatedData{idx:idx+1,"Date"});
    timeLostSecs = seconds(timeLost);
    % Calculate amount of cycles in the lost time
    extraCycles = floor(timeLostSecs/avgTimeOnOffCycle);

    % Adapt the data according to the findings
    timesToInsert = interpolatedData{idx,"Date"}+seconds(1):seconds(1):interpolatedData{idx+1,"Date"}-milliseconds(5);
    % Add times to the table and use NaNs to fill the other columns
    tableToAdd = table();
    tableToAdd.UnixTimestamp_ms_Timestamp=zeros(length(timesToInsert),1);
    tableToAdd.Date=timesToInsert';
    tableToAdd.ActivePower=zeros(length(timesToInsert),1);
    tableToAdd.ReactivePower=zeros(length(timesToInsert),1);
    tableToAdd.ApparentPower=zeros(length(timesToInsert),1);
    tableToAdd.ActiveEnergy=zeros(length(timesToInsert),1);
    tableToAdd.Frequency=zeros(length(timesToInsert),1);
    tableToAdd.Voltage=zeros(length(timesToInsert),1);
    tableToAdd.Current=zeros(length(timesToInsert),1);
    % Add table to data
    interpolatedData = vertcat(interpolatedData, tableToAdd);
    clear tableToAdd;
    % Sort data by time again
    interpolatedData = sortrows(interpolatedData,2,"ascend");
    % Now add cycles to the inserted timestamps
    idx3 = find(interpolatedData{:,"Date"}==timestamp2);
    interpolatedData{idx:avgTimeOnOffCycle:idx3,"ActivePower"} = max(interpolatedData{:,"ActivePower"});
    count = count + 1
end

figure();
sp(1) = subplot(2,1,1); plot(interpolatedData{:,"Date"},interpolatedData{:,"ActivePower"}); title('Current');
sp(2) = subplot(2,1,2); plot(data{:,"Date"},data{:,"ActivePower"}); title('Active power');
% Link axes so zooming in is synced on both plots
linkaxes(sp, 'x');

l = size(interpolatedData);
k = 1;
% Interpolate data where less than 1h and more than 5s are missing
while(~isempty(find(diff(interpolatedData{:,"Date"})<hours(1)&diff(interpolatedData{:,"Date"})>seconds(5), 1)))
    idx = find(diff(interpolatedData{:,"Date"})<hours(1)&diff(interpolatedData{:,"Date"})>seconds(5),1);
    timesToInsert = interpolatedData{idx,"Date"}+seconds(1):seconds(1):interpolatedData{idx+1,"Date"}-milliseconds(5);
    % Add times to the table and use NaNs to fill the other columns
    tableToAdd = table();
    tableToAdd.UnixTimestamp_ms_Timestamp=nan(length(timesToInsert),1);
    tableToAdd.Date=timesToInsert';
    tableToAdd.ActivePower=nan(length(timesToInsert),1);
    tableToAdd.ReactivePower=nan(length(timesToInsert),1);
    tableToAdd.ApparentPower=nan(length(timesToInsert),1);
    tableToAdd.ActiveEnergy=nan(length(timesToInsert),1);
    tableToAdd.Frequency=nan(length(timesToInsert),1);
    tableToAdd.Voltage=nan(length(timesToInsert),1);
    tableToAdd.Current=nan(length(timesToInsert),1);
    % Add table to data
    interpolatedData = vertcat(interpolatedData, tableToAdd);
    clear tableToAdd;
    % Sort data by time again
    interpolatedData = sortrows(interpolatedData,2,"ascend");
    k = k + 1;
end

% figure;
% plot(data{:,"Date"});

%% Interpolate small missing data chunks
filled = fillmissing(interpolatedData{:,"ActivePower"},'makima','SamplePoints',interpolatedData{:,"Date"});

figure
sp(1) = subplot(3,1,1); plot(interpolatedData{:,"Date"},filled); title('filled');
sp(2) = subplot(3,1,2); plot(interpolatedData{:,"Date"},interpolatedData{:,"ActivePower"}); title('interpolatedData');
sp(3) = subplot(3,1,3); plot(data{:,"Date"},data{:,"ActivePower"}); title('data');
% Link axes so zooming in is synced on both plots
linkaxes(sp, 'x');