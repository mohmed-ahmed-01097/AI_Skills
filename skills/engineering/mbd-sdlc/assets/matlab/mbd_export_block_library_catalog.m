function reportPath = mbd_export_block_library_catalog(outputDir, searchDepth)
%MBD_EXPORT_BLOCK_LIBRARY_CATALOG Export installed Simulink library block sample.
% Description:
%   Writes a Markdown catalog of blocks found under the Simulink library at
%   the requested search depth, including block type, mask type, and dialog
%   parameter names.
%
% Inputs:
%   outputDir    - Optional output directory. Defaults to .MBD_agent/reports.
%   searchDepth  - Optional find_system search depth. Defaults to 4.
%
% Outputs:
%   reportPath   - Path to generated Markdown catalog.

if nargin < 1 || isempty(outputDir)
    outputDir = fullfile(pwd, '.MBD_agent', 'reports');
end
if nargin < 2 || isempty(searchDepth)
    searchDepth = 4;
end
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
reportPath = fullfile(outputDir, 'simulink_block_library_catalog.md');
fid = fopen(reportPath, 'w');
if fid < 0
    error('mbd_export_block_library_catalog:FileOpenFailed', 'Could not write %s.', reportPath);
end
cleanupObj = onCleanup(@() fclose(fid));

fprintf(fid, '# Simulink block library catalog\n\n');
fprintf(fid, '- Generated: %s\n', datestr(now, 31));
fprintf(fid, '- Search depth: %d\n\n', searchDepth);

try
    load_system('simulink');
    blocks = find_system('simulink', 'SearchDepth', searchDepth, 'Type', 'Block');
catch ME
    fprintf(fid, 'Could not load/search Simulink library: `%s`\n', esc(ME.message));
    return;
end

fprintf(fid, '| Library path | BlockType | MaskType | Dialog parameters |\n');
fprintf(fid, '|---|---|---|---|\n');
for i = 1:numel(blocks)
    b = blocks{i};
    paramsText = '';
    try
        params = get_param(b, 'DialogParameters');
        paramsText = strjoin(fieldnames(params)', ', ');
    catch
        paramsText = '';
    end
    fprintf(fid, '| `%s` | %s | %s | %s |\n', esc(b), esc(getp(b, 'BlockType')), esc(getp(b, 'MaskType')), esc(paramsText));
end
end

function value = getp(pathName, paramName)
try
    value = get_param(pathName, paramName);
catch
    value = '';
end
end

function out = esc(in)
out = char(string(in));
out = strrep(out, '|', '\|');
out = strrep(out, newline, ' ');
end
