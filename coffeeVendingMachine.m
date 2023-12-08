function coffeeVendingMachine()

% Commands to clear workspace, close all figures, and clear the command window
clear all;
close all;
clc;

% Initialize GUI and get the main frame
mainFrame = initGUI();
pause(1);

% Retrieve the data structure associated with the main frame and save it back to the figure
machineData = guidata(mainFrame);
guidata(mainFrame, machineData);
% Pause the execution of the code until the main frame is closed
waitfor(mainFrame);
end

% This function creates the GUI for the coffee vending machine
function mainFrame = initGUI()

% Define all the required machine data variables
machineData.coffeeTypes = {'Espresso', 'Cappuccino', 'Americano', 'Latte', 'Mocha', 'Macchiato', 'Flat White', 'Cortado', 'Hot Milk', 'Hot Chocolate'};
machineData.coffeePrices = [1.50, 2.00, 2.50, 1.75, 2.25, 2.00, 2.25, 2.00, 2.75, 1.75];
machineData.cupSize = {'small', 'medium', 'large'};
machineData.machineStatus = 'idle';
machineData.coffeePaid = 0;
machineData.hasChange = 0;
machineData.buttonsEnabled = 0;
machineData.enableInteractions = 0;

% These are the colors used for the various elements in the GUI
backgroundColor = hex2dec({'FF','FA','F0'})'/255;
titleBackgroundColor = hex2dec({'FF','5F','1F'})'/255;
buttonColor = hex2dec({'5A','5A','5A'})'/255;
titleTextColor = hex2dec({'FF','FF','FF'})'/255;
coffeeTextColor = hex2dec({'00','00','00'})'/255;

% The extras
machineData.extraMilk = 0;
machineData.extraSugar = 0;
machineData.coffeeReady = 0;

% Get the screen size and define figure size
screenSize = get(0, "screensize");
figureSize = [1000, 700];
% Calculate the position for the figure to be centered
mainFramePos =[(screenSize(3) - figureSize(1))/2, (screenSize(4) - figureSize(2))/2, figureSize(1), figureSize(2)];

% Create the GUI frames
mainFrame = figure('name', 'Coffee Vending Machine Simulation', 'NumberTitle', 'off', 'toolbar', 'none', 'resize', 'off', 'position', mainFramePos);
titleFrame = uipanel('parent', mainFrame, 'backgroundcolor', titleBackgroundColor, 'position', [0 0.9 1 0.1]);
coffeeSelectionFrame = uipanel('parent', mainFrame, 'backgroundcolor', backgroundColor, 'position', [0 0 1 0.9]);

% Children uicontrols of titleFrame
titleText = uicontrol('parent', titleFrame, 'units', 'normalized', 'style', 'text', 'string', 'Coffee Vending Machine', 'fontsize', 22, 'fontname', 'Nunito', 'backgroundcolor', titleBackgroundColor, 'foregroundcolor', titleTextColor, 'position', [0.25 0 0.5 1], 'horizontalalignment', 'center');
clockText = uicontrol('parent', titleFrame, 'units', 'normalized', 'style', 'text', 'string', datestr(now, 'HH:MM'), 'fontsize', 16, 'fontname', 'Nunito', 'backgroundcolor', titleBackgroundColor, 'foregroundcolor', titleTextColor, 'position', [0.8 0 0.25 1], 'horizontalalignment', 'center');

% Get the handle for the current figure
mainFrame = gcf;

spacing = 0.03;
panelWidth = (1 - 6 * spacing)/5;
panelHeight = (1 - 5 * spacing)/2;

% This loop creates the coffee panel and calculation the position of each
for i = 1 : length(machineData.coffeeTypes)
row = floor((i-1)/5);
col = mod(i - 1, 5);
panelX = spacing + col * (panelWidth + spacing); % X position of the panel
panelY = 1 - spacing - (row + 1) * (panelHeight + spacing); % Y position of the panel

coffeePanel = uipanel('parent', coffeeSelectionFrame, 'backgroundcolor', 'white', 'position', [panelX panelY panelWidth panelHeight], 'bordertype', 'etchedin');

% Load images for each type of coffee and display it on the panel
coffeeImage = imread(strcat('./Coffee Images/', machineData.coffeeTypes{i}, '.png'));
uicontrol('parent', coffeePanel, 'style', 'pushbutton', 'cdata', coffeeImage, 'units', 'normalized', 'position', [0 0.3 1 0.7]);

% Display coffee name and price
uicontrol('parent', coffeePanel, 'style', 'text', 'string', machineData.coffeeTypes{i}, 'fontsize', 10, 'fontname', 'Montserrat', 'backgroundcolor', 'white', 'foregroundcolor', coffeeTextColor, 'units', 'normalized', 'position', [0.05 0.2 0.8 0.1], 'horizontalalignment', 'left');
uicontrol('parent', coffeePanel, 'style', 'text', 'string', ['$ ' num2str(machineData.coffeePrices(i))], 'fontsize', 10, 'fontname', 'Montserrat', 'backgroundcolor', 'white', 'foregroundcolor', '#FF7F7F', 'units', 'normalized', 'position', [0.1 0.05 0.8 0.1], 'horizontalalignment', 'right');
end

% Update clock text every second until the main frame is closed
while ishandle(mainFrame) && ishandle(clockText)
    set(clockText, 'string', datestr(now, 'HH:MM'));
    pause(1);
  end
end








