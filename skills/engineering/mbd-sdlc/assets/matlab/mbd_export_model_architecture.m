function reportPath = mbd_export_model_architecture(modelOrSubsystem, outputDir)
%MBD_EXPORT_MODEL_ARCHITECTURE Export Simulink architecture to Markdown.
% Description:
%   Exports blocks, dialog parameters, lines, annotations, and signal
%   attributes for a model or subsystem. Output is used for AI analysis
%   and before/after comparison.
%
% Inputs:
%   modelOrSubsystem - Model or subsystem path.
%   outputDir        - Optional output directory. Defaults to .MBD_agent/architecture.
%
% Outputs:
%   reportPath       - Path to the generated Markdown report.

if nargin < 2 || isempty(outputDir)
    outputDir = fullfile(pwd, '.MBD_agent', 'architecture');
end
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
modelOrSubsystem = char(modelOrSubsystem);

% Determine the root model name robustly.
parts = strsplit(modelOrSubsystem, '/');
modelName = parts{1};

if ~bdIsLoaded(modelName)
    load_system(modelName);
end

safeName = regexprep(modelOrSubsystem, '[^A-Za-z0-9_]+', '_');
reportPath = fullfile(outputDir, [safeName '_architecture.md']);
fid = fopen(reportPath, 'w');
if fid < 0
    error('mbd_export_model_architecture:FileOpenFailed', 'Could not write %s.', reportPath);
end
cleanupObj = onCleanup(@() fclose(fid));

fprintf(fid, '# Architecture export: `%s`\n\n', esc(modelOrSubsystem));
fprintf(fid, '- Generated: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
fprintf(fid, '- Root model: `%s`\n\n', esc(modelName));

% --- Blocks ---
blocks = find_system(modelOrSubsystem, 'LookUnderMasks', 'all', ...
    'FollowLinks', 'on', 'Type', 'Block');
fprintf(fid, '## Blocks\n\n');
fprintf(fid, '| # | Path | BlockType | MaskType | Parent | Position |\n');
fprintf(fid, '|---:|---|---|---|---|---|\n');
for i = 1:numel(blocks)
    b = blocks{i};
    fprintf(fid, '| %d | `%s` | %s | %s | `%s` | %s |\n', i, ...
        esc(b), esc(getp(b,'BlockType')), esc(getp(b,'MaskType')), ...
        esc(getp(b,'Parent')), esc(posText(b)));
end

% --- Block dialog parameters ---
fprintf(fid, '\n## Block dialog parameters\n\n');
for i = 1:numel(blocks)
    b = blocks{i};
    fprintf(fid, '### `%s`\n\n', esc(b));
    fprintf(fid, '- BlockType: `%s`\n', esc(getp(b, 'BlockType')));
    fprintf(fid, '- MaskType:  `%s`\n', esc(getp(b, 'MaskType')));
    try
        params = get_param(b, 'DialogParameters');
        names  = fieldnames(params);
        if isempty(names)
            fprintf(fid, '- Dialog parameters: none reported\n\n');
        else
            fprintf(fid, '| Parameter | Value |\n|---|---|\n');
            for j = 1:numel(names)
                nm  = names{j};
                val = getp(b, nm);
                fprintf(fid, '| `%s` | `%s` |\n', esc(nm), esc(val));
            end
            fprintf(fid, '\n');
        end
    catch ME
        fprintf(fid, '- Could not read dialog parameters: `%s`\n\n', esc(ME.message));
    end

    % Signal attributes on output ports.
    try
        ph = get_param(b, 'PortHandles');
        if isstruct(ph) && isfield(ph, 'Outport') && ~isempty(ph.Outport)
            fprintf(fid, '| Output port | DataType | SampleTime | Dimensions |\n');
            fprintf(fid, '|---:|---|---|---|\n');
            for p = 1:numel(ph.Outport)
                pHandle = ph.Outport(p);
                dt  = portParam(pHandle, 'DataType');
                st  = portParam(pHandle, 'SampleTime');
                dim = portParam(pHandle, 'Dimensions');
                fprintf(fid, '| %d | %s | %s | %s |\n', p, esc(dt), esc(st), esc(dim));
            end
            fprintf(fid, '\n');
        end
    catch
    end
end

% --- Lines ---
fprintf(fid, '\n## Lines\n\n');
fprintf(fid, '| # | Source | Destination(s) | Signal name |\n');
fprintf(fid, '|---:|---|---|---|\n');
try
    lines = find_system(modelOrSubsystem, 'FindAll', 'on', 'Type', 'line');
    for i = 1:numel(lines)
        lh  = lines(i);
        src = lineEndText(lh, 'SrcBlockHandle', 'SrcPortHandle');
        dst = lineDestText(lh);
        nm  = getLineParam(lh, 'Name');
        fprintf(fid, '| %d | `%s` | `%s` | `%s` |\n', i, esc(src), esc(dst), esc(nm));
    end
catch ME
    fprintf(fid, '| - | Error | `%s` | - |\n', esc(ME.message));
end

% --- Annotations (text labels, titles, subtitles) ---
fprintf(fid, '\n## Annotations\n\n');
try
    annots = find_system(modelOrSubsystem, 'FindAll', 'on', 'Type', 'annotation');
    if isempty(annots)
        fprintf(fid, '_No annotations found._\n');
    else
        fprintf(fid, '| # | Text | Position |\n|---:|---|---|\n');
        for i = 1:numel(annots)
            ah  = annots(i);
            txt = '';
            pos = '';
            try, txt = get_param(ah, 'Text'); catch, end
            try, pos = mat2str(get_param(ah, 'Position')); catch, end
            fprintf(fid, '| %d | `%s` | %s |\n', i, esc(txt), esc(pos));
        end
    end
catch ME
    fprintf(fid, 'Could not export annotations: `%s`\n', esc(ME.message));
end
end

% --- Helpers ---
function value = getp(pathName, paramName)
try
    raw   = get_param(pathName, paramName);
    value = val2txt(raw);
catch
    value = '';
end
end

function txt = portParam(portHandle, paramName)
try
    raw = get_param(portHandle, paramName);
    txt = val2txt(raw);
catch
    txt = '';
end
end

function txt = posText(blockPath)
try
    txt = mat2str(get_param(blockPath, 'Position'));
catch
    txt = '';
end
end

function out = val2txt(value)
if isnumeric(value) || islogical(value)
    out = mat2str(value);
elseif ischar(value)
    out = value;
elseif isstring(value)
    out = char(value);
elseif iscell(value)
    out = ['cell(' num2str(numel(value)) ')'];
elseif isstruct(value)
    out = ['struct(' strjoin(fieldnames(value)', ',') ')'];
else
    try, out = char(string(value)); catch, out = ['<' class(value) '>']; end
end
out = strrep(out, newline, ' ');
end

function out = esc(in)
out = val2txt(in);
out = strrep(out, '|', '\|');
end

function txt = getLineParam(lineHandle, paramName)
try, txt = get_param(lineHandle, paramName); catch, txt = ''; end
end

function txt = lineEndText(lineHandle, blockParam, portParam)
try
    bh = get_param(lineHandle, blockParam);
    ph = get_param(lineHandle, portParam);
    if bh > 0
        txt = getfullname(bh);
        if ph > 0
            txt = [txt ':' num2str(get_param(ph, 'PortNumber'))];
        end
    else
        txt = '';
    end
catch
    txt = '';
end
end

function txt = lineDestText(lineHandle)
try
    dstBlocks = get_param(lineHandle, 'DstBlockHandle');
    dstPorts  = get_param(lineHandle, 'DstPortHandle');
    parts     = cell(1, numel(dstBlocks));
    for k = 1:numel(dstBlocks)
        if dstBlocks(k) > 0
            part = getfullname(dstBlocks(k));
            if numel(dstPorts) >= k && dstPorts(k) > 0
                part = [part ':' num2str(get_param(dstPorts(k), 'PortNumber'))];
            end
            parts{k} = part;
        else
            parts{k} = '';
        end
    end
    txt = strjoin(parts, ', ');
catch
    txt = '';
end
end
