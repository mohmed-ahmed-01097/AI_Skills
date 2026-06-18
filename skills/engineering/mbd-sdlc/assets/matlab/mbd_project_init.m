function prjPath = mbd_project_init(projectRoot, projectName, openExisting)
%MBD_PROJECT_INIT Create or open a MATLAB project (.prj).
% Description:
%   Creates a new MATLAB project in projectRoot, or opens an existing one
%   if found. Sets up standard path labels, adds key folders to the project,
%   and writes a startup shortcut. The project file uses the .prj extension.
%
% Inputs:
%   projectRoot  - Root folder for the project. Defaults to pwd.
%   projectName  - Project name string. Defaults to folder name.
%   openExisting - If true, opens an existing .prj instead of creating.
%                  Defaults to true when a .prj file is found.
%
% Outputs:
%   prjPath      - Full path to the .prj file.

if nargin < 1 || isempty(projectRoot), projectRoot = pwd; end
[~, folderName] = fileparts(projectRoot);
if nargin < 2 || isempty(projectName), projectName = folderName; end
if nargin < 3, openExisting = []; end

prjPath = fullfile(projectRoot, [projectName '.prj']);
existingFiles = dir(fullfile(projectRoot, '*.prj'));

% Decide whether to open or create.
if isempty(openExisting)
    openExisting = ~isempty(existingFiles);
end

if openExisting && ~isempty(existingFiles)
    prjPath = fullfile(existingFiles(1).folder, existingFiles(1).name);
    fprintf('Opening existing project: %s\n', prjPath);
    matlab.project.loadProject(prjPath);
    return;
end

% Create a new project.
fprintf('Creating MATLAB project: %s\n', prjPath);
prj = matlab.project.createProject('Name', projectName, 'Folder', projectRoot);
prjPath = prj.RootFolder; % update to actual path

% Add standard MBD folders if they exist.
standardFolders = {
    '01_requirements'
    '02_system_design_hld'
    '03_software_design_lld'
    '04_implementation'
    '05_mil_tests'
    '06_sil_tests'
    '07_pil_tests'
    '08_hil_tests'
    '09_codegen'
    '10_release'
    'tools'
};
for i = 1:numel(standardFolders)
    fp = fullfile(projectRoot, standardFolders{i});
    if exist(fp, 'dir')
        try
            addFolderIncludingChildFiles(prj, standardFolders{i});
        catch
        end
    end
end

% Add a project shortcut for the main startup script if it exists.
startupScript = fullfile(projectRoot, 'tools', 'mbd', 'project_startup.m');
if exist(startupScript, 'file')
    try
        addShortcut(prj, 'Label', 'Project Startup', 'File', startupScript);
    catch
    end
end

save(prj);
fprintf('Project created at: %s\n', prj.RootFolder);
prjPath = fullfile(prj.RootFolder, [projectName '.prj']);
end