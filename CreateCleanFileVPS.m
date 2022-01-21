%% Erasmus project - CreateCleanFileVPS
% Here data can be loaded from a .csv file fastStream retrieved with VPS software
% Subsequently, the data is prepared for visualisation and written to a
% new, clean .csv file

%% Initialization
clear ; close all; clc
% currentFactor = 0.010989 %same as previous sensor
% vibrFactor = 6.8439e-06 %0.000007900599(previous)
filepath = 'VPS_Software\240AC4514170\20_01_2022\';
filename = '240AC4514170-FastStreamStored-ID7679-2022-01-20 175418';
% Choose to apply a low pass filter or not
applyLPF = false

%% =========== Part 1: Loading Data =============
% We start by loading the data

% Read data
data = readtable(strcat(filepath,filename,'.csv'), 'TextType','string');

%Only keep necessary columns
clean_data = table(data.UnixTimestamp_us_,data.Current,data.Vibration);
clean_data.Properties.VariableNames = { 'Unix' 'Current' 'Vibration'};

% Sort by time (descending to be in line with the format of other files)
clean_data = sortrows(clean_data,"Unix",'descend');

%% =========== Part 2: Preparing Data =============
% Convert unix to timestamp
% This relies on a Unix timestamp with 1 microsecond resolution!!!
clean_data.Instance = datetime(clean_data.Unix,'ConvertFrom','epochtime','TicksPerSecond',1e6,'Format','dd-MMM-yyyy HH:mm:ss.SSSSSSSSS');

% Multiply the factors
% clean_data{:,"Current"} = clean_data{:,"Current"}*currentFactor;
% clean_data{:,"Vibration"} = clean_data{:,"Vibration"}*vibrFactor;

% Subtract the average current
avgCurrent = mean(clean_data{:,"Current"});
clean_data{:,"Current"} = clean_data{:,"Current"} - avgCurrent;

% disp(clean_data(1:10,:));

if(applyLPF)
    % Apply low pass filter to filter out higher(, noise) frequencies
    filteredCurrent = lowpass(clean_data{:,"Current"},100,2048);
    fprintf("Filtered\n")
    disp(clean_data(1:10,:));
    %Plot
    figure(1)
    sp(1) = subplot(2,1,1);plot(flip(clean_data{:,"Instance"}),flip(clean_data{:,"Current"}));title('Current');ylabel('Current (A)');xlabel('Time'); axis tight
    sp(2) = subplot(2,1,2);plot(flip(clean_data{:,"Instance"}),flip(filteredCurrent));title('Filtered current');ylabel('Current (A)');xlabel('Time'); axis tight
    % Link axes so zooming in is synced on both plots
    linkaxes(sp, 'x');
    clean_data{:,"Current"} = filteredCurrent;
    % Write result to new table
    writetable(clean_data,strcat('./MATLAB_files/',filename,'_cleanFiltered.csv'));
else
    % Write result to new table
    writetable(clean_data,strcat('./MATLAB_files/',filename,'_clean.csv'));
end