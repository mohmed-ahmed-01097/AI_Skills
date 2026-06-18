function reportPath = mbd_discover_environment(outputDir)
%MBD_DISCOVER_ENVIRONMENT Export MATLAB and Simulink environment evidence.
% Description:
%   Writes a Markdown report with MATLAB version, installed products,
%   active licenses, installed add-ons, available Simulink apps, and a
%   top-level Simulink library sample when Simulink is installed.
%
% Inputs:
%   outputDir  - Optional output directory. Defaults to .MBD_agent/reports.
%
% Outputs:
%   reportPath - Path to the generated Markdown report.

if nargin < 1 || isempty(outputDir)
    outputDir = fullfile(pwd, '.MBD_agent', 'reports');
end
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
reportPath = fullfile(outputDir, 'matlab_environment.md');
fid = fopen(reportPath, 'w');
if fid < 0
    error('mbd_discover_environment:FileOpenFailed', 'Could not write %s.', reportPath);
end
cleanupObj = onCleanup(@() fclose(fid));

fprintf(fid, '# MATLAB environment\n\n');
fprintf(fid, '- Generated: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
fprintf(fid, '- MATLAB version: %s\n', version);
fprintf(fid, '- Computer: %s\n\n', computer);

% Installed products.
fprintf(fid, '## Installed products\n\n');
products = ver;
fprintf(fid, '| Name | Version | Release | Date |\n');
fprintf(fid, '|---|---|---|---|\n');
for i = 1:numel(products)
    fprintf(fid, '| %s | %s | %s | %s |\n', ...
        esc(products(i).Name), esc(products(i).Version), ...
        esc(products(i).Release), esc(products(i).Date));
end

% Active licenses.
fprintf(fid, '\n## Active licenses\n\n');
try
    lic = license('inuse');
    if isempty(lic)
        fprintf(fid, 'No active licenses reported.\n');
    else
        for i = 1:numel(lic)
            fprintf(fid, '- %s\n', esc(lic(i).feature));
        end
    end
catch ME
    fprintf(fid, 'Could not query active licenses: `%s`\n', esc(ME.message));
end

% Installed add-ons – write rows to file instead of just calling disp().
fprintf(fid, '\n## Installed add-ons\n\n');
try
    if exist('matlab.addons.installedAddons', 'file') || ...
            exist('matlab.addons.installedAddons', 'builtin')
        addons = matlab.addons.installedAddons;
        if isempty(addons) || height(addons) == 0
            fprintf(fid, 'No installed add-ons reported.\n');
        else
            fprintf(fid, '| Name | Version | Enabled |\n');
            fprintf(fid, '|---|---|---|\n');
            for i = 1:height(addons)
                row = addons(i, :);
                name    = esc(char(row.Name));
                ver_str = '';
                en_str  = '';
                try, ver_str = esc(char(row.Version)); catch, end
                try, en_str  = esc(char(string(row.Enabled))); catch, end
                fprintf(fid, '| %s | %s | %s |\n', name, ver_str, en_str);
            end
        end
    else
        fprintf(fid, 'Add-ons API not available in this release.\n');
    end
catch ME
    fprintf(fid, 'Could not query add-ons: `%s`\n', esc(ME.message));
end

% Simulink availability and top-level libraries.
fprintf(fid, '\n## Simulink availability\n\n');
try
    load_system('simulink');
    topLibs = find_system('simulink', 'SearchDepth', 1, 'Type', 'Block_Diagram');
    fprintf(fid, 'Simulink library loaded. Top-level libraries:\n\n');
    for i = 1:numel(topLibs)
        fprintf(fid, '- `%s`\n', esc(topLibs{i}));
    end
catch ME
    fprintf(fid, 'Could not load Simulink library: `%s`\n', esc(ME.message));
end

% List installed Simulink apps.
fprintf(fid, '\n## Simulink apps\n\n');
try
    % Each app is usually a function; test for the most common ones.
    apps = {
        'Simulink Test',         'sltest.testmanager.TestFile'
        'Embedded Coder',        'coder.EmbeddedCodeConfig'
        'Simulink Coder',        'RTW.BuildConfig'
        'Simulink Check',        'ModelAdvisor'
        'Requirements Toolbox',  'slreq.ReqSet'
        'Stateflow',             'Stateflow.Chart'
        'Fixed-Point Designer',  'fi'
        'Simulink Coverage',     'cvtest'
        'Polyspace',             'polyspace.Project'
        'System Composer',       'systemcomposer.arch.Architecture'
        'Simulink Design Verifier', 'sldv.Options'
    };
    fprintf(fid, '| App | Available |\n|---|---|\n');
    for i = 1:size(apps, 1)
        probe = apps{i, 2};
        avail = exist(probe, 'class') > 0 || exist(probe, 'file') > 0 || ...
                exist(probe, 'builtin') > 0;
        fprintf(fid, '| %s | %s |\n', apps{i, 1}, tf2str(avail));
    end
catch ME
    fprintf(fid, 'Could not probe apps: `%s`\n', esc(ME.message));
end
end

function s = tf2str(v)
if v, s = 'yes'; else, s = 'no'; end
end

function out = esc(in)
out = char(string(in));
out = strrep(out, '|', '\|');
out = strrep(out, newline, ' ');
end
