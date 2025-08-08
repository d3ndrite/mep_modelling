function [sim_mep_mag, epoched_sim_mep] = nftsim_sim_gen(x_values)
    % Persistent variable to track the number of iterations
    persistent iteration_count;
    if isempty(iteration_count)
        iteration_count = 0; % Initialize at first function call
    end
    iteration_count = iteration_count + 1; % Increment count
        
    currentfolder = pwd;
    filename = 'run.conf';
    disp(x_values);

    % Update configuration file with new x values
    change_conf(currentfolder, filename, x_values);

	% Define the name of the executable
	exeName = 'nftsim';

	% Search recursively in the current directory
	nftsimFile = dir(fullfile(pwd, '**', exeName));

	% Check if the file was found
	if isempty(nftsimFile)
	    error('NFTsim executable "%s" not found in the current folder or subfolders.', exeName);
	end

	% If multiple results, take the first one found
	nftsimPath = fullfile(nftsimFile(1).folder, nftsimFile(1).name);

	% Define input and output configuration files
	inputFile = 'run.conf';
	outputFile = 'op.output';

	% Construct command string
	cmd = sprintf('"%s" -i "%s" -o "%s"', nftsimPath, inputFile, outputFile);

	% Run the command
	[status, cmdout] = system(cmd);

	% Check status
	if status ~= 0
	    error('NFTsim execution failed with status %d.\nOutput:\n%s', status, cmdout);
	end

	disp('NFTsim executed successfully.');
	% disp(cmdout);
    
    % Pause to allow simulation completion
    pause(0.7);  
    disp('Paused to allow simulation to complete.');
    
    % Extract output from the model
    [tt, phi] = cortical_output();
    disp('Cortical output extracted.');
    [ave_mep, sim_mep_mag, epoched_sim_mep] = mep_output(tt, phi);
end
