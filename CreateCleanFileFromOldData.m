%% Erasmus project - CreateCleanFileFromOldData
% Here data can be loaded from a .tst file with the correct column names
% from older data that is formatted differently:
% (index,instance,current,vibration)
% Subsequently, the data is prepared for visualisation and written to a
% new, clean .csv file

%% Initialization
clear ; close all; clc
currentFactor = 0.010989
vibrFactor = 0.000007900599
file = 'Fridge/28-05-2021/combined';

%% =========== Part 1: Loading Data =============
% We start by loading the data

% Read data
data = readtable(strcat('./Files/',file,'.csv'), 'TextType','string');

%%Only keep necessary columns
clean_data = table(data.Instant,data.ch1_current,data.ch2_vibration);
clean_data.Properties.VariableNames = { 'Instance' 'Current' 'Vibration'};
clean_data{:,1} = strrep(clean_data{:,1},'T',' ');

%% =========== Part 2: Preparing Data =============
% Multiply the factors
clean_data{:,2} = clean_data{:,2}*currentFactor;
clean_data{:,3} = clean_data{:,3}*vibrFactor;

% Subtract the average current
avgCurrent = mean(clean_data{:,2});
clean_data{:,2} = clean_data{:,2} - avgCurrent;

% Write result to new table
writetable(clean_data,strcat('./Files/',file,'_clean.csv'));
