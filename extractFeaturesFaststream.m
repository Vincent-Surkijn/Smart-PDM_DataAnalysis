function features = extractFeaturesFaststream(data,csvpath,Fs)
% extractFeaturesFaststream(data,csvpath,Fs) extracts features from a faststream file
% and writes them to a .csv file a csvpath is defined. The function will be
% faster when specifying Fs.  If the .csv file already exists the features 
% will be appended to the file
% 
% Function can be used as:  extractFeaturesFaststream(data)
%                           extractFeaturesFaststream(data,csvpath)
%                           extractFeaturesFaststream(data,csvpath,Fs)
%
% extracted features:   top 5 frequencies and their corresponding power
%						mean frequency
%						central frequency
%						rms frequency
%						root variance frequency
%						skewness and kurtosis of spectrum
%	Frequency features will only be measured in the on part of the on/off cycle!
%
%
% features = table with the extracted features
%
% data =        result from readtable(faststreamfile)
%    e.g. data = readtable('98F4AB08E738-FastStreamStored-ID2492-2021-12-14 045858_clean', 'TextType','string');
% csvpath =     the path to the .csv file where the features should be
%               written to (without .csv extension)
%               should be left empty if the result should not be written to
%               a file
% Fs =          sampling frequency
%

% Measure the time that the function takes
tic

% Check amount of input args to see if result should be written to a file
if(nargin>3)
    error('This function should only be used with max 3 input arguments\n');
elseif(nargin==1)
    writeFile = false;
    Fs = findSampleFreq(data)
elseif(nargin==2)
    if(not(isstring(csvpath)))
        error('When only using 2 args, the second  should be a string');
    end
    writeFile = true;
    Fs = findSampleFreq(data)
elseif(nargin==3)
    writeFile = true;
end


% Initialize features table
features = table;
% Save the first instance to identify the data from which the features were extracted
features.instance = data{1,"Instance"};

%% Convert vibration data to frequency domain
% Subtract the average vibration to reduce the DC component
avgVibr = mean(data{:,"Vibration"});
freq_data = data{:,"Vibration"} - avgVibr;

% sort according to time
x = flip(freq_data);
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

%% Extract vibration related features
% Top 5 frequencies in the vibration spectrum
[vibrFreqsvals,vibrFreqs]= findpeaks(power(1:round(n/2)),...               % Don't check mirrored frequencies
                            'MinPeakDistance',10*(n/Fs), ...  % At least 10Hz apart
                            'sortstr','descend',...         % Sort in descending order
                            'NPeaks',5 ...                  % Take the top 5
                            );
fprintf('Max frequencies found in vibrations in descending order:\n');
fprintf('%1.1fHz\n',vibrFreqs.*(Fs/n));
% Convert to frequency values
vibrFreqs = vibrFreqs.*(Fs/n);
% Write to features table
features.vibrFreq1 = vibrFreqs(1);
features.vibrFreq2 = vibrFreqs(2);
features.vibrFreq3 = vibrFreqs(3);
features.vibrFreq4 = vibrFreqs(4);
features.vibrFreq5 = vibrFreqs(5);

features.vibrFreqsvals1 = vibrFreqsvals(1);
features.vibrFreqsvals2 = vibrFreqsvals(2);
features.vibrFreqsvals3 = vibrFreqsvals(3);
features.vibrFreqsvals4 = vibrFreqsvals(4);
features.vibrFreqsvals5 = vibrFreqsvals(5);

% Mean frequency
meanFreqVibr = meanfreq(power,Fs);
features.mean_frequency_vibration = meanFreqVibr;
% Use the following one to get a plot
% figure(1)
% meanfreq(power,Fs)

% Plot Vibration spectrum
figure(2)
plot(f(1:round(n/2)),power(1:round(n/2)));
title('Frequency spectrum Vibration');
xlabel('Frequency (Hz)');
ylabel('Power');

%% Convert current data to frequency domain
x = flip(data{:,"Current"});
Y = fft(x);
Y2 = Y;
%Remove 50Hz component
Y2(max(round(50*(n/Fs)-10*(n/Fs)),1):min(round(50*(n/Fs)+10*(n/Fs)),length(Y)))=0;
%Remove 50Hz component(double-sided spectrum)
Y2(max(round(length(Y)-50*(n/Fs)-10*(n/Fs)),1):min(round(length(Y)-50*(n/Fs)+10*(n/Fs)),length(Y)))=0;
% number of samples
n = length(x);
% frequency range
f = (0:n-1)*(Fs/n);
% power of the DFT
power = abs(Y).^2/n;
power2 = abs(Y2).^2/n;

% Top 5 frequencies in the current spectrum
[currentFreqsvals,currentFreqs]= findpeaks(power(1:round(n/2)),...                % Don't check mirrored frequencies
                            'MinPeakDistance',10*(n/Fs), ...  % At least 10Hz apart
                            'sortstr','descend',...         % Sort in descending order
                            'NPeaks',5 ...                  % Take the top 5
                            );
fprintf('Max frequencies found in current in descending order:\n');
fprintf('%1.1fHz\n',currentFreqs.*(Fs/n));
% Convert to frequency values
currentFreqs = currentFreqs.*(Fs/n);
% Write to features table
features.currentFreqs1 = currentFreqs(1);
features.currentFreqs2 = currentFreqs(2);
features.currentFreqs3 = currentFreqs(3);
features.currentFreqs4 = currentFreqs(4);
features.currentFreqs5 = currentFreqs(5);

features.currentFreqsvals1 = currentFreqsvals(1);
features.currentFreqsvals2 = currentFreqsvals(2);
features.currentFreqsvals3 = currentFreqsvals(3);
features.currentFreqsvals4 = currentFreqsvals(4);
features.currentFreqsvals5 = currentFreqsvals(5);

% Mean frequency
meanFreqCurrent = meanfreq(power,Fs);
features.mean_frequency_current = meanFreqCurrent;
% Use the following one to get a plot
% figure(3)
% meanfreq(power,Fs)

% Top 5 frequencies in the current spectrum without 50Hz
[currentWo50Freqsvals,currentWo50Freqs]= findpeaks(power2(1:round(n/2)),...   % Don't check mirrored frequencies
                            'MinPeakDistance',10*(n/Fs), ...  % At least 10Hz apart
                            'sortstr','descend',...         % Sort in descending order
                            'NPeaks',5 ...                  % Take the top 5
                            );
fprintf('Max frequencies found in current without 50Hz in descending order:\n');
fprintf('%1.1fHz\n',currentWo50Freqs.*(Fs/n));
% Convert to frequency values
currentWo50Freqs = currentWo50Freqs.*(Fs/n);
% Write to features table
features.currentWo50Freqs1 = currentWo50Freqs(1);
features.currentWo50Freqs2 = currentWo50Freqs(2);
features.currentWo50Freqs3 = currentWo50Freqs(3);
features.currentWo50Freqs4 = currentWo50Freqs(4);
features.currentWo50Freqs5 = currentWo50Freqs(5);

features.currentWo50Freqsvals1 = currentWo50Freqsvals(1);
features.currentWo50Freqsvals2 = currentWo50Freqsvals(2);
features.currentWo50Freqsvals3 = currentWo50Freqsvals(3);
features.currentWo50Freqsvals4 = currentWo50Freqsvals(4);
features.currentWo50Freqsvals5 = currentWo50Freqsvals(5);

% Mean frequency
meanFreqCurrentWo50 = meanfreq(power2,Fs);
features.mean_frequency_currentWo50 = meanFreqCurrentWo50;
% Use the following one to get a plot
% figure(4)
% meanfreq(power2,Fs)

% Plot spectra of current with and without 50Hz component
figure(5)
plot(f(1:round(n/2)),power(1:round(n/2)));
title('Frequency spectrum Current');
xlabel('Frequency (Hz)');
ylabel('Power');

figure(6)
plot(f(1:round(n/2)),power2(1:round(n/2)));
title('Frequency spectrum Current without 50Hz');
xlabel('Frequency (Hz)');
ylabel('Power');

%% Write results to file if the path was indicated
if(writeFile)
    try
        writetable(features,strcat(csvpath,".csv"),'WriteMode','Append',...
                    'WriteVariableNames',not(isfile(strcat(csvpath,".csv"))));
    catch err
        fprintf("Error writing to file:\n %s\n", err);
    end
end

% Measure the time that the function takes
toc