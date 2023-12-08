function coffeeVendingMachine()

% Clear commands
clear all;
close all;
clc;

mainFrame = initGUI();

  pause(1);
  data = guidata(mainFrame);
  % This is to save the data structure back to the figure
  guidata(mainFrame, data);

  waitfor(mainFrame);
end

function mainFrame = initGUI()
data.coffeeTypes = {'Espresso', 'Cappuccino', 'Americano', 'Latte', 'Mocha', 'Macchiato', 'Flat White', 'Cortado', 'Hot Milk', 'Hot Chocolate'};
data.coffeePrices = [1.50, 2.00, 2.50, 1.75, 2.25, 2.00, 2.25, 2.00, 2.75, 1.75];
data.cupSize = {'small', 'medium', 'large'};
data.machineStatus = 'idle';
data.coffeePaid = 0;
data.hasChange = 0;
data.enableButtons = 0;
data.enableInteractions = 0;
backgroundColor = hex2dec({'FF','FA','F0'})'/255;
titleBackgroundColor = hex2dec({'FF','5F','1F'})'/255;
buttonColor = hex2dec({'5A','5A','5A'})'/255;
titleTextColor = hex2dec({'FF','FF','FF'})'/255;
coffeeTextColor = hex2dec({'00','00','00'})'/255;
data.extraMilk = 0;
data.extraSugar = 0;
data.coffeeFinished = 0;

screen_size = get(0, "screensize");
fig_size = [1000, 700];
% Position for the figure to be centered
mainFramePos =[(screen_size(3)-fig_size(1))/2, (screen_size(4)-fig_size(2))/2, fig_size(1), fig_size(2)];

% GUI frames
mainFrame = figure('name', 'Coffee Vending Machine Simulation', 'NumberTitle', 'off', 'toolbar', 'none', 'resize', 'off', 'position', mainFramePos);
titleFrame = uipanel('parent', mainFrame, 'backgroundcolor', titleBackgroundColor, 'position', [0 0.9 1 0.1]);
coffeeSelectionFrame = uipanel('parent', mainFrame, 'backgroundcolor', backgroundColor, 'position', [0 0 1 0.9]);
titleText = uicontrol('parent', titleFrame, 'units', 'normalized', 'style', 'text', 'string', 'Coffee Vending Machine', 'fontsize', 22, 'fontname', 'Nunito', 'backgroundcolor', titleBackgroundColor, 'foregroundcolor', titleTextColor, 'position', [0.25 0 0.5 1], 'horizontalalignment', 'center');
clockText = uicontrol('parent', titleFrame, 'units', 'normalized', 'style', 'text', 'string', datestr(now, 'HH:MM'), 'fontsize', 16, 'fontname', 'Nunito', 'backgroundcolor', titleBackgroundColor, 'foregroundcolor', titleTextColor, 'position', [0.8 0 0.25 1], 'horizontalalignment', 'center');

mainFrame = gcf;

spacing = 0.03;
panelWidth = (1 - 6 * spacing)/5;
panelHeight = (1 - 5 * spacing)/2;

% Calculation of coffee panel position
for i = 1:length(data.coffeeTypes)
row = floor((i-1)/5); % Row of the panel (0 for first, 1 for second)
col = mod(i - 1, 5); % Column of the panel
panelX = spacing + col * (panelWidth + spacing); % X position of the panel
panelY = 1 - spacing - (row + 1) * (panelHeight + spacing); % Y position of the panel
coffeePanel = uipanel('parent', coffeeSelectionFrame, 'backgroundcolor', 'white', 'position', [panelX panelY panelWidth panelHeight], 'bordertype', 'etchedin');

% Used to load and display the images
    coffeeImage = imread(strcat('./Coffee Images/', data.coffeeTypes{i}, '.png'));
    uicontrol('parent', coffeePanel, 'style', 'pushbutton', 'cdata', coffeeImage, 'units', 'normalized', 'position', [0 0.3 1 0.7]);

    % Coffee name display
    uicontrol('parent', coffeePanel, 'style', 'text', 'string', data.coffeeTypes{i}, 'fontsize', 11, 'fontname', 'Montserrat', 'backgroundcolor', 'white', 'foregroundcolor', coffeeTextColor, 'units', 'normalized', 'position', [0.05 0.2 0.8 0.1], 'horizontalalignment', 'left');

    % Coffee price display
    uicontrol('parent', coffeePanel, 'style', 'text', 'string', ['$ ' num2str(data.coffeePrices(i))], 'fontsize', 11, 'fontname', 'Montserrat', 'backgroundcolor', 'white', 'foregroundcolor', '#FF7F7F', 'units', 'normalized', 'position', [0.1 0.05 0.8 0.1], 'horizontalalignment', 'right');
endfor

while ishandle(mainFrame) && ishandle(clockText)
    set(clockText, 'string', datestr(now, 'HH:MM'));
    pause(1);
    end
end










