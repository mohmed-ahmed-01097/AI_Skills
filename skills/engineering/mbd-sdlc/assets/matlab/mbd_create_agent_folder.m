function root = mbd_create_agent_folder(projectRoot)
%MBD_CREATE_AGENT_FOLDER Create the standard .MBD_agent workspace.
% Description:
%   Creates the AI working folder used for model architecture exports,
%   workspace reports, scripts, logs, and task evidence.
%
% Inputs:
%   projectRoot - Optional project root. Defaults to current folder.
%
% Outputs:
%   root        - Path to the .MBD_agent folder.

if nargin < 1 || isempty(projectRoot)
    projectRoot = pwd;
end

root = fullfile(projectRoot, '.MBD_agent');
folders = {'scripts', 'architecture', 'workspace', 'reports', 'logs', 'scratch', 'tasks'};
if ~exist(root, 'dir')
    mkdir(root);
end
for i = 1:numel(folders)
    p = fullfile(root, folders{i});
    if ~exist(p, 'dir')
        mkdir(p);
    end
end

constitutionPath = fullfile(root, 'constitution.md');
if ~exist(constitutionPath, 'file')
    writeTextFile(constitutionPath, sprintf(['# Project constitution\n\n' ...
        '- Created: %s\n' ...
        '- Purpose: TODO\n' ...
        '- MATLAB release: TODO\n' ...
        '- Main models: TODO\n' ...
        '- Code generation target: TODO\n' ...
        '- Test strategy: TODO\n' ...
        '- Constraints: TODO\n'], datestr(now, 31)));
end

rulesPath = fullfile(root, 'rules.md');
if ~exist(rulesPath, 'file')
    writeTextFile(rulesPath, ['# Project MBD rules' newline newline ...
        '- Use MathWorks documentation for the detected MATLAB release.' newline ...
        '- Use scripted model edits, not manual diagram edits.' newline ...
        '- Inspect block parameters before setting them.' newline ...
        '- Keep generated AI artifacts under .MBD_agent unless approved.' newline]);
end
end

function writeTextFile(pathName, textValue)
fid = fopen(pathName, 'w');
if fid < 0
    error('mbd_create_agent_folder:FileOpenFailed', 'Could not open %s for writing.', pathName);
end
cleanupObj = onCleanup(@() fclose(fid));
fprintf(fid, '%s', textValue);
end
