function [tt, phi] = cortical_output()

    filename = 'op.output';

    % Read lines to locate data start (R2022a+)
    lines = readlines(filename);
    idx = find(contains(lines, '====='), 1, 'first');

    if isempty(idx)
        error('Data start marker (====) not found in op.output');
    end

    % Data starts 2 lines after separator line
    dataStartRow = idx + 2;

    % Force MATLAB to treat it as text
    data = readmatrix(filename, 'FileType', 'text', 'NumHeaderLines', dataStartRow - 1);
    data = data(2:end, :);   % <-- Skip first data row

    % Extract time and phi
    tt = data(:, 1);         % First column: Time
    phi = data(:, 2);        % Second column: Propagator.22.phi, the layer 5 
end
