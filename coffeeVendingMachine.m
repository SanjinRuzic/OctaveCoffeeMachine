function coffeeVendingMachine()

% Clear workspace, figures and cmd window
clear all;
close all;
clc;

% Initialize an empty player variable
player = [];

% Initialize GUI
mainFrame = initGUI();
pause(1);

% Retrieve and save GUI data structure
machineData = guidata(mainFrame);
guidata(mainFrame, machineData);

% Wait until main frame is closed
waitfor(mainFrame);
end

function mainFrame = initGUI()

% Declare global variables for machine stats
global totalCoffeeMade;
global machineBalance;
global waterLevel;
global coffeeBeans;

% Load machine state from file if it exists
filePath = fullfile('C:', 'Users', 'durop', 'Desktop', 'coffeeMachineSimulation', 'm_inv.txt');
if exist(filePath, 'file')
fid = fopen(filePath, 'r');
fileData = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);

if isempty(fileData{1})
totalCoffeeMade = 0;
machineBalance = 100;
waterLevel = 5000;
coffeeBeans = 1000;

else
textLine1 = fileData{1}{1};
textLine2 = fileData{1}{2};
textLine3 = fileData{1}{3};
textLine4 = fileData{1}{4};

coffeeMadeStartIndex = strfind(textLine1, 'Coffee Made: ') + 13;
totalCoffeeMade = str2num(textLine1(coffeeMadeStartIndex:end));

balanceStartIndex = strfind(textLine2, 'Balance: ') + 9;
machineBalance = str2num(textLine2(balanceStartIndex:end));

waterLevelStartIndex = strfind(textLine3, 'Water Level: ') + 13;
waterLevel = str2num(textLine3(waterLevelStartIndex:end));

coffeeBeansStartIndex = strfind(textLine4, 'Coffee Beans: ') + 14;
coffeeBeans = str2num(textLine4(coffeeBeansStartIndex:end));
end
end

% Define machine data structure
machineData.coffeeTypes = {'Espresso', 'Cappuccino', 'Americano', 'Latte', 'Mocha', 'Macchiato', 'Flat White', 'Cortado', 'Hot Milk', 'Hot Chocolate'};
machineData.coffeePrices = [2.50, 3.50, 4.30, 3.00, 5.00, 3.00, 3.75, 4.00, 3.50, 4.20];
machineData.coffeePaid = 0;
machineData.hasChange = 0;
machineData.totalInserted = 0;
machineData.coffeeReady = 0;

% Define colors for GUI elements
backgroundColor = hex2dec({'FF','FA','F0'})'/255;
titleBackgroundColor = hex2dec({'FF','5F','1F'})'/255;
buttonColor = hex2dec({'5A','5A','5A'})'/255;
titleTextColor = hex2dec({'FF','FF','FF'})'/255;
coffeeTextColor = hex2dec({'00','00','00'})'/255;

% Get screen size and calculate figure position
screenSize = get(0, 'screensize');
figureSize = [1000, 700];
mainFramePos =[(screenSize(3) - figureSize(1))/2, (screenSize(4) - figureSize(2))/2, figureSize(1), figureSize(2)];

% Pre-load coffee images
coffeeImages = cell(1, length(machineData.coffeeTypes));
for i = 1:length(coffeeImages)
coffeeImages{i} = imread(strcat('./CoffeeImages/', machineData.coffeeTypes{i}, '.png'));
end

% Pre-process coffee names and prices
machineData.coffeeNames = machineData.coffeeTypes;
machineData.coffeePrices = machineData.coffeePrices;

% Create GUI frames
mainFrame = figure('name', 'Coffee Vending Machine Simulation', 'NumberTitle', 'off', 'toolbar', 'none', 'resize', 'off', 'position', mainFramePos, 'visible', 'on');
mainFrame = gcf;
titleFrame = uipanel('parent', mainFrame, 'backgroundcolor', titleBackgroundColor, 'position', [0 0.9 1 0.1]);
coffeeSelectionFrame = uipanel('parent', mainFrame, 'backgroundcolor', backgroundColor, 'position', [0 0 1 0.9]);

% Text elements for title and clock
titleText = uicontrol('parent', titleFrame, 'units', 'normalized', 'style', 'text', 'string', 'taste', 'fontsize', 23, 'fontname', 'Georgia', 'backgroundcolor', titleBackgroundColor, 'foregroundcolor', titleTextColor, 'position', [0.25 0 0.5 1], 'horizontalalignment', 'center', 'fontweight', 'bold');
clockText = uicontrol('parent', titleFrame, 'units', 'normalized', 'style', 'text', 'string', datestr(now, 'HH:MM'), 'fontsize', 16, 'fontname', 'Calibri', 'backgroundcolor', titleBackgroundColor, 'foregroundcolor', titleTextColor, 'position', [0.8 0 0.25 1], 'horizontalalignment', 'center', 'fontweight', 'bold');

% Spacing and panel dimensions for coffee panels
spacing = 0.03;
panelWidth = (1 - 6 * spacing)/5;
panelHeight = (1 - 5 * spacing)/2;

% Create and arrange coffee panels
for i = 1 : length(machineData.coffeeTypes)
row = floor((i-1)/5);
col = mod(i - 1, 5);
panelX = spacing + col * (panelWidth + spacing);
panelY = 1 - spacing - (row + 1) * (panelHeight + spacing);
coffeePanel = uipanel('parent', coffeeSelectionFrame, 'backgroundcolor', 'white', 'position', [panelX panelY panelWidth panelHeight], 'bordertype', 'etchedin');

% On-demand image loading
uicontrol('parent', coffeePanel, 'style', 'pushbutton', 'units', 'normalized', 'position', [0 0.3 1 0.7], 'callback', {@loadImageCallback, i, coffeeImages, coffeePanel});

% Load coffee image directly and display name and price
coffeeImage = imread(strcat('./CoffeeImages/', machineData.coffeeTypes{i}, '.png'));
uicontrol('parent', coffeePanel, 'style', 'pushbutton', 'cdata', coffeeImage, 'units', 'normalized', 'position', [0 0.3 1 0.7]);
uicontrol('parent', coffeePanel, 'style', 'text', 'string', machineData.coffeeTypes{i}, 'fontsize', 12, 'fontname', 'Calibri', 'backgroundcolor', 'white', 'foregroundcolor', coffeeTextColor, 'units', 'normalized', 'position', [0.05 0.2 0.8 0.1], 'horizontalalignment', 'left', 'fontweight', 'bold');
uicontrol('parent', coffeePanel, 'style', 'text', 'string', ['€ ' sprintf('%.2f', machineData.coffeePrices(i))], 'fontsize', 12, 'fontname', 'Calibri', 'backgroundcolor', 'white', 'foregroundcolor', '#FF5F1F', 'units', 'normalized', 'position', [0.15 0.05 0.8 0.1], 'horizontalalignment', 'right', 'fontweight', 'bold');
uicontrol('parent', coffeePanel, 'style', 'pushbutton', 'string', 'Select', 'units', 'normalized', 'fontsize', 10, 'fontname', 'Calibri', 'position', [0.05 0.1 0.5 0.1], 'callback', {@coffeePanelCallback, i, mainFrame});
end

% Update clock text every second
while ishandle(mainFrame) && ishandle(clockText)
set(clockText, 'string', datestr(now, 'HH:MM'));
pause(1);
end

guidata(mainFrame, machineData);
end

function loadImageCallback(hObject, eventdata, i, coffeeImages, panel)
set(hObject, 'cdata', coffeeImages{i});
end

function closeMiniWindow(hObject, eventdata, miniWindow, actions)
delete(miniWindow);
delete(actions);
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

global waterLevel;
global coffeeBeans;

% Create mini window panel
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
collectChange = uimenu(actions, 'label', 'Collect Change', 'callback', {@brewAndCollectChange, coffeeIndex, mainFrame, miniWindow});
takeCoffeeHeading = uimenu(actions, 'label', '--- Ready to Collect Coffee? ---', 'enable', 'off');
collectCoffee = uimenu(actions, 'label', 'Collect Coffee', 'callback', {@collectCoffeeCallback, mainFrame, miniWindow, actions});

machineData.insertMoneyButtons = [insert1Cent, insert2Cents, insert5Cents, insert10Cents, insert20Cents, insert50Cents, insert1Euro, insert2Euros];
machineData.collectChange = collectChange;
machineData.collectCoffee = collectCoffee;
machineData.actions = actions;

set(machineData.collectChange, 'enable', 'off');
set(machineData.collectCoffee, 'enable', 'off');

closeButton = uicontrol('parent', miniWindow, 'style', 'pushbutton', 'units', 'normalized', 'position', [0.9 0.9 0.1 0.1], 'string', 'X', 'foregroundcolor', 'white', 'backgroundcolor', 'red', 'fontsize', 16, 'fontname', 'Calibri', 'fontweight', 'bold', 'callback', {@closeMiniWindow, miniWindow, actions});

% Display coffee image on the left of mini window
pkg load image;
selectedCoffeeImage = imread(strcat('./CoffeeImages/', machineData.coffeeTypes{coffeeIndex}, '.png'));
coffeeImageAxes = axes('parent', miniWindow, 'units', 'normalized', 'position', [0 0 0.3 1], 'visible', 'off', 'color', backgroundColor);
coffeeImageAxesUnits = get(coffeeImageAxes, 'units');
set(coffeeImageAxes, 'units' , 'pixels');
coffeeImageAxesPos = get(coffeeImageAxes, 'position');
set(coffeeImageAxes, 'units' , coffeeImageAxesUnits);

resizedCoffeeImage = imresize(selectedCoffeeImage, [coffeeImageAxesPos(4) coffeeImageAxesPos(3)]);
imshow(resizedCoffeeImage, 'parent', coffeeImageAxes);

% Display coffee info
coffeeTypeText = uicontrol('parent', miniWindow, 'style', 'text', 'string', machineData.coffeeTypes{coffeeIndex}, 'units', 'normalized', 'position', [0.35 0.9 0.3 0.1], 'backgroundcolor', backgroundColor, 'foregroundcolor', coffeeTextColor, 'fontsize', 20, 'fontname', 'Calibri', 'horizontalalignment', 'left');
coffeePriceText = uicontrol('parent', miniWindow, 'style', 'text', 'string', ['€ ' sprintf('%.2f', machineData.coffeePrices(coffeeIndex))], 'fontsize', 14, 'fontname', 'Calibri', 'backgroundcolor', backgroundColor, 'foregroundcolor', '#FF5F1F', 'units', 'normalized', 'position', [0.6 0.9 0.1 0.1], 'horizontalalignment', 'right', 'fontweight', 'bold');
dividerAxes = axes('parent', miniWindow, 'units', 'normalized', 'position', [0.23 0.4 0.85 1], 'visible', 'off');
dividerLine = line('parent', dividerAxes, 'xdata', [0.35 0.85], 'ydata', [0.85 0.85], 'color', 'k');

% Add buttons for coffee strength and sugar level
uicontrol('parent', miniWindow, 'style', 'text', 'string', 'Coffee Strength', 'units', 'normalized', 'position', [0.35 0.8 0.3 0.05], 'backgroundcolor', backgroundColor, 'foregroundcolor', 'black', 'fontsize', 14, 'fontname', 'Calibri');
for i = 1 : length(machineData.coffeeStrengths)
uicontrol('parent', miniWindow, 'style', 'togglebutton', 'tag', 'coffeeStrength', 'string', machineData.coffeeStrengths{i}, 'units', 'normalized', 'position', [0.35+(i-1)*0.1 0.7 0.09 0.09], 'backgroundcolor', 'white', 'foregroundcolor', '#FF5F1F', 'fontsize', 10, 'fontname', 'Calibri', 'callback', {@updateButton}, 'fontweight', 'bold');
end
uicontrol('parent', miniWindow, 'style', 'text', 'string', 'Sugar Level', 'units', 'normalized', 'position', [0.35 0.6 0.3 0.08], 'backgroundcolor', backgroundColor, 'foregroundcolor', 'black', 'fontsize', 14, 'fontname', 'Calibri');
for i = 1 : length(machineData.sugarLevels)
uicontrol('parent', miniWindow, 'style', 'togglebutton', 'tag', 'sugarLevel', 'string', machineData.sugarLevels{i}, 'units', 'normalized', 'position', [0.35+(i-1)*0.1 0.5 0.09 0.1], 'backgroundcolor', 'white', 'foregroundcolor', '#FF5F1F', 'fontsize', 10, 'fontname', 'Calibri', 'callback', {@updateButton}, 'fontweight', 'bold');
end

% Display user prompt and check for resource levels
machineData.userPrompt = uicontrol('parent', miniWindow, 'style', 'text', 'string', sprintf('Please insert €%.2f.', machineData.coffeePrices(coffeeIndex)), 'units', 'normalized', 'position', [0.4 0.32 0.5 0.15], 'backgroundcolor', backgroundColor, 'foregroundcolor', coffeeTextColor, 'fontsize', 12, 'fontname', 'Calibri', 'horizontalalignment', 'center', 'fontweight', 'bold');
if waterLevel < 200
set(machineData.userPrompt, 'string', 'Not enough water in the machine.');
set(machineData.insertMoneyButtons, 'enable', 'off');
set(machineData.collectChange, 'enable', 'off');
set(machineData.collectCoffee, 'enable', 'off');
elseif coffeeBeans < 15
set(machineData.userPrompt, 'string', 'Not enough coffee beans in the machine.');
set(machineData.insertMoneyButtons, 'enable', 'off');
set(machineData.collectChange, 'enable', 'off');
set(machineData.collectCoffee, 'enable', 'off');
end

guidata(mainFrame, machineData);
end

# Play coin slot audio
function playCoinSlotAudio()
persistent player;
if isempty(player) || ~isplaying(player)
[y, fs] = audioread('./Sounds/02_Coin.wav');
player = audioplayer(y, fs);
play(player);
end
end

function insertMoneyCallback(hObject, eventdata, amount, coffeeIndex, mainFrame, miniWindow)
machineData = guidata(mainFrame);
playCoinSlotAudio();

if ~isfield(machineData, 'totalInserted')
machineData.totalInserted = 0;
end

global machineBalance;

% Track how much money is inserted
machineData.totalInserted = machineData.totalInserted + amount;
machineBalance = machineBalance + amount;
totalInsertedText = uicontrol('parent', miniWindow, 'style', 'text', 'string', 'Money Inserted:', 'units', 'normalized', 'position', [0.32 0.25 0.175 0.1], 'fontsize', 11, 'fontname', 'Calibri', 'foregroundcolor', '#000000', 'backgroundcolor', '#FFFAF0', 'horizontalalignment', 'left', 'fontweight', 'bold');
totalInsertedAmount = uicontrol('parent', miniWindow, 'style', 'text', 'string', sprintf('€%.2f', machineData.totalInserted), 'units', 'normalized', 'position', [0.49 0.25 0.15 0.1], 'foregroundcolor', '#FF5F1F', 'fontsize', 11, 'fontname', 'Calibri', 'foregroundcolor', '#FF5F1F', 'backgroundcolor', '#FFFAF0', 'horizontalalignment', 'left', 'fontweight', 'bold');

% Calculate change
remainingAmount = machineData.coffeePrices(coffeeIndex) - machineData.totalInserted;
if remainingAmount > 0
set(machineData.userPrompt, 'string', sprintf('Please insert €%.2f more.', abs(remainingAmount)));
machineData.coffeePaid = 0;
else
change = abs(remainingAmount);

% Check if there's enough balance for change
if machineBalance < change
set(machineData.userPrompt, 'string', 'Insufficient machine balance to provide change.');
else
machineBalance = machineBalance - change;
set(machineData.userPrompt, 'string', sprintf('Brewing %s. Change: €%.2f.', machineData.coffeeTypes{coffeeIndex}, change));
machineData.coffeePaid = 1;
machineData.hasChange = 1;

end
end

set(machineData.collectCoffee, 'enable', 'off');
guidata(mainFrame, machineData);
end


% Playing brewing sound
function playBrewingAudio()
persistent player;
if isempty(player) || ~isplaying(player)
[y, fs] = audioread('./Sounds/01_Brewing.wav');
player = audioplayer(y, fs);
play(player);
end
end

function brewAndCollectChange(hObject, eventdata, coffeeIndex, mainFrame, miniWindow)
machineData = guidata(mainFrame);
machineData.coffeePaid = 1;
machineData.hasChange = 1;

% If payment is complete and change available
if machineData.coffeePaid == 1 && machineData.hasChange == 1
set(machineData.insertMoneyButtons, 'enable', 'off');
set(machineData.collectChange, 'enable', 'off');
set(machineData.userPrompt, 'string', sprintf('Your coffee is being made. Please wait...'));

sandClockImage = imread('./BrewVisuals/sandClock.png');
sandClockImageAxes = axes('parent', miniWindow, 'units', 'normalized', 'position', [0.63 0.11 0.2 0.2], 'visible', 'off');
imshow(sandClockImage, 'parent', sandClockImageAxes);

playBrewingAudio();
pause(52);
delete(sandClockImageAxes);
set(machineData.userPrompt, 'string', sprintf('Your coffee is ready! Please collect it and enjoy!'));
set(machineData.collectCoffee, 'enable', 'on');
endif

guidata(mainFrame, machineData);
end

function collectCoffeeCallback(hObject, eventdata, mainFrame, miniWindow, actions)
machineData = guidata(mainFrame);

global totalCoffeeMade;
global machineBalance;
global waterLevel;
global coffeeBeans;

set(machineData.userPrompt, 'string', sprintf('Thank you! Aborting in 10 seconds...'));
set(machineData.collectCoffee, 'enable', 'off');

% Updates inventory and balance
filePath = fullfile('C:', 'Users', 'durop', 'Desktop', 'coffeeMachineSimulation', 'm_inv.txt');
fid = fopen(filePath, 'w+');
totalCoffeeMade = totalCoffeeMade + 1;
fprintf(fid, 'Total Coffee Made: %d\n', totalCoffeeMade);
fprintf(fid, 'Machine Balance: %d\n', machineBalance);
waterUsage = 200;
coffeeUsage = 15;
waterLevel = waterLevel - waterUsage;
coffeeBeans = coffeeBeans - coffeeUsage;
fprintf(fid, 'Water Level: %d\n', waterLevel);
fprintf(fid, 'Coffee Beans: %d\n', coffeeBeans);
fclose(fid);

% Close mini window and delete menubar
pause(10);
delete(miniWindow);
delete(actions);
set(actions, 'enable', 'off');

guidata(mainFrame, machineData);
end

% Manages the visual appearance and selection state of buttons
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
