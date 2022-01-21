%% Erasmus project - extractFeaturesFromMultipleFiles
% This script takes all slow stream csv files in a folder, extracts features from them
% and writes these features to another csv file(csvpath)

%% Main
% clear; clc;
% Enter the path to the folder followed by \*.csv (has to be between '')
folder = '.\VPS_Software\240AC4514170\Slowstreams\Feature extraction\*.csv'

% Enter the path to the file where the features will be written to
csvpath = ".\VPS_Software\240AC4514170\featuresV2";

files = subdir(folder);

filenames = {files(:,1).name};

fprintf("Files to be read:\n");
filenames'

fprintf("Reading files...\n");

% Read the first file
data = readtable(filenames{1}, 'TextType','string');

l = max(size(filenames));
i = 2;
while(i<l+1)
    data = vertcat(data,readtable(filenames{i}, 'TextType','string'));
    i = i + 1;
end

% Sort data by time first
data = sortrows(data,2,"ascend");

% Extract features
fprintf("Extracting features...\n");
features = extractFeaturesSlowstream(data,csvpath);