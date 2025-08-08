function [tt,phi]=cortical_output()

silent = true; % Default: allow output

    
    % Your existing code..
if ~silent
  disp('Cortical output extracted.'); % This message will only show if silent == false
end

% neurofield_read_sept17.mmarcus_config_op.output
% Marcus Wilson 4 September 2017
% Read in the basic neurofield output from the example of version 0.1.4
%
close all; %clear
%
% Read with the nf_read file
%
%%%%%  INPUT here %%%%%%%%%%%%%%%%%%

% node_select= 1;   %a list of nodes that we will plot out. Must be taken from 1 to the number of nodes that the code outputs
% show_plasticity=false;  %do we show plasticity output? frue of false
fid=fopen('op.output');   %Put in name of file we wish to open
%% 11 July 2018  Parameters for raster plots and spike generation

% N=150;  %number of neurons
% do_spike_reconstruction=false;  %do we reconstruct spikes?  Make note of which population we need
% sigma=0.15;  %the standard deviation
% do_raster=false;  %will only work if we also do spike reconstruction
% time_needed_array = [1 40689];  %in ms - what points do we plot in the raster plot
% nearest_pulse_time = 2440;  % in ms  - when is the closest pulse to the period we want to plot?
% resynch_time=0.2;   %resynch every burst of 5Hz rTMS
% rel_phi=17.8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


tline='some_string_to_start';
row=0;

%% String find: first, we'll find the number of nodes
%Step 1: find node string

while( ~( (tline(1)=='N')  && (tline(2)=='o')  && (tline(3)=='d') ) ) %looks for node
tline=fgetl(fid); 
if (length(tline)<1)
    tline='empty_line';
end
% disp(tline)
row=row+1;
end
%Now have reached the row where the nodes are. 
% disp('*****')
nnodes_sim=str2num(tline(7:end));

%Step 2: output string

while(~( (tline(1) == 'O') & (tline(2) == 'u') & (tline(3) == 't') ) ) %look for the string 'Out' for 'Output'
tline=fgetl(fid);  %read next line
if (length(tline)<3)
    tline='empty_line';
end
% disp(tline);
row=row+1;   %how many rows have we read in?

end
% disp(['***found the output line*** it is ' tline]);
pos_interval=strfind(tline,'Inter');    %{Interval is delta_t}; find 'Inter' (start of 'interval')

%% Now read the write time (how many samples are written out in results per second)
% The value will start in position 9 following this
interval_dt=str2num(tline(pos_interval+9:end));   %turn to number

%% Find whether we do all nodes or not.  Identify how many nodes we have outputed

all_find=strfind(tline,'All');   
if (isempty(all_find))
    %if we couldn't find the word 'All' then we are only outputing some
    %nodes
    %
    %Find where 'Node:' ends and 'Start:' starts. That's where our output
    %nodes are listed. 
    node_find=strfind(tline,'Node:');
    start_find=strfind(tline,'Start:');
    nodes_outputed=str2num( tline(node_find+5:start_find-1) );  %look in this portion of tline
    nnodes=length(nodes_outputed);   %now identifying the number of nodes
else
    %we have found the word 'All'. So we do all nodes.Keep nnodes as we
    %found it earlier
    nnodes=nnodes_sim;  %nnodes for output is the same as the simulation nodes
end


%% Find the output data
tline='empty_line';
while(~(tline(1) == '=') )  %while we don't have '===' at start, read in a new line
tline=fgetl(fid);   
if (length(tline)<3)
    tline='empty_line';
end
% disp(tline);
row=row+1;   %how many rows have we read in?
end

%% Now we read in three empty lines
tline1=fgetl(fid);
tline2=fgetl(fid);
tline3=fgetl(fid);
row=row+3;  %add in another three to the row count

%% Now we start on the data
%read in file, with blank line as delimiter and skipping first 'row' rows and zero columns

%deadline: result=dlmread("marcus_config_op.output",'',row,0);
%temp result=dlmread("op.output",'',row,0);
result=dlmread("op.output",'',row,0);
% ^M = dlmread(filename,delimiter,R1,C1) starts reading at row offset R1 and column offset 0.

%% Data in output file:  
tt=result(:,1);  %seconds
phi=result(:,2:nnodes+1);  %per second


end
