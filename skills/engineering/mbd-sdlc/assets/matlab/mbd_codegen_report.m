function reportPath = mbd_codegen_report(modelName, outputDir)
%MBD_CODEGEN_REPORT Export code generation configuration evidence.
% Description:
%   Writes a Markdown summary of the active configuration set including
%   solver, production hardware, code interface, and build parameters.
%   Does NOT run slbuild.
%
% Inputs:
%   modelName - Model name.
%   outputDir - Optional output directory. Defaults to .MBD_agent/reports.
%
% Outputs:
%   reportPath - Path to generated Markdown report.

if nargin < 2 || isempty(outputDir)
    outputDir = fullfile(pwd, '.MBD_agent', 'reports');
end
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
reportPath = fullfile(outputDir, [char(modelName) '_codegen_config.md']);
fid = fopen(reportPath, 'w');
if fid < 0
    error('mbd_codegen_report:FileOpenFailed', 'Could not write %s.', reportPath);
end
cleanupObj = onCleanup(@() fclose(fid));

fprintf(fid, '# Code generation configuration: `%s`\n\n', char(modelName));
fprintf(fid, '- Generated: %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

try
    load_system(modelName);
    cs = getActiveConfigSet(modelName);
catch ME
    fprintf(fid, 'Could not load configuration set: `%s`\n', esc(ME.message));
    return;
end

% Solver and simulation.
solverParams = {'SolverType', 'Solver', 'FixedStep', 'StartTime', 'StopTime', ...
    'SolverMode', 'MaxStep', 'MinStep', 'RelTol', 'AbsTol'};
writeParamSection(fid, cs, 'Solver', solverParams);

% Code generation target.
codegenParams = {'SystemTargetFile', 'TargetLang', 'CodeInterfacePackaging', ...
    'GenerateReport', 'InlineParams', 'OptimizeBlockIOStorage', ...
    'BlockReduction', 'ConditionallyExecuteInputs', 'MatFileLogging', ...
    'SignalLogging', 'ReusableCode', 'GenerateMakefile'};
writeParamSection(fid, cs, 'Code generation', codegenParams);

% Hardware implementation - critical for production C targets.
hwParams = {'ProdHWDeviceType', 'ProdBitPerChar', 'ProdBitPerShort', ...
    'ProdBitPerInt', 'ProdBitPerLong', 'ProdBitPerLongLong', ...
    'ProdBitPerFloat', 'ProdBitPerDouble', 'ProdBitPerPointer', ...
    'ProdEndianess', 'ProdIntDivRoundTo', 'ProdShiftRightIntArith', ...
    'TargetHWDeviceType'};
writeParamSection(fid, cs, 'Hardware implementation', hwParams);

% Diagnostics (selected ones relevant to code generation).
diagParams = {'DataTypeOverride', 'UnderSpecifiedDataTypes', ...
    'StrictBusMsg', 'UnconnectedInputMsg', 'UnconnectedOutputMsg'};
writeParamSection(fid, cs, 'Selected diagnostics', diagParams);

fprintf(fid, '## Build command\n\n');
fprintf(fid, 'After user approval, run:\n\n```matlab\nslbuild(''%s'');\n```\n', ...
    char(modelName));
end

function writeParamSection(fid, cs, sectionTitle, params)
fprintf(fid, '## %s\n\n', sectionTitle);
fprintf(fid, '| Parameter | Value |\n|---|---|\n');
for i = 1:numel(params)
    nm = params{i};
    try
        val = get_param(cs, nm);
        fprintf(fid, '| `%s` | `%s` |\n', nm, esc(val));
    catch
        fprintf(fid, '| `%s` | _not available_ |\n', nm);
    end
end
fprintf(fid, '\n');
end

function out = esc(in)
out = char(string(in));
out = strrep(out, '|', '\|');
out = strrep(out, newline, ' ');
end
