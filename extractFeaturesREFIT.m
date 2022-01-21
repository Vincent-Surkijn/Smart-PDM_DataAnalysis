function features = extractFeaturesREFIT(data,csvpath)
% extractFeaturesREFIT(data) extracts features from a REFIT file
% and writes them to a .csv file if a csvpath is specified
% If the .csv file already exists the features will be appended to the file
%
% extracted features:   period of average on cycle
%                       period of average off cycle
%                       amount of cycles during the day(8h-22h)
%                       amount of cycles during the night(22h-8h)
%
% features = a table with the extracted features
%
% data =        result from readtable(slowstreamfile)
%    e.g. data = readtable('1_12 - 6_12.csv', 'TextType','string');
% csvpath =     the path to the .csv file where the features should be
%               written to (without .csv extension)
%               should be left empty if the result should not be written to
%               a file
%

% To check amount of peaks quickly:
% Plot: findpeaks(data{:,"Current"},'MinPeakHeight',0.35,'MinPeakDistance',3000)
% [~,LOCS] = findpeaks(data{:,"Current"},'MinPeakHeight',0.35,'MinPeakDistance',3000);
%   --> LOCS contains indices of all the peaks so length(LOCS) will return
%   the amount of peaks

% Measure the time that the function takes
tic
% Initialize features table
features = table;

% Check amount of input args to see if result should be written to a file
if(nargin>2)
    error('This function should only be used with 1 or 2 input arguments\n');
elseif(nargin==1)
    writeFile = false;
elseif(nargin==2)
    writeFile = true;
end

% Initialisation of cycle parameters
l = max(size((data)));  % Length of the data
i = 1;  % To count indices
j = 1;  % To count indices
k = 1;  % To count indices
% Save the start date
currentDate = datetime(data{1,"Date"},"format","yyyy-MM-dd");
fprintf("First day: %s\n",currentDate);
nightCycles = 0;    % Amount of cycles at night(22-8h)
dayCycles = 0;      % Amount of cycles during the day(8-22h)
onCycles = 0;         % Amount of cycles in a day(24h)
onTimes = 0;        % Lengths of on cycles
offTimes = 0;       % Lengths of off cycles
dates(1) = currentDate;          % Save dates

% Determine at what index to start(don't want to start in the middle of an
% on/off cycle)
% If the power is greater than 70 then the file starts in the middle of an on cycle
if(data{i,"ActivePower"}>70)
    fprintf("File starts in the middle of an on cycle.\n");
    % Jump to the end of the cycle
    i = i + find(data{i:l,"ActivePower"}==0, 1, 'first');
% else it is an off cycle
else
    fprintf("File starts in the middle of an off cycle.\n");
    % Jump to the end of the cycle
    i = i + find(data{i:l,"ActivePower"}~=0, 1, 'first');
end

%TODO: offTimes indices problem
% Cycle
while(i<l+1)
    % If a new day started
    if(day(currentDate)~=day(data{i,"Date"}))
        % Update the date
        currentDate = datetime(data{i,"Date"},"format","yyyy-MM-dd");
        fprintf("New day detected: %s\n",currentDate);
        % Start a new element to increment in the vectors
        onTimes(end+1,end+1) = 0;
        offTimes(end+1,end+1) = 0;
        onCycles(end+1) = 0;
        j = 1;
        k = 1;
        dayCycles(end+1) = 0;
        nightCycles(end+1) = 0;
        % Save new date
        dates(end+1) = currentDate;
    end

    % If the power is greater than 70 then it is an on cycle
    if(data{i,"ActivePower"}>70)
        % Increment the amount of on cycles of this day
        onCycles(end) = onCycles(end) + 1;
        % If the cycle occured between 22h and 8h: it was at night
        if(hour(data{i,"Date"})<8 || hour(data{i,"Date"})>22)
            nightCycles(end) = nightCycles(end) + 1;
        % It was during the day
        else
            dayCycles(end) = dayCycles(end) + 1;
        end

        % Save start index of on cycle
        idxStartOn = i;
        found = false;
        while(not(found))
            % Jump to the end of the cycle
            i = i + find(data{i:l,"ActivePower"}==0, 1, 'first');
            % Prevent single 0 to be detected as off cycle
            if(data{i+1,"ActivePower"}==0)
                %TODO: improve
                % Cycle needs to be larger than 20min
                if(etime(datevec(data{i,"Date"}),datevec(data{idxStartOn,"Date"}))>20*60)
                    found = true;
                end
            end
            % Do not record the cycle's duration if it does not end before the end of the data
            % find() returns empty if it does not find a result
            if(isempty(i))
                break;
            end
        end

        % find() returns empty if it does not find a result
        if(isempty(i))
            break;
        end

        % Calculate time of on cycle
        timeOn = etime(datevec(data{i,"Date"}),datevec(data{idxStartOn,"Date"}));
        % Append length to vector (row=1day;column=1st cycle)
        % Round it to a second because more decimal places are inaccurate
        onTimes(end,j) = round(timeOn);
        % Increment counter
        j = j + 1;
    else
        % Save start index of off cycle
        idxStartOff = i;
        % Jump to next on cycle (greater than 70 to prevent noise detection)
        i = i + find(data{i:l,"ActivePower"}>70, 1, 'first');
        % Do not record the cycle's duration if it does not end before the end of the data
        % find() returns empty if it does not find a result
        if(isempty(i))
            break;
        end
        % Calculate time of off cycle
        timeOff = etime(datevec(data{i,"Date"}),datevec(data{idxStartOff,"Date"}));
        % Append length to vector (row=1day;column=1st cycle)
        % Round it to a second because more decimal places are inaccurate
        offTimes(end,k) = round(timeOff);
        % Increment counter
        k = k + 1;
    end
end

% nightCycles
% dayCycles
% onCycles
% onTimes
% offTimes

% Calculate the average times without the zero values
avgOnTimes = sum(onTimes');
amount = sum(onTimes'~=0);
% Round to a second
avgOnTimes = round(avgOnTimes./amount);

avgOffTimes = sum(offTimes');
amount = sum(offTimes'~=0);
% Round to a second
avgOffTimes = round(avgOffTimes./amount);

% Create features table
features.date = dates';
features.cycles_in_a_day = onCycles';
features.period_of_average_on_cycle = avgOnTimes';
features.period_of_average_off_cycle = avgOffTimes';
features.cycles_during_the_day_8to22 = dayCycles';
features.cycles_during_the_night_22to8 = nightCycles';
features.onTimes = onTimes;
features.offTimes = offTimes;

% Write results to a file if a path was indicated
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