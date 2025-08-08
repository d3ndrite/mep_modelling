%% Main optimization code
% Authors: JK and VV
% Uses patternsearch to optimize based on MEP amplitude

clear functions
close all


% Initialize subject data matrix
load AO700_data.mat % data matrix arranged as datapoints x subject_number
subject_data = subject_data_AO700;
subject_ids = [1:2, 11:17, 19:27];
nSubjects = numel(subject_ids);

% Initial values and bounds
x0 = [1.9200 1.9200 0.7200 0.7200]; % Default values as appears in Wilson et al 2021
lb = [0.0001 0.0001 0.0001 0.0001];
ub = [5.0000 5.0000 5.0000 5.0000];
options = optimoptions('patternsearch', ...
    'Display', 'iter', ...
    'MeshTolerance', 1e-4);

for i = 1:nSubjects
    % Extract relevant data and subject ID
    mean_data = subject_data(:, i);
    subj_id = subject_ids(i);
    % x0 = best_fit(i,:);

    % Objective function
    objective = @(x) nftsim_model_fit(x, mean_data);
    x0_guess = round(x0, 4);

    % Run patternsearch with bounds
    [x_optimized, fval, exitflag, output] = ...
        patternsearch(objective, x0_guess, [], [], [], [], lb, ub, [], options);
    
    % Prepare filenames
    xfile = sprintf('x_values_subject_%03d.mat', subj_id);
    figfile = sprintf('optimized_%03d.fig', subj_id);
    workspace_file = sprintf('workspace_%03d.mat', subj_id);

    save(workspace_file)
    % Save optimized parameters
    save(xfile, 'x_optimized', 'fval', 'exitflag', 'output');
    % Optional: create and save a figure
    figure('Name', sprintf('Best fit %03d', subj_id));
    savefig(figfile);
    close;
    save 

end
