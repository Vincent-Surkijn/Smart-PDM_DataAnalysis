%% Erasmus project - Data visualisation
% Here data can be loaded from a clean .csv file
% Subsequently, it is visualized and some interesting parameters are
% calculated

%% Initialization
clear ; close all; clc
% Enter the filename ending in _clean!
filename = '98F4AB08E738-FastStreamStored-ID4809-2022-01-06 155331_clean';
% Sampling frequency (Adapt this to the frequency the data was gathered at)
Fs = 2048

%% =========== Part 1: Loading Data =============
% We start by loading the data

% Read data
data = readtable(strcat('./MATLAB_files/',filename,'.csv'), 'TextType','string');
%data = readtable(strcat('./Files/',filename,'.csv'), 'TextType','string');

% Sort by time
data = sortrows(data,"Unix",'descend');

%% =========== Part 2: Visualising Data =============

% Display headers and first 10 rows
% disp(data(1:10,:));

% Print dimensions of data
%fprintf("Dimensions of data: %d rows x %d columns\n", size(data));

% Visualise data
figure(1)
sp(1) = subplot(2,1,1); plot(data{:,"Current"}); title('Current'); set(gca, 'XDir','reverse')
sp(2) = subplot(2,1,2); plot(data{:,"Vibration"}); title('Vibration'); set(gca, 'XDir','reverse')
% Link axes so zooming in is synced on both plots
linkaxes(sp, 'x');
fprintf('Press any key to also plot a time series of the current and vibration.\n');
pause;
%% Time series
fprintf('Plotting time series.\n');
figure(2)
sp(1) = subplot(2,1,1);plot(flip(data{:,"Instance"}),datenum(flip(data{:,"Current"})));title('Current vs time');ylabel('Current (A)');xlabel('Time'); axis tight
sp(2) = subplot(2,1,2);plot(flip(data{:,"Instance"}),datenum(flip(data{:,"Vibration"})));title('Vibrations vs time');ylabel('Vibration');xlabel('Time'); axis tight

% Link axes so zooming in is synced on both plots
linkaxes(sp, 'x');

fprintf('Press any key to also plot the power/RMS, kurtosis and skewness of the current.\n');
pause;
%% Active power, kurtosis and skewness of current
fprintf('Plotting power/RMS, kurtosis and skewness of the current.\n');
% % 230V is the outlet voltage amplitude in Portugal
% voltage = 230;
% % so the sine wave looks like this
% tx = 1:max(size(data));
% voltageWave = voltage*sin(tx);
% % which make the RMS of the voltage
% voltageRMS = rms(voltageWave);

i = 1;
j = 1;
l = size(data);
while(i<l(1)+1)
    %calculate per 0.1s interval
    current_rms(j) = rms(data{i:min(i+round(0.5*Fs),l),"Current"});
    kurt(j) = kurtosis(data{i:min(i+round(0.5*Fs),l),"Current"});
    skew(j) = skewness(data{i:min(i+round(0.5*Fs),l),"Current"});
%     if(kurt(j)>150)
%         fprintf('%d\n',i)
%     end
    i = i + round(0.1*Fs);
    j = j + 1;
end

% Plot current RMS
powerCurrent = current_rms;%.*voltageRMS;
figure(3);
plot(flip(powerCurrent));
title('Average power of the current');
ylabel('RMS(A)')

% Plot current with skewness and kurtosis
figure(4);
sp(1) = subplot(3,1,1); 
plot(data{:,"Current"});
title('Current');
set(gca, 'XDir','reverse')
axis tight

sp(2) = subplot(3,1,2);
plot(flip(kurt));
title('Kurtosis of the current');

sp(3) = subplot(3,1,3);
plot(flip(skew));
title('Skewness of the current');

fprintf('Press any key to also plot the Kurtosis and skewness of the vibration.\n');
pause;
%% Kurtosis and skewness of vibration
fprintf('Plotting Kurtosis and skewness of the vibration.\n');
i = 1;
j = 1;
l = size(data);
while(i<l(1)+1)
    %calculate per 0.1s interval
    kurt(j) = kurtosis(data{i:min(i+round(0.5*Fs),l),"Vibration"});
    skew(j) = skewness(data{i:min(i+round(0.5*Fs),l),"Vibration"});
    i = i + round(0.1*Fs);
    j = j + 1;
end

% Plot vibration with skewness and kurtosis
figure(5);
subplot(3,1,1); 
plot(data{:,"Vibration"});
title('Vibration');
set(gca, 'XDir','reverse')
axis tight

subplot(3,1,2);
plot(flip(kurt));
title('Kurtosis of the vibration');

subplot(3,1,3);
plot(flip(skew));
title('Skewness of the vibration');

fprintf('Press any key to also plot a Spectral analysis of the current and vibration.\n');
pause;
%% Spectral analysis
fprintf('Plotting Spectral analysis. (Did you change the sample frequency accordingly?)\n');
display(Fs);
%vibration
% Subtract the average vibration to reduce the DC component
avgVibr = mean(data{:,"Vibration"});
freq_data = data{:,"Vibration"} - avgVibr;

% Select what part of the data to use(do the same for the current!)
x = flip(freq_data);
% x = flip(data{650000:1750000,"Vibration"});  % On cycle (29NOV)

% number of samples
n = length(x);
% fourier transform of signal
Y = fft(x);
% Remove lower frequencies(up until threshold)
threshold = 4;
Y(1:round(threshold*(n/Fs)))=0;
% Remove lower frequencies(double-sided spectrum)
Y(max(round(size(Y)-threshold*(n/Fs):size(Y)),1))=0;
% frequency range
f = (0:n-1)*(Fs/n);
% power of the DFT
power = abs(Y).^2/n;
% Print top 5 frequencies in the vibration spectrum
[value,LOCS]= findpeaks(power(1:round(n/2)),...                    % Don't check mirrored frequencies
                            'MinPeakDistance',10*(n/Fs), ...  % At least 10Hz apart
                            'sortstr','descend',...         % Sort in descending order
                            'NPeaks',5 ...                  % Take the top 5
                            );
fprintf('Max frequencies found in vibrations in descending order:\n');
fprintf('%1.1fHz\n',LOCS.*(Fs/n));

% figure(6)
% plot(f,power);
% title('Frequency spectrum Vibration');
% xlabel('Frequency (Hz)');
% ylabel('Power');

y0 = fftshift(Y);         % shift y values
f0 = (-n/2:n/2-1)*(Fs/n); % 0-centered frequency range
power0 = abs(y0).^2/n;    % 0-centered power


figure(7)
plot(f0,power0)
title('Double-sided Frequency spectrum Vibration');
xlabel('Frequency (Hz)')
ylabel('Power')

%Current
% Select what part of the data to use
x = flip(data{:,"Current"});
% x = flip(data{650000:1750000,"Current"});  % On cycle (29NOV)

Y = fft(x);
Y2 = Y;
Y2(max(round(50*(n/Fs)-10*(n/Fs)),1):min(round(50*(n/Fs)+10*(n/Fs)),length(Y)))=0;               %Remove 50Hz component
Y2(max(round(length(Y)-50*(n/Fs)-10*(n/Fs)),1):min(round(length(Y)-50*(n/Fs)+10*(n/Fs)),length(Y)))=0; %Remove 50Hz component(double-sided spectrum)
l = size(x);
n = length(x);          % number of samples
f = (0:n-1)*(Fs/n);     % frequency range
power = abs(Y).^2/n;    % power of the DFT

% figure(8)
% plot(f,power);
% title('Frequency spectrum Current');
% xlabel('Frequency (Hz)');
% ylabel('Power');

y0 = fftshift(Y);           % shift y values
y0_2 = fftshift(Y2);        % shift y values
f0 = (-n/2:n/2-1)*(Fs/n);   % 0-centered frequency range
power0 = abs(y0).^2/n;      % 0-centered power
power0_2 = abs(y0_2).^2/n;   % 0-centered power

figure(9)
plot(f0,power0)
title('Double-sided Frequency spectrum Current');
xlabel('Frequency (Hz)')
ylabel('Power')

figure(10)
plot(f0,power0_2)
title('Double-sided Frequency spectrum Current without 50Hz component');
xlabel('Frequency (Hz)')
ylabel('Power')

fprintf('Press any key to also plot a Time-Frequency analysis of the current and vibration.\n');
pause;
%% Time-Frequency analysis
fprintf('Plotting Time-Frequency analysis. (Did you change the sample frequency accordingly?)\n');
display(Fs);
% Using Continuous Wavelet Transform
% % current
% [cfs,frq] = cwt(flip(data{:,2}),Fs);
% tms = (0:numel(data{:,2})-1)/Fs;
% %Plot scalogram&signal
% figure(11)
% subplot(2,1,1); 
% % plot(tms,flip(data{:,2}))
% plot(timeseries(flip(data{:,2}),datenum(flip(data{:,1}))))
% axis tight
% datetick('x','HH:MM:ss')
% title('Signal and Scalogram')
% xlabel('Time')
% ylabel('Current (A)')
% 
% subplot(2,1,2); 
% surface(tms,frq,abs(cfs))
% axis tight
% shading flat
% set(gca,'xticklabel',[])
% xlabel('Time')
% ylabel('Frequency (Hz)')
% 
% % vibration
% [cfs,frq] = cwt(flip(data{:,3}),Fs);
% tms = (0:numel(data{:,3})-1)/Fs;
% %Plot scalogram&signal
% figure(12)
% subplot(2,1,1); 
% % plot(tms,flip(data{:,3}))
% plot(timeseries(flip(data{:,3}),datenum(flip(data{:,1}))))
% axis tight
% datetick('x','HH:MM:ss')
% title('Signal and Scalogram')
% xlabel('Time')
% ylabel('Vibration')
% 
% subplot(2,1,2); 
% surface(tms,frq,abs(cfs))
% axis tight
% shading flat
% set(gca,'xticklabel',[])
% xlabel('Time')
% ylabel('Frequency (Hz)')


% Using Short-Time Fourier Transform(faster&more lightweight)
% current
%Plot scalogram&signal
figure(11)
subplot(2,1,1); 
% plot(tms,flip(data{:,2}))
plot(timeseries(flip(data{:,"Current"}),datenum(flip(data{:,"Instance"}))))
datetick('x','HH:MM:ss')
title('Signal')
xlabel('Time')
ylabel('Current (A)')
axis tight

subplot(2,1,2); 
stft(flip(data{:,"Current"}),Fs,'FrequencyRange','onesided')


% vibration
%Plot scalogram&signal
figure(12)
subplot(2,1,1); 
% plot(tms,flip(data{:,3}))
plot(timeseries(flip(freq_data),datenum(flip(data{:,"Instance"}))))
datetick('x','HH:MM:ss')
title('Signal')
xlabel('Time')
ylabel('Vibration')
axis tight

subplot(2,1,2); 
stft(flip(freq_data),Fs,'FrequencyRange','onesided')