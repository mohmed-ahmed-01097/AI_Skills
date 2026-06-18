% config_layout.m — Layout preset for <ModelName>.
% Copy this file to .MBD_agent/scripts/ and edit for the target model.
% Import it at the top of your model creation/edit script:
%   run(fullfile('.MBD_agent', 'scripts', 'config_layout.m'));

% --- Canvas origin ---
LAYOUT_ORIGIN_X = 50;
LAYOUT_ORIGIN_Y = 50;

% --- Default block dimensions (pixels) ---
LAYOUT_BLOCK_W  = 90;
LAYOUT_BLOCK_H  = 40;
LAYOUT_BLOCK_W_WIDE = 120;  % for subsystems or MATLAB Function blocks
LAYOUT_BLOCK_H_TALL = 60;   % for blocks with many ports

% --- Horizontal spacing between blocks ---
LAYOUT_COL_GAP  = 60;   % gap between right edge of one block and left of next

% --- Vertical spacing between blocks in the same column ---
LAYOUT_ROW_GAP  = 30;

% --- Column X positions (left edge of block) ---
% Compute as: LAYOUT_ORIGIN_X + col * (LAYOUT_BLOCK_W + LAYOUT_COL_GAP)
LAYOUT_COL1_X = LAYOUT_ORIGIN_X;
LAYOUT_COL2_X = LAYOUT_COL1_X + LAYOUT_BLOCK_W + LAYOUT_COL_GAP;
LAYOUT_COL3_X = LAYOUT_COL2_X + LAYOUT_BLOCK_W + LAYOUT_COL_GAP;
LAYOUT_COL4_X = LAYOUT_COL3_X + LAYOUT_BLOCK_W + LAYOUT_COL_GAP;

% --- Row Y positions (top edge of block) ---
LAYOUT_ROW1_Y = LAYOUT_ORIGIN_Y + 60;   % leave room for title annotation
LAYOUT_ROW2_Y = LAYOUT_ROW1_Y + LAYOUT_BLOCK_H + LAYOUT_ROW_GAP;
LAYOUT_ROW3_Y = LAYOUT_ROW2_Y + LAYOUT_BLOCK_H + LAYOUT_ROW_GAP;
LAYOUT_ROW4_Y = LAYOUT_ROW3_Y + LAYOUT_BLOCK_H + LAYOUT_ROW_GAP;