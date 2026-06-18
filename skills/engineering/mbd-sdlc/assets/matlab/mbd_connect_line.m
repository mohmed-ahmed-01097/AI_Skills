function lineHandle = mbd_connect_line(systemPath, sourcePort, destinationPort, varargin)
%MBD_CONNECT_LINE Connect two Simulink ports with clear default routing.
% Description:
%   Adds a line between source and destination ports using autorouting by
%   default. Pass additional name/value pairs to override add_line options.
%
% Inputs:
%   systemPath      - Parent system path.
%   sourcePort      - Source port string such as 'Gain/1'.
%   destinationPort - Destination port string such as 'Out1/1'.
%   varargin        - Optional add_line name/value pairs.
%
% Outputs:
%   lineHandle      - Handle of the created line.

if isempty(varargin)
    lineHandle = add_line(systemPath, sourcePort, destinationPort, 'autorouting', 'on');
else
    lineHandle = add_line(systemPath, sourcePort, destinationPort, varargin{:});
end
end
