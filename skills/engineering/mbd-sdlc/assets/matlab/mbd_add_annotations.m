function mbd_add_annotations(systemPath, titleText, subtitleText)
%MBD_ADD_ANNOTATIONS Add centered title and optional subtitle to a model/subsystem.
% Description:
%   Adds text annotation blocks at the top of the canvas for a generated or
%   edited model or subsystem. Title uses a larger font; subtitle is smaller.
%   Positions are computed to center text near the top of the canvas.
%
% Inputs:
%   systemPath    - Model or subsystem path.
%   titleText     - Title string.
%   subtitleText  - Optional subtitle string. Pass empty to skip.
%
% Outputs:
%   None.

systemPath = char(systemPath);
if nargin < 3
    subtitleText = '';
end

open_system(systemPath);

% Estimate canvas width from existing block positions.
blocks = find_system(systemPath, 'SearchDepth', 1, 'Type', 'Block');
canvasWidth = 600; % default
if ~isempty(blocks)
    positions = cell2mat(cellfun(@(b) get_param(b, 'Position'), blocks, ...
        'UniformOutput', false)');
    if ~isempty(positions)
        canvasWidth = max(positions(:, 3)) + 100;
    end
end

centerX = round(canvasWidth / 2);

% Add title annotation.
if ~isempty(titleText)
    add_block('built-in/Note', [systemPath '/Title_Annotation'], ...
        'Position', [centerX - 150, 10, centerX + 150, 35], ...
        'Text', titleText, ...
        'FontSize', '14', ...
        'HorizontalAlignment', 'center', ...
        'DropShadow', 'off');
end

% Add subtitle annotation below the title.
if ~isempty(subtitleText)
    add_block('built-in/Note', [systemPath '/Subtitle_Annotation'], ...
        'Position', [centerX - 150, 38, centerX + 150, 56], ...
        'Text', subtitleText, ...
        'FontSize', '10', ...
        'HorizontalAlignment', 'center', ...
        'DropShadow', 'off');
end

save_system(strtok(systemPath, '/'));
end