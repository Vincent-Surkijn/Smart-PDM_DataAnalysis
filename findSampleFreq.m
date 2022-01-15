function fs = findSampleFreq(data)
% fs = findSampleFreq(data) returns the (rough) sampling frequency found
% from the data
%
% fs =      the found sampling frequency
%
% data =    (n x 3) matrix where n is the amount of samples. The 
%           columns should be instance, current, vibration in that order 
%
% e.g.      data =  | Instance                         Current      Vibration |
%                   | "2021-11-23 11:52:27.8555300"    0.0029826    0.012593  |
%                   |           ...                       ...          ...    |
%                   |           ...                       ...          ...    |

% fs = 1 / (mean(diff(datenum(flip(data{:,1}),"yyyy-mm-dd HH:MM:ss.FFF"))*24*3600));
fs = 1 / (mean(diff(datenum(flip(data{:,"Instance"})))*24*3600));

% way to find seconds between 2 timestamps:
% etime(datevec('22-Nov-2021 12:15:03'),datevec('22-Nov-2021 12:09:39'))