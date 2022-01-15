%% Erasmus project - Cross-correlation detection
% This script works as a test file for detecting on cycles by calculating
% cross-correlation between the signal and a template on cycle

%% Initialization
clear ; close all; clc
% ENTER the filename ending in _clean!
filename = '98F4AB08E738-FastStreamStored-ID2492-2021-12-14 045858_clean';
% filename = '2DEC_512Hz_300smpnum_clean';
% ENTER the sampling frequency
Fs = 2048;

% Load the template signal
if(Fs == 128)
    template_name = '21NOV_128Hz_300smpnum_clean';
elseif(Fs == 512)
    template_name = '23NOV_512Hz_300smpnum_clean';
elseif(Fs == 2048)
    template_name = '98F4AB08E738-FastStreamStored-ID2484-2021-12-13 234811_clean';
else
    fprintf("Frequency is not yet supported\n");
    return;
end
%% =========== Part 1: Loading Data =============
% Read data
signal = readtable(strcat('./MATLAB_files/',filename,'.csv'), 'TextType','string');
template_data = readtable(strcat('./MATLAB_files/',template_name,'.csv'), 'TextType','string');

%% =========== Part 2: Visualising Data =============
filename = replace(filename,'_',' ');
template_name = replace(template_name,'_',' ');
figure(1)
sp(1) = subplot(2,1,1); 
if(Fs == 128)
    template = template_data{700000:702118,"Current"};
elseif(Fs == 512)
    template = template_data{898000:900809,"Current"};
elseif(Fs == 2048)
    template = template_data{52000:54332,"Current"};
end
plot(template);
title('Template'); ylabel('Current(A)');xlabel('Sample number'); set(gca, 'XDir','reverse');
sp(2) = subplot(2,1,2); plot(signal{:,"Current"}); title(string(filename)); ylabel('Current(A)'); xlabel('Sample number');set(gca, 'XDir','reverse');

%% =========== Part 3: Calculating & Visualising Correlation =============
[C1,lag1] = xcorr(flip(template),flip(signal{:,"Current"})); 

figure(2);
plot(lag1/Fs,C1); ylabel('Amplitude'); xlabel('Time (s)'); title('Cross-correlation between Template and Signal')

% Find all peaks in the cross-correlation that are at least 10s apart and
% bigger than 10 times the rms of the correlation
[~,LOCS] = findpeaks(C1,'MinPeakHeight',10*rms(C1),'MinPeakDistance',(10*Fs));

% Plot peaks if there are any
if(size(LOCS) > 0)% if peaks founds
    figure(3);
    plot(signal{:,"Current"});
    hold on;
    plot(LOCS,signal{LOCS,"Current"},'o','MarkerSize',5);
    title('Start(s) of on cycle(s) detected via cross-correlation method');
    set(gca, 'XDir','reverse');
else
    % Just take the biggest peak
    fprintf("No big correlations found, this is the point that is most likely to be the start of an on cycle\n")
    [~,LOCS] = findpeaks(C1,...
                        'MinPeakDistance',10*Fs, ...  % At least 10s apart
                        'sortstr','descend',...         % Sort in descending order
                        'NPeaks',1 ...                  % Take the biggest peak
                        );

    figure(3);
    plot(signal{:,"Current"});
    hold on;
    plot(LOCS,signal{LOCS,"Current"},'o','MarkerSize',5);
    title('Start(s) of on cycle(s) detected via cross-correlation method');
    set(gca, 'XDir','reverse');
end