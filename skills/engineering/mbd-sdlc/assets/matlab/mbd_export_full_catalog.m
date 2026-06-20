function reportPath = mbd_export_full_catalog(outputDir, searchDepth, includeParamValues, libraryRoots, forceRegenerate)
%MBD_EXPORT_FULL_CATALOG Export one combined environment + block catalog file.
% Description:
%   Generates a single Markdown file containing: MATLAB release and
%   installed products, active licenses, installed add-ons, installed
%   Simulink apps, and a Simulink block library catalog (block paths,
%   types, mask types, and dialog parameters). This is a thin wrapper
%   around mbd_discover_environment and mbd_export_block_library_catalog
%   that merges their output into one file, as requested for a single
%   reference the AI can read instead of guessing block names or
%   parameters from memory.
%
%   Everything in the merged file is read from the user's actual installed
%   MATLAB/Simulink at generation time. Nothing here is a hand-written or
%   memorized list, so it stays correct across releases and toolboxes.
%
% Inputs:
%   outputDir          - Optional output directory. Defaults to .MBD_agent/reports.
%   searchDepth        - Optional find_system search depth for the block
%                        catalog. Defaults to 4.
%   includeParamValues - Optional logical. Defaults to false. true adds
%                        default parameter values, not just names; slower
%                        and produces a larger file.
%   libraryRoots       - Optional cell array of library roots to catalog.
%                        Defaults to {'simulink'}.
%   forceRegenerate    - Optional logical. Defaults to false. If the merged
%                        file already exists and this is false, generation
%                        is skipped and the existing path is returned, since
%                        the catalog only changes when products/toolboxes
%                        change, not per task.
%
% Outputs:
%   reportPath         - Path to the merged Markdown catalog.

if nargin < 1 || isempty(outputDir)
    outputDir = fullfile(pwd, '.MBD_agent', 'reports');
end
if nargin < 2 || isempty(searchDepth)
    searchDepth = 4;
end
if nargin < 3 || isempty(includeParamValues)
    includeParamValues = false;
end
if nargin < 4 || isempty(libraryRoots)
    libraryRoots = {'simulink'};
end
if nargin < 5 || isempty(forceRegenerate)
    forceRegenerate = false;
end
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

reportPath = fullfile(outputDir, 'matlab_simulink_full_catalog.md');

if exist(reportPath, 'file') && ~forceRegenerate
    fprintf(['Existing catalog found: %s\n' ...
        'Skipping regeneration. Pass forceRegenerate=true to rebuild ' ...
        '(for example, after installing/removing a toolbox or upgrading MATLAB).\n'], ...
        reportPath);
    return;
end

envPath = mbd_discover_environment(outputDir);
catalogPath = mbd_export_block_library_catalog(outputDir, searchDepth, includeParamValues, libraryRoots);

fid = fopen(reportPath, 'w');
if fid < 0
    error('mbd_export_full_catalog:FileOpenFailed', 'Could not write %s.', reportPath);
end
cleanupObj = onCleanup(@() fclose(fid));

fprintf(fid, '# MATLAB and Simulink full catalog\n\n');
fprintf(fid, '- Generated: %s\n', datestr(now, 31));
fprintf(fid, ['- Regenerate after installing/removing toolboxes or upgrading MATLAB. ' ...
    'Call mbd_export_full_catalog(..., true) to force a rebuild.\n\n']);
fprintf(fid, '## Contents\n\n');
fprintf(fid, '1. MATLAB environment (release, products, licenses, add-ons, Simulink apps)\n');
fprintf(fid, '2. Simulink block library catalog (block paths, types, parameters)\n\n');
fprintf(fid, '---\n\n');

appendFileContents(fid, envPath);
fprintf(fid, '\n---\n\n');
appendFileContents(fid, catalogPath);

fprintf('Combined catalog written: %s\n', reportPath);
end

function appendFileContents(destFid, sourcePath)
sourceFid = fopen(sourcePath, 'r');
if sourceFid < 0
    fprintf(destFid, '_Could not read %s._\n', sourcePath);
    return;
end
content = fread(sourceFid, '*char')';
fclose(sourceFid);
fwrite(destFid, content);
end
