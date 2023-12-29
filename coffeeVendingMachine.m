function coffeeVendingMachine()

% Commands to clear workspace, close all figures, and clear the command window
clear all;
close all;
clc;

player = [];

% Initialize GUI and get the main frame
mainFrame = initGUI();
machineData.buttonsEnabled = 1;
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
machineData.coffeePrices = [2.50, 3.50, 4.30, 3.00, 5.00, 3.00, 3.75, 4.00, 3.50, 4.20];
machineData.cupSize = {'small', 'medium', 'large'};
machineData.coffeePaid = 0;
machineData.hasChange = 0;
machineData.buttonsEnabled = 0;
machineData.enableInteractions = 0;
machineData.totalInserted = 0;

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
screenSize = get(0, 'screensize');
figureSize = [1000, 700];
% Calculate the position for the figure to be centered
mainFramePos =[(screenSize(3) - figureSize(1))/2, (screenSize(4) - figureSize(2))/2, figureSize(1), figureSize(2)];

% Pre-load all coffee images into a cell array
coffeeImages = cell(1, length(machineData.coffeeTypes));
for i = 1:length(coffeeImages)
    coffeeImages{i} = imread(strcat('./CoffeeImages/', machineData.coffeeTypes{i}, '.png'));
end

% Pre-process coffee names and prices into separate arrays
machineData.coffeeNames = machineData.coffeeTypes;
machineData.coffeePrices = machineData.coffeePrices;

% Create the GUI frames
mainFrame = figure('name', 'Coffee Vending Machine Simulation', 'NumberTitle', 'off', 'toolbar', 'none', 'resize', 'off', 'position', mainFramePos, 'visible', 'on');
mainFrame = gcf;
titleFrame = uipanel('parent', mainFrame, 'backgroundcolor', titleBackgroundColor, 'position', [0 0.9 1 0.1]);
coffeeSelectionFrame = uipanel('parent', mainFrame, 'backgroundcolor', backgroundColor, 'position', [0 0 1 0.9]);

% Text to display the current time
titleText = uicontrol('parent', titleFrame, 'units', 'normalized', 'style', 'text', 'string', 'taste', 'fontsize', 23, 'fontname', 'Georgia', 'backgroundcolor', titleBackgroundColor, 'foregroundcolor', titleTextColor, 'position', [0.25 0 0.5 1], 'horizontalalignment', 'center', 'fontweight', 'bold');
clockText = uicontrol('parent', titleFrame, 'units', 'normalized', 'style', 'text', 'string', datestr(now, 'HH:MM'), 'fontsize', 16, 'fontname', 'Calibri', 'backgroundcolor', titleBackgroundColor, 'foregroundcolor', titleTextColor, 'position', [0.8 0 0.25 1], 'horizontalalignment', 'center', 'fontweight', 'bold');

spacing = 0.03;
panelWidth = (1 - 6 * spacing)/5;
panelHeight = (1 - 5 * spacing)/2;

% This loop creates the coffee panel and calculates position of each
for i = 1 : length(machineData.coffeeTypes)
row = floor((i-1)/5);
col = mod(i - 1, 5);
panelX = spacing + col * (panelWidth + spacing);
panelY = 1 - spacing - (row + 1) * (panelHeight + spacing);

coffeePanel = uipanel('parent', coffeeSelectionFrame, 'backgroundcolor', 'white', 'position', [panelX panelY panelWidth panelHeight], 'bordertype', 'etchedin');
% On-demand image loading
uicontrol('parent', coffeePanel, 'style', 'pushbutton', 'units', 'normalized', 'position', [0 0.3 1 0.7], 'callback', {@loadImageCallback, i, coffeeImages, coffeePanel});

% Load images for each type of coffee and display it on the panel
coffeeImage = imread(strcat('./CoffeeImages/', machineData.coffeeTypes{i}, '.png'));
uicontrol('parent', coffeePanel, 'style', 'pushbutton', 'cdata', coffeeImage, 'units', 'normalized', 'position', [0 0.3 1 0.7]);

% Display coffee name and price
uicontrol('parent', coffeePanel, 'style', 'text', 'string', machineData.coffeeTypes{i}, 'fontsize', 12, 'fontname', 'Calibri', 'backgroundcolor', 'white', 'foregroundcolor', coffeeTextColor, 'units', 'normalized', 'position', [0.05 0.2 0.8 0.1], 'horizontalalignment', 'left', 'fontweight', 'bold');
uicontrol('parent', coffeePanel, 'style', 'text', 'string', ['€ ' sprintf('%.2f', machineData.coffeePrices(i))], 'fontsize', 12, 'fontname', 'Calibri', 'backgroundcolor', 'white', 'foregroundcolor', '#FF5F1F', 'units', 'normalized', 'position', [0.15 0.05 0.8 0.1], 'horizontalalignment', 'right', 'fontweight', 'bold');
uicontrol('parent', coffeePanel, 'style', 'pushbutton', 'string', 'Select', 'units', 'normalized', 'fontsize', 10, 'fontname', 'Calibri', 'position', [0.05 0.1 0.5 0.1], 'callback', {@coffeePanelCallback, i, mainFrame});
end

% Update clock text every second until the main frame is closed
while ishandle(mainFrame) && ishandle(clockText)
set(clockText, 'string', datestr(now, 'HH:MM'));
pause(1);
end

guidata(mainFrame, machineData);
end

% Image loading callback function
function loadImageCallback(hObject, eventdata, i, coffeeImages, panel)
set(hObject, 'cdata', coffeeImages{i});
end

% Callback function for coffee panel click event
function coffeePanelCallback(hObject, eventdata, coffeeIndex, mainFrame)
machineData = guidata(mainFrame);
machineData.coffeeTypes = {'Espresso', 'Cappuccino', 'Americano', 'Latte', 'Mocha', 'Macchiato', 'Flat White', 'Cortado', 'Hot Milk', 'Hot Chocolate'};
machineData.coffeePrices = [2.50, 3.50, 4.30, 3.00, 5.00, 3.00, 3.75, 4.00, 3.50, 4.20];
machineData.coffeeStrengths = {'LOW', 'NORMAL', 'STRONG'};
machineData.sugarLevels = {'NONE', 'LESS', 'NORMAL', 'MORE'};

backgroundColor = hex2dec({'FF','FA','F0'})'/255;
titleBackgroundColor = hex2dec({'FF','5F','1F'})'/255;
buttonColor = hex2dec({'5A','5A','5A'})'/255;
titleTextColor = hex2dec({'FF','FF','FF'})'/255;
coffeeTextColor = hex2dec({'00','00','00'})'/255;

% Create mini window panel that overlays the existing panels
miniWindow = uipanel('parent', mainFrame, 'backgroundcolor', backgroundColor, 'position', [0.1 0.1 0.8 0.8]);

% Actions menubar
actions = uimenu('label', 'Actions');
insertMoneyHeading = uimenu(actions, 'label', '--- Insert Money ---', 'enable', 'off');
insert1Cent = uimenu(actions, 'label', 'Insert €0.01', 'callback', {@insertMoneyCallback, 0.01, coffeeIndex, mainFrame, miniWindow});
insert2Cents = uimenu(actions, 'label', 'Insert €0.02', 'callback', {@insertMoneyCallback, 0.02, coffeeIndex, mainFrame, miniWindow});
insert5Cents = uimenu(actions, 'label', 'Insert €0.05', 'callback', {@insertMoneyCallback, 0.05, coffeeIndex, mainFrame, miniWindow});
insert10Cents = uimenu(actions, 'label', 'Insert €0.10', 'callback', {@insertMoneyCallback, 0.10, coffeeIndex, mainFrame, miniWindow});
insert20Cents = uimenu(actions, 'label', 'Insert €0.20', 'callback', {@insertMoneyCallback, 0.20, coffeeIndex, mainFrame, miniWindow});
insert50Cents = uimenu(actions, 'label', 'Insert €0.50', 'callback', {@insertMoneyCallback, 0.50, coffeeIndex, mainFrame, miniWindow});
insert1Euro = uimenu(actions, 'label', 'Insert €1.00', 'callback', {@insertMoneyCallback, 1.00, coffeeIndex, mainFrame, miniWindow});
insert2Euros = uimenu(actions, 'label', 'Insert €2.00', 'callback', {@insertMoneyCallback, 2.00, coffeeIndex, mainFrame, miniWindow});
takeChangeHeading = uimenu(actions, 'label', '--- Ready to Collect Change? ---', 'enable', 'off');
collectChange = uimenu(actions, 'label', 'Collect Change', 'callback', {@brewAndCollectChange, coffeeIndex, mainFrame});
takeCoffeeHeading = uimenu(actions, 'label', '--- Ready to Collect Coffee? ---', 'enable', 'off');
collectCoffee = uimenu(actions, 'label', 'Collect Coffee', 'callback', {@collectCoffeeCallback, mainFrame, miniWindow});

machineData.insertMoneyButtons = [insert1Cent, insert5Cents, insert10Cents, insert20Cents, insert50Cents, insert1Euro, insert2Euros];
machineData.collectChange = collectChange;
machineData.collectCoffee = collectCoffee;
machineData.actions = actions;

% Display the coffee image on the left side of the panel
pkg load image;
selectedCoffeeImage = imread(strcat('./CoffeeImages/', machineData.coffeeTypes{coffeeIndex}, '.png'));
coffeeImageAxes = axes('parent', miniWindow, 'units', 'normalized', 'position', [0 0 0.3 1], 'visible', 'off', 'color', backgroundColor);

coffeeImageAxesUnits = get(coffeeImageAxes, 'units');
set(coffeeImageAxes, 'units' , 'pixels');
coffeeImageAxesPos = get(coffeeImageAxes, 'position');
set(coffeeImageAxes, 'units' , coffeeImageAxesUnits);

resizedCoffeeImage = imresize(selectedCoffeeImage, [coffeeImageAxesPos(4) coffeeImageAxesPos(3)]);
imshow(resizedCoffeeImage, 'parent', coffeeImageAxes);

coffeeTypeText = uicontrol('parent', miniWindow, 'style', 'text', 'string', machineData.coffeeTypes{coffeeIndex}, 'units', 'normalized', 'position', [0.35 0.9 0.3 0.1], 'backgroundcolor', backgroundColor, 'foregroundcolor', coffeeTextColor, 'fontsize', 20, 'fontname', 'Calibri', 'horizontalalignment', 'left');
coffeePriceText = uicontrol('parent', miniWindow, 'style', 'text', 'string', ['€ ' sprintf('%.2f', machineData.coffeePrices(coffeeIndex))], 'fontsize', 14, 'fontname', 'Calibri', 'backgroundcolor', backgroundColor, 'foregroundcolor', '#FF5F1F', 'units', 'normalized', 'position', [0.6 0.9 0.1 0.1], 'horizontalalignment', 'right', 'fontweight', 'bold');
dividerAxes = axes('parent', miniWindow, 'units', 'normalized', 'position', [0.23 0.4 0.85 1], 'visible', 'off');
dividerLine = line('parent', dividerAxes, 'xdata', [0.35 0.85], 'ydata', [0.85 0.85], 'color', 'k');

uicontrol('parent', miniWindow, 'style', 'text', 'string', 'Coffee Strength', 'units', 'normalized', 'position', [0.35 0.8 0.3 0.05], 'backgroundcolor', backgroundColor, 'foregroundcolor', 'black', 'fontsize', 14, 'fontname', 'Calibri');
for i = 1 : length(machineData.coffeeStrengths)
uicontrol('parent', miniWindow, 'style', 'togglebutton', 'tag', 'coffeeStrength', 'string', machineData.coffeeStrengths{i}, 'units', 'normalized', 'position', [0.35+(i-1)*0.1 0.7 0.09 0.09], 'backgroundcolor', 'white', 'foregroundcolor', '#FF5F1F', 'fontsize', 10, 'fontname', 'Calibri', 'callback', {@updateButton}, 'fontweight', 'bold');
end

uicontrol('parent', miniWindow, 'style', 'text', 'string', 'Sugar Level', 'units', 'normalized', 'position', [0.35 0.6 0.3 0.08], 'backgroundcolor', backgroundColor, 'foregroundcolor', 'black', 'fontsize', 14, 'fontname', 'Calibri');
for i = 1 : length(machineData.sugarLevels)
uicontrol('parent', miniWindow, 'style', 'togglebutton', 'tag', 'sugarLevel', 'string', machineData.sugarLevels{i}, 'units', 'normalized', 'position', [0.35+(i-1)*0.1 0.5 0.09 0.1], 'backgroundcolor', 'white', 'foregroundcolor', '#FF5F1F', 'fontsize', 10, 'fontname', 'Calibri', 'callback', {@updateButton}, 'fontweight', 'bold');
end

machineData.userPrompt = uicontrol('parent', miniWindow, 'style', 'text', 'string', sprintf('Please insert €%.2f.', machineData.coffeePrices(coffeeIndex)), 'units', 'normalized', 'position', [0.4 0.3 0.5 0.2], 'backgroundcolor', backgroundColor, 'foregroundcolor', coffeeTextColor, 'fontsize', 12, 'fontname', 'Calibri', 'horizontalalignment', 'center', 'fontweight', 'bold');
guidata(mainFrame, machineData);
end

% This function handles the insertion of coins into the machine and change calculation
function insertMoneyCallback(hObject, eventdata, amount, coffeeIndex, mainFrame, miniWindow)
machineData = guidata(mainFrame);

if ~isfield(machineData, 'totalInserted')
machineData.totalInserted = 0;
end

machineData.totalInserted = machineData.totalInserted + amount;
remainingAmount = machineData.coffeePrices(coffeeIndex) - machineData.totalInserted;
if remainingAmount > 0
set(machineData.userPrompt, 'string', sprintf('Please insert €%.2f more.', abs(remainingAmount)));
machineData.coffeePaid = 0;
else
change = abs(remainingAmount);
set(machineData.userPrompt, 'string', sprintf('Brewing %s. Change: €%.2f.', machineData.coffeeTypes{coffeeIndex}, change));
machineData.coffeePaid = 1;
machineData.hasChange = 1;
end

set(machineData.collectCoffee, 'enable', 'off');
guidata(mainFrame, machineData);
end


% Playing sound while coffee is being brewed
function playAudio()
persistent player;
if isempty(player) || ~isplaying(player)
[y, fs] = audioread('./Sounds/01_Brewing.wav');
player = audioplayer(y, fs);
play(player);
end
end

% Callback that handles change collection
function brewAndCollectChange(hObject, eventdata, coffeeIndex, mainFrame)
machineData = guidata(mainFrame);
machineData.coffeePaid = 1;
machineData.hasChange = 1;

if machineData.coffeePaid == 1 && machineData.hasChange == 1
set(machineData.insertMoneyButtons, 'enable', 'off');
set(machineData.collectChange, 'enable', 'off');
set(machineData.userPrompt, 'string', sprintf('Your coffee is being made. Please wait...'));
playAudio();
pause(52);
set(machineData.userPrompt, 'string', sprintf('Your coffee is ready! Please collect it and enjoy!'));
set(machineData.collectCoffee, 'enable', 'on');
endif

guidata(mainFrame, machineData);
end

% Wrap up the process, close mini window and delete menubar
function collectCoffeeCallback(hObject, eventdata, mainFrame, miniWindow)
machineData = guidata(mainFrame);
set(machineData.userPrompt, 'string', sprintf('Thank you! Ready to take new order.'));
set(machineData.collectCoffee, 'enable', 'off');
pause(8);
delete(miniWindow);
set(machineData.actions, 'enable', 'off');

guidata(mainFrame, machineData);
end

% Callback function to update the buttons when one is clicked
function updateButton(hObject, ~, buttonIndex)
buttonGroup = get(hObject, 'tag');
allButtons = findobj('style', 'togglebutton');
buttonsInGroup = allButtons(strcmp(get(allButtons, 'tag'), buttonGroup));

set(buttonsInGroup, 'value', 0, 'backgroundcolor', 'white', 'foregroundcolor', '#FF5F1F');
set(hObject, 'value', 1, 'backgroundcolor', '#FF5F1F', 'foregroundcolor', 'white');

selectedButton = findobj(buttonsInGroup, 'value', 1);
if ~isempty(selectedButton) && selectedButton ~= hObject
set(selectedButton, 'value', 0, 'backgroundcolor', 'white', 'foregroundcolor', '#FF5F1F');
end
end


