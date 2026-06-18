function reportPath = mbd_run_model_advisor(modelName, outputDir, checkGroups)
%MBD_RUN_MODEL_ADVISOR Run Model Advisor checks and write an evidence log.
% Description:
%   Loads the model, attempts a Model Advisor run for the requested check
%   groups, and writes a Markdown log. API availability varies by release
%   and installed products; any failure is logged rather than hidden.
%
% Inputs:
%   modelName   - Model name.
%   outputDir   - Optional output directory. Defaults to .MBD_agent/reports.
%   checkGroups - Optional cell array of check group IDs.
%                 Defaults to MAAB and high-impact checks when available.
%
% Outputs:
%   reportPath  - Path to generated Markdown log.

if nargin < 2 || isempty(outputDir)
    outputDir = fullfile(pwd, '.MBD_agent', 'reports');
end
if nargin < 3
    checkGroups = {};
end
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

reportPath = fullfile(outputDir, [char(modelName) '_model_advisor.md']);
fid = fopen(reportPath, 'w');
if fid < 0
    error('mbd_run_model_advisor:FileOpenFailed', 'Could not write %s.', reportPath);
end
cleanupObj = onCleanup(@() fclose(fid));

fprintf(fid, '# Model Advisor run: `%s`\n\n', char(modelName));
fprintf(fid, '- Generated: %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

% Load model.
try
    load_system(modelName);
catch ME
    fprintf(fid, 'Could not load model: `%s`\n', esc(ME.message));
    return;
end

% Check whether Model Advisor class is available via try-catch (more reliable
% than exist() on a package method across releases).
maAvailable = false;
try
    ma = ModelAdvisor.getModelAdvisor(modelName); %#ok<NASGU>
    maAvailable = true;
catch
end

if ~maAvailable
    fprintf(fid, 'ModelAdvisor API was not found in this MATLAB installation.\n');
    fprintf(fid, 'Run checks manually or install Simulink Check.\n');
    return;
end

% Default check groups when none supplied.
if isempty(checkGroups)
    checkGroups = {
        'mathworks.maab'        % MAAB / MAB modeling guidelines
        'mathworks.jc'          % Model configuration checks
        'mathworks.hism'        % Modeling standards (safety-oriented)
    };
end

fprintf(fid, '## Check groups attempted\n\n');
for k = 1:numel(checkGroups)
    fprintf(fid, '- `%s`\n', checkGroups{k});
end
fprintf(fid, '\n');

% Run each group and log results.
for k = 1:numel(checkGroups)
    groupId = checkGroups{k};
    fprintf(fid, '## Group: `%s`\n\n', groupId);
    try
        result = ModelAdvisor.run(modelName, 'Configuration', groupId, ...
            'Force', true, 'DisplayResults', 'None');
        if isstruct(result) || isobject(result)
            fprintf(fid, 'Run completed. Inspect the HTML report in `slprj/modeladvisor/`.\n\n');
        else
            fprintf(fid, 'Run returned: `%s`\n\n', class(result));
        end
    catch ME
        fprintf(fid, 'Group `%s` failed: `%s`\n\n', groupId, esc(ME.message));
    end
end

fprintf(fid, '## Next step\n\n');
fprintf(fid, 'Open the full HTML report:\n\n');
fprintf(fid, '```matlab\nModelAdvisor.run(''%s'', ''Force'', true);\n```\n', char(modelName));
end

function out = esc(in)
out = char(string(in));
out = strrep(out, '|', '\|');
out = strrep(out, newline, ' ');
end
