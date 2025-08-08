function [ave_mep, sim_mep_mag, epoched_sim_mep]=mep_output(tt,phi)
% modified from motomodel.m 
%!!! JK: saving epoched_sim_mep from main function instead of here

M = 100;    %how many different motounits to consider
max_input = 900;  %Controls alpha in paper.  Alpha = (max_input/min_input)/M. maximum firing rate likely to be received as input from layer 5. Standard 900
min_input = 14;  % T_min in paper.  min firing rate per second to get a motounit to fire. Standard 10 or 14 to get no activity for 0 bg
min_firing = 8;    %q_min in paper. minimum firing rate of motoneuron. Standard 8
max_firing = 300;  %Qmmax in paper. maximum firing rate of motoneuron
lambda =  2e-3;  %the lambda parameter of moezzi for describing the MUAP function
time_delay = 10e-3;  %a 10 ms time delay (moezzi) in aligning the muaps
gain=1.0;   %a multiplying gain for the input.  
mV_scaling = 3.0; % scaling factor to get the output correct (= M_0 / min_input in paper).  Standard 3 for paper

%% equation 5
a=log(max_input/min_input)/M;   % the Li parameter 'a'
motoindex=1:M;   %motounit number
%% equation 4
thresholds=min_input*exp(a*motoindex);   % a list of thresholds

% multiply up the input by a gain factor
phi=(phi*gain);  

%% firing_rate_for_each is a function: get_firing_rate(phi, thresholds, gradient_for_i, intercept_for_i); %% Equation number 6

% Assume that they all end at the max input, max firing point, but start at threshold, 8 Hz point
gradient_for_i = (max_firing - min_firing)*(max_input - thresholds).^(-1);  %increase in y over increase in x

%only thresholds is a vector so should get a vector out here.make sure last one doesn't have infinite gradient

gradient_for_i(end) = gradient_for_i(end-1); 
intercept_for_i = min_firing - (thresholds.*gradient_for_i);  %calculate intercept on y axis

% below is the equation 6 function: Q_k(t) = f{phi_v(t)} = q + κk * (phi_v(t)- Tk)
% κappa_k (for each firing motoneuron k) is factored in when the axonal flux rate (phi_v) from the layer 5 neurons exceeds a unit s threshold T_k)
firing_rate_for_each = get_firing_rate(phi, thresholds, gradient_for_i, intercept_for_i); 

% Similarly, now find locations of firings for each (when do they fire)
firing_times = get_firing_times(tt,firing_rate_for_each);

%% {Equations 8 & 9} Finally we need to convolve with our function
% 1. Each sucessive unit comes in more strongly. 
% 2. Take each firing sequence (0 and 1) and multiply it by the threshold for that unit
% 3. Make a matrix where each row is identical, but each column is the threshold for that motounit

threshold_matrix = ones(length(tt),1)*thresholds;  %create array of ones = size of tt

weighted_firing = firing_times.*threshold_matrix; % multiply by threshold to get threshold of each motounit
% Now have the ith unit being 0 or its threshold. 

% 4. Sum them all up over all units (columns)
% 5. Multiply by a mV scale factor to get y-scale right.
total_impact = mV_scaling*sum(weighted_firing,2); % M_0=42(mV*s) is factroed in here.
% Carry out convolution.  p6321
deltat=tt(2)-tt(1); 
t_in_muap = [-5*lambda:deltat:5*lambda]; %"-5*lamba to 5*labda in the steps of deltat" t_in_muap is a vector starting from -5*

% {Equation 8}
muap = -t_in_muap.*exp(-(t_in_muap/lambda).^2);

% {Equation 9}
motor_output = conv(total_impact,muap,'same');  
%This will have a length longer than both total_impact and muap. We want the central bit take only middle bit for accurate timing
%shift this by 10 ms rightwards
%move by time_delay/deltat steps
motor_output_final = [zeros(round(time_delay/deltat),1); motor_output(1:end - round(time_delay/deltat))];  

%% Find average MEP output figure;
% reshape the motor_output_final to allow an average
 motor_shaped = reshape(motor_output_final, round(1/deltat), round(length(motor_output_final)*deltat));
% motor_shaped = reshape(motor_output_final, 1e4, 10); %% !! absolute values
%default: ave_mep = mean(motor_shaped(:, 3:10), 2);
ave_mep = mean(motor_shaped(:, 3:10), 2); %06_06: 3:10 -> 3

% magnitude = max(ave_mep)-min(ave_mep);

epoched_sim_mep = ave_mep(1:1000, :);
% Compute sim_mep_mag
sim_mep_mag = max(epoched_sim_mep) - min(epoched_sim_mep);

end





