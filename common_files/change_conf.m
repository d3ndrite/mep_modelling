function [] = change_conf(currentfolder, filename, x_values)

% Step 1: Define the file path
filePath = fullfile(currentfolder, filename);

% Step 2: Read the file as a text array
fileLines = readlines(filePath);

% Step 3: Define target line indices and patterns
targetLineIndices_list = [99, 100, 101, 103, 104, 105, 107, 108, 109, 111, 112, 113];
searchPattern_list = {'Coupling 2:  Map  - nu:', 'Coupling 3:  Map  - nu:', 'Coupling 4:  Map  - nu:', ...
    'Coupling 6:  Map  - nu:', 'Coupling 7:  Map  - nu:', 'Coupling 8:  Map  - nu:', ...
    'Coupling 10:  Map  - nu:', 'Coupling 11:  Map  - nu:', 'Coupling 12:  Map  - nu:', ...
    'Coupling 14:  Map  - nu:', 'Coupling 15:  Map  - nu:', 'Coupling 16:  Map  - nu:'};

% Assuming values_to_replace is defined elsewhere in your code
v_ee = x_values(1); %
v_ei = -x_values(3); %!26_03
v_ie = x_values(2);
v_ii = -x_values(4); %!26_03
values_to_replace_list = [v_ee, v_ei, v_ei, v_ie, v_ii, v_ii, v_ie, v_ii, v_ii, v_ee, v_ei, v_ei];
final_values = values_to_replace_list.* 1e-4; % appending the order of magnitude
% disp(final_values);
disp(x_values)

% Step 4: Loop through each target line
for tarindx_iter = 1:length(targetLineIndices_list)
    targetLineIndex = targetLineIndices_list(tarindx_iter);
    targetLine = fileLines(targetLineIndex);
    searchPattern = searchPattern_list{tarindx_iter};

    % Check if the pattern exists in the line
   if contains(targetLine, searchPattern)
    % Get the new replacement value
    newNumber = final_values(tarindx_iter);

    % Step 9: Format the new number dynamically
    if abs(newNumber) < 1e-2 || abs(newNumber) >= 1e4
        formattedNumber = sprintf('%+.4e', newNumber); % Scientific notation with 4 decimals
    else
        formattedNumber = sprintf('%+.8f', newNumber); % Fixed notation with 4 decimals
    end

    % Ensure correct formatting: make sure there is always one digit before the decimal
    formattedNumber = regexprep(formattedNumber, '([-+]?\d)\.e', '$1.0e'); % Ensures "9.e-05" → "9.0e-05"

    % Remove unnecessary ".0" in floats
    formattedNumber = regexprep(formattedNumber, '\.0+$', '');

    % Ensure "0.0000" is converted to just "0"
    if str2double(formattedNumber) == 0
        formattedNumber = '0';
    end

    % Remove unnecessary "+" sign but keep "-" sign
    formattedNumber = regexprep(formattedNumber, '^\+', '');

    % Step 10: Replace the number in the line
    updatedLine = strcat(searchPattern, ' ', formattedNumber);

    % Step 11: Update the file content
    fileLines(targetLineIndex) = updatedLine;
else
    warning('Pattern not found in line %d. Skipping...', targetLineIndex);
   end

end

% Step 12: Write the modified content back to the file
writelines(fileLines, filePath);

disp('Changes successful :)');

end

