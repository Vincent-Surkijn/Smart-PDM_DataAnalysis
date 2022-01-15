function [indices1,ts,value] = detectOnCycle(data,varargin)
% indices = detectOnCycle(data) detects the start of an on cycle of the 
% refrigerator by using the measured current.
% Start is detected within less than 1/10th of a second!
%
% [indices,ts,value] = detectOnCycle(data,fs) uses the sampling frequency
% inputted by you and will make the function faster.
%
% indices = the indices of where the on cycle(s) start
% ts =      the timestamp(s) at which the peak(s) occur(s)
% value =   the value(s) of the peak(s) that started the cycle(s)
%
% data =    (n x 3) matrix where n is the amount of samples. The 
%           columns should be instance, current, vibration in that order
% fs =      the sampling frequency used to collect the data. Can also be
%           retrieved from the data, but it will make the function slower.
%
% e.g.      data =  | Instance                         Current      Vibration |
%                   | "2021-11-23 11:52:27.8555300"    0.0029826    0.012593  |
%                   |           ...                       ...          ...    |
%                   |           ...                       ...          ...    |


if(nargin>2)
    error('This function should only be used with 1 or 2 input arguments\n');
elseif(nargin==1)
    % if the sample frequency is not given, calculate it
    fs = round(findSampleFreq(data),0)
elseif(nargin==2)
    fs = varargin{1};
end

l = size(data);
indices1 = zeros(1,1);
value = zeros(1,1);
flipped = flip(data{:,"Current"});
flipped2 = flip(data{:,"Vibration"});


% Find all peaks bigger than 10 times the average rms and at least 5s apart
[~,LOCS] = findpeaks(flipped,'MinPeakHeight',(rms(data{:,"Current"}))*10,'MinPeakDistance',(5*fs));

% Plot peaks if there are any
if(size(LOCS) > 0)% if peaks founds
    figure;
    plot(flipped);
    hold on;
    plot(LOCS,flipped(LOCS),'o','MarkerSize',5);
    title('Start(s) of on cycle(s) detected via findpeaks method');
else     % if no peaks founds
    fprintf('No start(s) of on cycle(s) found with findpeaks method\n');
    indices1 = -1;
    value = -1;
    ts = -1;
    % check if the end of an on cycle was detected
    ipt = findchangepts(flipped,'Statistic','rms');
    % compare rms  from 5min=300s until 5s before and from 5s until 5min=300s after the change
    rms_before = rms(flipped( max(ipt-(300*fs),1): min(ipt+(5*fs),l(1))));
    rms_after = rms(flipped( min(ipt+(5*fs),l(1)): min(ipt+(300*fs),l(1)) ));
    % check if the change is sufficiently high to indicate the end of an on cycle
    if( rms_before >= rms_after*5 )
        fprintf('Only the end of the on cycle is captured!\n');
        fprintf('End of cycle at index %d\n',ipt);
        display(data{l(1)-ipt,"Instance"});  % print the timestamp
    else    
        %TODO: differentiate between on and off cycle
        fprintf('No change of cycles detected!\n');
    end
    return;
end


% Compare rms of current before and after peak
i = 1;
j = 1;
len = size(LOCS);
while(i < len(1)+1)
    % check if the rms increases after the initial peak
    % peak is over after 3s ==> 3*fs samples further
    % take a sufficient chunk(5min/300s) of the running cycle
    start = min(LOCS(i)+(3*fs),l(1));
    stop = min(LOCS(i)+300*fs,l(1));
    % check rms of the off cycle(from 5min before until 3 seconds before)
    rms_offCycle = rms(flipped( max(LOCS(i)-(300*fs),1):max(LOCS(i)-3*fs,1)));
    if( (rms(flipped( start:stop )) >= (5*rms_offCycle)) && rms_offCycle~= 0)
        indices1(j) = LOCS(i);
%         value(j) = flipped(LOCS(i));
        j = j + 1;
    end
    i = i + 1;
end

% Plot peaks if there are any
if(indices1(1) ~= 0)
    figure;
    plot(flipped);
    hold on;
    plot(indices1,flipped(indices1),'o','MarkerSize',5);
    title('Start(s) of on cycle(s) detected via combined method');
else
    fprintf('No start(s) of on cycle(s) found with combined method\n');
end


% Compare rms of vibration before and after peak
i = 1;
j = 1;
len = size(indices1);
indices = zeros(1,1);
while(i < max(len)+1 && indices1(1) ~= 0)
    % all vibrations stronger than 1.0E-04 are not noise
    threshold = 0.0001;
    if( rms(flipped2( indices1(i):min(indices1(i)+300*fs,l(1)-3*fs )))>=threshold)
        indices(j) = indices1(i);
        value(j) = flipped2(indices1(i));
        j = j + 1;
    end
    i = i + 1;
end


% Detect end of on cycle
len = size(indices1);
i = 1;
while(i<max(len))
    end_cycle1(i) = (indices(i)+(10*fs))...
        + findchangepts(flipped( indices(i)+(10*fs):indices(i+1)+(10*fs) ),'Statistic','rms');
    i = i + 1;
end
% Final endpoint is from last peak until end of data
end_cycle1(i) = (indices(i)+(10*fs))...
    + findchangepts(flipped( indices(i)+(10*fs):l(1) ),'Statistic','rms');


% check if changepoints are actually the end of a cycle
i = 1;
j = 1;
len = size(end_cycle1);
end_cycle = zeros(1,1);
while(i<max(len)+1)
    % compare rms 5s before and 5s after the change
    rms_before = rms(flipped( max(end_cycle1(i)-(300*fs),1): min(end_cycle1(i)+(5*fs),l(1))));
    rms_after = rms(flipped( min(end_cycle1(i)+(5*fs),l(1)): min(end_cycle1(i)+(300*fs),l(1)) ));
    % check if the change is sufficiently high to indicate the end of an on cycle
    if( rms_before >= rms_after*5 )     
        end_cycle(j) = end_cycle1(i);
        j = j + 1;
        fprintf('End of cycle at index %d\n',end_cycle1(i));
        display(data{l(1)-end_cycle1(i),"Instance"});  % print the timestamp
    end
    i = i + 1;
end

% Plot peaks if there are any
if(indices(1) ~= 0)
    figure;
    % Plot current
    subplot(2,1,1);
    plot(flipped);
    hold on;
    plot(indices,flipped(indices),'o','MarkerSize',5);
    title('Start(s) of on cycle(s) detected via ultra combined method');
    if(end_cycle(1) ~= 0)
        hold on;
        xline(end_cycle,'-g');
    end
    % Plot vibration
    subplot(2,1,2);
    plot(flipped2);
    hold on;
    plot(indices,flipped2(indices),'o','MarkerSize',5);
    title('Start(s) of on cycle(s) detected via ultra combined method');
    if(end_cycle(1) ~= 0)
        hold on;
        xline(end_cycle,'-g');
    end
else
    fprintf('No start(s) of on cycle(s) found with ultra combined method\n');
end

% return variables
% Do (size - indices) because data is flipped for calculations
% This is done because the data is loaded from new(top) to old(bottom)
% So the indices you get in return can be used to retrieve the samples from
% the original data file
l = size(data);
indices1 = l(1) - indices1;
ts = data{indices1,"Instance"};