function mbd_apply_model_view(systemPath)
%MBD_APPLY_MODEL_VIEW Apply fit-to-view to a model or subsystem.
% Description:
%   Opens the target system and fits the canvas to show all content,
%   equivalent to pressing Ctrl+0 in Simulink. Tries the modern API first,
%   falls back to set_param for older releases.
%
% Inputs:
%   systemPath - Model or subsystem path.
%
% Outputs:
%   None.

systemPath = char(systemPath);
open_system(systemPath);

% Preferred API (R2015b+).
try
    Simulink.BlockDiagram.arrangeSystem(systemPath);
catch
end

% Fit-to-view via ZoomFactor (broad release support).
try
    set_param(systemPath, 'ZoomFactor', 'FitSystem');
    return;
catch
end

% Final fallback: use the model handle API if available.
try
    h = get_param(systemPath, 'Handle');
    set_param(h, 'ZoomFactor', 'FitSystem');
catch ME
    warning('mbd_apply_model_view:FitViewFailed', ...
        'Could not apply fit-to-view for %s: %s', systemPath, ME.message);
end
end
