%% Erasmus project - Slowstream Data visualisation
% Here data can be loaded from a clean .csv file
% Subsequently, it is visualized and some interesting parameters are
% calculated

%% Initialization
clear ; close all; clc
% Enter the filename ending in _clean!
filename = '21_9_6 - 21_9_12';
filepath = 'VPS_Software\98F4AB08E738\Slowstreams\';

%% =========== Part 1: Loading Data =============
% We start by loading the data

% Read data
data = readtable(strcat(filepath,filename,'.csv'), 'TextType','string');

% Sort data by time first
data = sortrows(data,"Date","ascend");
%% =========== Part 2: Visualising Data =============

% Display headers and first 10 rows
% disp(data(1:10,:));

% Print dimensions of data
%fprintf("Dimensions of data: %d rows x %d columns\n", size(data));

% Visualise data
figure(1)
sp(1) = subplot(2,1,1); plot(data{:,"Current"}); title('Current');
sp(2) = subplot(2,1,2); plot(data{:,"ActivePower"}); title('Active power');
% Link axes so zooming in is synced on both plots
linkaxes(sp, 'x');
fprintf('Press any key to also plot a time series of the current and vibration.\n');
pause;
%% Time series
fprintf('Plotting time series.\n');
figure(2)
sp(1) = subplot(2,1,1);plot(flip(data{:,"Date"}),flip(data{:,"Current"}));title('Current vs time');ylabel('Current (A)');xlabel('Time'); axis tight
sp(2) = subplot(2,1,2);plot(flip(data{:,"Date"}),flip(data{:,"ActivePower"}));title('Active Power vs time');ylabel('Active Power (W)');xlabel('Time'); axis tight

% Link axes so zooming in is synced on both plots
linkaxes(sp, 'x');