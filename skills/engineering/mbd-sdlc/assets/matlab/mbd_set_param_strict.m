function mbd_set_param_strict(blockPath, parameterName, parameterValue)
%MBD_SET_PARAM_STRICT Set a Simulink parameter after validating the name.
% Description:
%   Validates that the target block exposes the requested dialog parameter
%   before calling set_param. Prevents silent failures caused by wrong
%   parameter names, wrong block library paths, or release differences.
%
% Inputs:
%   blockPath      - Simulink block path.
%   parameterName  - Dialog parameter name to set.
%   parameterValue - Parameter value passed to set_param.
%
% Outputs:
%   None.

blockPath     = char(blockPath);
parameterName = char(parameterName);

try
    params = get_param(blockPath, 'DialogParameters');
catch ME
    error('mbd_set_param_strict:CannotQueryParams', ...
        'Could not query dialog parameters for block "%s": %s', ...
        blockPath, ME.message);
end

% Some blocks return an empty struct with no fields.
if ~isstruct(params) || isempty(fieldnames(params))
    warning('mbd_set_param_strict:NoDialogParams', ...
        'Block "%s" reports no dialog parameters. Attempting set_param anyway.', ...
        blockPath);
    set_param(blockPath, parameterName, parameterValue);
    return;
end

if ~isfield(params, parameterName)
    names = fieldnames(params);
    msg = sprintf( ...
        'Parameter "%s" is not available on block "%s".\nAvailable parameters:\n%s', ...
        parameterName, blockPath, strjoin(names, newline));
    error('mbd_set_param_strict:UnknownParameter', '%s', msg);
end

set_param(blockPath, parameterName, parameterValue);
end
