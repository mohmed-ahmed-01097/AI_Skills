function testFilePath = mbd_test_manager_template(modelName, testFilePath, stopTime)
%MBD_TEST_MANAGER_TEMPLATE Create a basic Simulink Test Manager file.
% Description:
%   Creates a Simulink Test file with one suite, one simulation test case,
%   and optional stop time configuration for the supplied model.
%   Requires Simulink Test. Existence is checked via try-catch to work
%   correctly across MATLAB releases.
%
% Inputs:
%   modelName     - Model under test.
%   testFilePath  - Optional output .mldatx path.
%   stopTime      - Optional simulation stop time as a string. Default '10'.
%
% Outputs:
%   testFilePath  - Path to the created test file.

if nargin < 2 || isempty(testFilePath)
    outDir = fullfile(pwd, '.MBD_agent', 'reports');
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    testFilePath = fullfile(outDir, [char(modelName) '_tests.mldatx']);
end
if nargin < 3 || isempty(stopTime)
    stopTime = '10';
end

% Check Simulink Test availability via try-catch (more reliable than exist()
% on a package class across releases).
try
    dummy = sltest.testmanager.TestFile; %#ok<NASGU>
    clear dummy;
catch ME
    if contains(ME.identifier, 'undefined') || contains(ME.identifier, 'Unrecognized')
        error('mbd_test_manager_template:MissingSimulinkTest', ...
            'Simulink Test is not available in this installation.');
    end
    % Other errors may come from trying to create a file without a path; OK.
end

load_system(modelName);
sltest.testmanager.clear;

% Create test file with one suite and one simulation test case.
tf = sltest.testmanager.TestFile(testFilePath);
ts = addTestSuite(tf, 'Generated Suite');
tc = addTestCase(ts, 'simulation', 'Generated Simulation Test');
setProperty(tc, 'Model', char(modelName));
setProperty(tc, 'StopTime', stopTime);

% Add a baseline capture placeholder section.
try
    addBaseline(tc);
catch
    % Baseline API may differ; skip silently.
end

saveToFile(tf);
fprintf('Test file written: %s\n', testFilePath);
end
