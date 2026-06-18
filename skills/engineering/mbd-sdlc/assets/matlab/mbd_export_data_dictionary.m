function reportPath = mbd_export_data_dictionary(dictionaryPath, outputDir)
%MBD_EXPORT_DATA_DICTIONARY Export a Simulink data dictionary summary.
% Description:
%   Writes a Markdown report listing all sections and their entries in a
%   Simulink data dictionary. Sections are discovered dynamically, not
%   hard-coded. Values are summarized to keep reports readable.
%
% Inputs:
%   dictionaryPath - Path or name of the .sldd file.
%   outputDir      - Optional output directory. Defaults to .MBD_agent/workspace.
%
% Outputs:
%   reportPath     - Path to the generated Markdown report.

if nargin < 2 || isempty(outputDir)
    outputDir = fullfile(pwd, '.MBD_agent', 'workspace');
end
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
safeName = regexprep(char(dictionaryPath), '[^A-Za-z0-9_]+', '_');
reportPath = fullfile(outputDir, [safeName '_dictionary.md']);
fid = fopen(reportPath, 'w');
if fid < 0
    error('mbd_export_data_dictionary:FileOpenFailed', 'Could not write %s.', reportPath);
end
cleanupObj = onCleanup(@() fclose(fid));

fprintf(fid, '# Data dictionary: `%s`\n\n', esc(dictionaryPath));
fprintf(fid, '- Generated: %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

try
    dictObj = Simulink.data.dictionary.open(dictionaryPath);
catch ME
    fprintf(fid, 'Could not open dictionary: `%s`\n', esc(ME.message));
    return;
end

% Discover sections dynamically instead of assuming fixed names.
try
    sectionNames = getSectionNames(dictObj);
catch ME
    fprintf(fid, 'Could not discover sections: `%s`\n', esc(ME.message));
    sectionNames = {'Design Data', 'Configurations', 'Other Data'}; % safe fallback
end

if isempty(sectionNames)
    fprintf(fid, 'No sections found in this dictionary.\n');
    return;
end

for i = 1:numel(sectionNames)
    sectionName = sectionNames{i};
    fprintf(fid, '## %s\n\n', sectionName);
    try
        sectionObj = getSection(dictObj, sectionName);
        entries = find(sectionObj);
        if isempty(entries)
            fprintf(fid, '_No entries._\n\n');
            continue;
        end
        fprintf(fid, '| Name | Status | Value class | Value summary |\n');
        fprintf(fid, '|---|---|---|---|\n');
        for j = 1:numel(entries)
            entryObj = entries(j);
            name   = entryObj.Name;
            status = entryObj.Status;
            try
                val        = getValue(entryObj);
                valClass   = class(val);
                valSummary = summarizeValue(val);
            catch ME2
                valClass   = '';
                valSummary = ['Could not read value: ' ME2.message];
            end
            fprintf(fid, '| `%s` | %s | %s | `%s` |\n', ...
                esc(name), esc(status), esc(valClass), esc(valSummary));
        end
        fprintf(fid, '\n');
    catch ME
        fprintf(fid, 'Could not inspect section `%s`: `%s`\n\n', ...
            sectionName, esc(ME.message));
    end
end
end

% Discover all section names from the dictionary object.
function names = getSectionNames(dictObj)
names = {};
% Try the documented API first.
try
    sections = dictObj.DataSections;
    for i = 1:numel(sections)
        names{end+1} = sections(i).Name; %#ok<AGROW>
    end
    return;
catch
end
% Fallback: probe known section names.
candidates = {'Design Data', 'Configurations', 'Other Data', 'AUTOSAR', ...
              'Interface Data', 'Requirements'};
for i = 1:numel(candidates)
    try
        getSection(dictObj, candidates{i});
        names{end+1} = candidates{i}; %#ok<AGROW>
    catch
    end
end
end

function txt = summarizeValue(value)
if isnumeric(value) || islogical(value)
    txt = mat2str(value);
elseif ischar(value)
    txt = value;
elseif isstring(value)
    txt = char(value);
elseif isstruct(value)
    txt = ['struct(' strjoin(fieldnames(value)', ',') ')'];
else
    txt = ['<' class(value) '>'];
end
if numel(txt) > 120
    txt = [txt(1:117) '...'];
end
txt = strrep(txt, newline, ' ');
end

function out = esc(in)
out = char(string(in));
out = strrep(out, '|', '\|');
out = strrep(out, newline, ' ');
end
