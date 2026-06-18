function reportPath = mbd_export_workspace_state(modelName, outputDir)
%MBD_EXPORT_WORKSPACE_STATE Export base/model workspace and data dictionary.
% Description:
%   Writes a Markdown report describing base workspace variables, model
%   workspace variables, the model data dictionary (if linked), and a
%   list of MAT files found in the current folder and its subfolders.
%
% Inputs:
%   modelName - Optional model name. Pass empty to export base workspace only.
%   outputDir - Optional output directory. Defaults to .MBD_agent/workspace.
%
% Outputs:
%   reportPath - Path to generated Markdown report.

if nargin < 1, modelName = ''; end
if nargin < 2 || isempty(outputDir)
    outputDir = fullfile(pwd, '.MBD_agent', 'workspace');
end
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
reportPath = fullfile(outputDir, 'workspace_state.md');
fid = fopen(reportPath, 'w');
if fid < 0
    error('mbd_export_workspace_state:FileOpenFailed', 'Could not write %s.', reportPath);
end
cleanupObj = onCleanup(@() fclose(fid));

fprintf(fid, '# Workspace state\n\n');
fprintf(fid, '- Generated: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
fprintf(fid, '- Model: `%s`\n\n', esc(modelName));

% Base workspace.
fprintf(fid, '## Base workspace\n\n');
try
    vars = evalin('base', 'whos');
    writeWhosTable(fid, vars);
catch ME
    fprintf(fid, 'Could not inspect base workspace: `%s`\n', esc(ME.message));
end

if ~isempty(modelName)
    modelName = char(modelName);
    if ~bdIsLoaded(modelName)
        load_system(modelName);
    end

    % Model workspace.
    fprintf(fid, '\n## Model workspace\n\n');
    try
        mws  = get_param(modelName, 'ModelWorkspace');
        vars = whos(mws);
        writeWhosTable(fid, vars);
    catch ME
        fprintf(fid, 'Could not inspect model workspace: `%s`\n', esc(ME.message));
    end

    % Data dictionary.
    fprintf(fid, '\n## Model data dictionary\n\n');
    try
        dd = get_param(modelName, 'DataDictionary');
        if isempty(dd)
            fprintf(fid, 'No data dictionary configured.\n');
        else
            fprintf(fid, '- Dictionary: `%s`\n', esc(dd));
            mbd_export_data_dictionary(dd, outputDir);
            fprintf(fid, '- Detailed export written to `%s`.\n', esc(outputDir));
        end
    catch ME
        fprintf(fid, 'Could not inspect data dictionary: `%s`\n', esc(ME.message));
    end
end

% MAT files in project tree.
fprintf(fid, '\n## MAT files found in project tree\n\n');
try
    matFiles = dir(fullfile(pwd, '**', '*.mat'));
    if isempty(matFiles)
        fprintf(fid, '_No .mat files found._\n');
    else
        fprintf(fid, '| Path | Size (bytes) | Modified |\n|---|---:|---|\n');
        for i = 1:numel(matFiles)
            fp = fullfile(matFiles(i).folder, matFiles(i).name);
            relPath = strrep(fp, pwd, '.');
            fprintf(fid, '| `%s` | %d | %s |\n', esc(relPath), ...
                matFiles(i).bytes, datestr(matFiles(i).datenum, 'yyyy-mm-dd HH:MM:SS'));
        end
    end
catch ME
    fprintf(fid, 'Could not scan for MAT files: `%s`\n', esc(ME.message));
end
end

function writeWhosTable(fid, vars)
fprintf(fid, '| Name | Size | Bytes | Class | Global | Sparse | Complex |\n');
fprintf(fid, '|---|---|---:|---|---|---|---|\n');
for i = 1:numel(vars)
    sz = strjoin(arrayfun(@num2str, vars(i).size, 'UniformOutput', false), 'x');
    fprintf(fid, '| `%s` | %s | %d | %s | %d | %d | %d |\n', ...
        esc(vars(i).name), esc(sz), vars(i).bytes, esc(vars(i).class), ...
        vars(i).global, vars(i).sparse, vars(i).complex);
end
if isempty(vars)
    fprintf(fid, '| - | - | - | - | - | - | - |\n');
end
end

function out = esc(in)
out = char(string(in));
out = strrep(out, '|', '\|');
out = strrep(out, newline, ' ');
end
