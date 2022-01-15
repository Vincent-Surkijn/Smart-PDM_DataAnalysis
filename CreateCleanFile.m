%% Erasmus project - CreateCleanFile
% Here data can be loaded from a .csv file with the correct column names
% Subsequently, the data is prepared for visualisation and written to a
% new, clean .csv file

%% Initialization
clear ; close all; clc
currentFactor = 0.010989 %same as previous sensor
vibrFactor = 6.8439e-06 %0.000007900599(previous)
filename = '4DEC_128Hz_300smpnum';

%% =========== Part 1: Loading Data =============
% We start by loading the data

% Read data
data = readtable(strcat('./Refrigerator ISEP/',filename,'.csv'), 'TextType','string');

%%Only keep necessary columns
clean_data = table(data.instance,data.current,data.vibration);
clean_data.Properties.VariableNames = { 'Instance' 'Current' 'Vibration'};

%% =========== Part 2: Preparing Data =============
% Multiply the factors
clean_data{:,"Current"} = clean_data{:,"Current"}*currentFactor;
clean_data{:,"Vibration"} = clean_data{:,"Vibration"}*vibrFactor;

% Subtract the average current
avgCurrent = mean(clean_data{:,"Current"});
clean_data{:,"Current"} = clean_data{:,"Current"} - avgCurrent;

% Write result to new table
writetable(clean_data,strcat('./MATLAB_files/',filename,'_clean.csv'));
