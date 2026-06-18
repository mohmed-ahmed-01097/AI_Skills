function blockHandle = add_place(libraryBlock, destinationPath, x, y, width, height, varargin)
%ADD_PLACE Add a Simulink block with deterministic placement.
% Description:
%   Adds a block from a verified Simulink library path to a destination path
%   and sets its position from x, y, width, and height. Width and height are
%   optional; defaults are used when they are omitted or empty.
%
% Inputs:
%   libraryBlock    - Source library block path, for example 'simulink/Math Operations/Gain'.
%   destinationPath - Destination block path, for example 'myModel/Controller/Kp'.
%   x               - Left position in pixels.
%   y               - Top position in pixels.
%   width           - Optional block width in pixels.
%   height          - Optional block height in pixels.
%   varargin        - Optional name/value pairs passed to add_block.
%
% Outputs:
%   blockHandle     - Handle of the added block.

if nargin < 4
    error('add_place:NotEnoughInputs', 'libraryBlock, destinationPath, x, and y are required.');
end
if nargin < 5 || isempty(width)
    width = 90;
end
if nargin < 6 || isempty(height)
    height = 40;
end

if ~ischar(libraryBlock) && ~isstring(libraryBlock)
    error('add_place:InvalidLibraryBlock', 'libraryBlock must be a character vector or string scalar.');
end
if ~ischar(destinationPath) && ~isstring(destinationPath)
    error('add_place:InvalidDestinationPath', 'destinationPath must be a character vector or string scalar.');
end

libraryBlock = char(libraryBlock);
destinationPath = char(destinationPath);
position = [x y x + width y + height];

add_block(libraryBlock, destinationPath, 'Position', position, varargin{:});
blockHandle = get_param(destinationPath, 'Handle');
end
