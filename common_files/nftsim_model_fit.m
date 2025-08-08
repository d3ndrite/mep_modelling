function [fval, sim_mep_mag, epoched_sim_mep, nmep_sim] = nftsim_model_fit(x_values, mean_data)
    % Persistent variable to track the number of iterations
    persistent iteration_count;
    if isempty(iteration_count)
        iteration_count = 0; % Initialize at first function call
    end
    iteration_count = iteration_count + 1; % Increment count
    
    iterator=iteration_count;
    
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
    pause(0.7);  %! if run.conf writing does not complete, consider increasing this time
    disp('Paused to allow simulation to complete.');
    
    % Extract output from the model
    [tt, phi] = cortical_output(); % extracts layer 5 output
    disp('Cortical output extracted.');
    [ave_mep, sim_mep_mag, epoched_sim_mep] = mep_output(tt, phi); % simulates MEP
    % plot(ave_mep(1:1000))

    % checks to prevent invalid MEPs
    sim_mag = abs(max(epoched_sim_mep(350:700))-min(epoched_sim_mep(350:700)));

    if sim_mag < 0.01 
        disp(['Invalid iteration. sim_mag <0.01 for iteration', num2str(iterator)])
        % fval1 = NaN;
        fval=NaN;
    elseif (sum(epoched_sim_mep(400:750), 1) == 0)
        disp(['Invalid iteration. blank simulated MEP for the valid range for iteration:', num2str(iterator)])
        fval=NaN;
    else
    	epoched_sim = epoched_sim_mep;
        nmep_sim = epoched_sim(350:700); % (this accounds for 200 points tau delay and 150 points for 15ms pulse to MEP observed in the simulation)
        nmep_exp = mean_data;

        fval = abs(abs(max(nmep_exp)-min(nmep_exp))-abs(max(nmep_sim)-min(nmep_sim)));

    end
        % Display the current error value
        disp(['Error:', num2str(iteration_count), ': ', num2str(fval)]);
    end 
    
