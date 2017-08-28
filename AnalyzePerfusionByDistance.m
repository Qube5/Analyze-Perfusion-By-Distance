%% Header
%  Quentin Delepine

clc;        % clear window
clear all   % clear variables, etc. 
format short
format compact
delete(findall(0,'Type','figure'));

%% Settings
directory  = '../../Desktop/Other/SIMR/Perfusion Tests/';  % directory of folder desktop
interval1  = 5  ;   % pic every interval1 mins for first subset minutes
interval2  = 30 ;   % pic every interval2 mins after
subset     = 60 ;   % subset of time to take many pics
numCols    = 20 ;   % number of pixels to right of xpoint
numRows    = 20 ;   % number of pixels below ypoint
displayImg = [ ];   % [ 0 5 10 300 ] lists images to display 0:600 to display all
ratio      = 2/3;   % ratio usually 2/3 for my 13" laptop. Have scale error to know. Sometimes 1/2
z          = 100;   % constant interval between xpoints
invert     = 1  ;   % 1 is on, 0 is off, inverts colors so higher number is darker
remove     = 1  ;   % 1 is on, 0 is off, removes bad data
imageStack = 0  ;   % 1 is on, 0 is off, 1 stacks images, 0 distributes them
graphStack = 0  ;   % 1 is on, 0 is off, 1 stacks graphs, 0 distributes them
bestfit    = 0  ;   % 1 is on, 0 is off, 2 is bestfit only
graph      = 0  ;   % 1 is on, 0 is off, 1 is on, 0 is off
compGraph  = 1  ;   % Compiled Graph
save       = 0  ;   % 1 is on, 0 is off
dispRects  = 1  ;   % 1 is on, 0 is off
gauss      = 10 ;   % Gaussian Filter Level. 1 is off, 10 is nice
imgLoc     = 1  ; 
graphLoc   = 1  ;

%% Initialize variables
folders     = (dir(directory)); % list of files in folder
folders     = folders(ismember(arrayfun(@(x) x.name(1), folders),'0''1''2''3''4''5''6''7''8''9')); % only dates within folder
numFolders  = length(folders); % number of tests

startFolder = 1; % numFolders;
scrn        = get(groot,'ScreenSize'); % gets screen size to change fig position
insertShape = vision.ShapeInserter('Shape','Rectangles','BorderColor','Custom','CustomBorderColor', uint8([200 0 0]));

imgs = [ 0 5 10 15 25 30 50 60 90 120 ];
allData = zeros(1, numFolders);
linData = zeros(length(imgs), numFolders); 

%% Analyze images
% dates = { '7-08-16'}; % only some dates
for g = startFolder: numFolders
    date = folders(g).name;
%     if g>length(dates); break; end  % only some dates
%     date = dates{g};                % only some dates
    folder = [date '/Images/']; 
    long = 0;
    if strcmp(date,'6-21-16') % set xpoints and y for each test % trash 1
        x = 1240;
        cLoc = 1425;
        z = -abs(z);
        y = 150;
        sampleName = [ '10.% PEG 05.0% GelMA | ' date ];
    elseif strcmp(date,'6-23-16')
        x = 140;
        cLoc = 60;
        z = abs(z);
        y = 300;
        sampleName = [ '10.% PEG 05.0% GelMA | ' date ];
    elseif strcmp(date,'6-24-16')
        x = 250;
        cLoc = 80;
        z = abs(z);
        y = 150;
        sampleName = [ '10.% PEG 05.0% GelMA | ' date ];
    elseif strcmp(date,'6-28-16') % good
        x = 190;
        cLoc = 80;
        z = abs(z);
        y = 150;
        sampleName = [ '10.% PEG 07.5% GelMA | ' date ];
    elseif strcmp(date,'6-30-16') % trash 5
        long = 1;
        x = 1640;
        cLoc = 1450;
        z = abs(z);
        y = 100;
        sampleName = [ '10.% PEG 07.5% GelMA | ' date ];
    elseif strcmp(date,'7-01-16')
        x = 1140;
        cLoc = 1350;
        z = -abs(z);
        y = 150;
        sampleName = [ '10.% PEG 07.5% GelMA | ' date ];
        date = '7-1-16';
    elseif strcmp(date,'7-06-16')
        long = 1;
        x = 1040;
        cLoc = 1425;
        z = -abs(z);
        y = 100;
        sampleName = [ '10.% PEG 07.5% GelMA | ' date ];
        date = '7-6-16';
    elseif strcmp(date,'7-08-16')
        x = 380;
        cLoc = 250;
        z = abs(z);
        y = 100;
        sampleName = [ '10.% PEG 10.0% GelMA | ' date ];
        date = '7-8-16';
    elseif strcmp(date,'7-19-16')
        long = 1;
        x = 1820;
        cLoc = 1500;
        z = abs(z);
        y = 30;
        sampleName = [ '10.% PEG 10.0% GelMA | ' date ];
    elseif strcmp(date,'7-20-16')
        long = 1;
        x = 1940;
        cLoc = 1500;
        z = abs(z);
        y = 150;
        sampleName = [ '10.% PEG 10.0% GelMA | ' date ];    
    elseif strcmp(date,'7-23-16') % trash 11
        long = 1;
        x = 2000;
        cLoc = 1800;
        z = abs(z);
        y = 150;
        sampleName = [ '7.5% PEG 05.0% GelMA | ' date ];    
    elseif strcmp(date,'7-26-16') % trash 12
        long = 1;
        x = 1980;
        cLoc = 1450;
        z = abs(z);
        y = 75;
        sampleName = [ '10.% PEG 05.0% GelMA | ' date ];
	elseif strcmp(date,'7-27-16')
        long = 1;
        x = 2080;
        cLoc = 1600;
        z = abs(z);
        y = 75;
        sampleName = [ '10.% PEG 05.0% GelMA | ' date ];
    else
        numFolders = numFolders - 1; 
%         slopes     = repmat({0}, numFolders, 2);
%         yInts      = zeros(numFolders, 1);
        continue
    end
    
    %% Initialize variables
    
    numPoints = 6;
%     xpoints = linspace(x+z,x+z*numPoints,numPoints);
    xpoints = linspace(x,x+z*(numPoints-1),numPoints);

    disp(sampleName);
    
%     len = (dir([directory folder])); % list of files in folder
%     len = len(arrayfun(@(x) x.name(1), len) ~= '.'); % get rid of hidden files
%     len = length(len); % number of pictures

    len = length(imgs); % if only some images
    num = 0; % indexes the timestamps of images
    
    %% Collect Image Data
    legItems = repmat({' '}, 1, length(imgs));
    data = zeros(length(imgs), numPoints);
    for i = 1 : len
        num = imgs(i);
        try
            img = imread([directory folder '/Perfusion-' date '-t-' int2str(num) '.jpg']);
            if long == 1
                img = imresize(img,2);
                ratio = 1/3;
            else
                ratio = 2/3;
            end
            legItems{i} = ['t=' num2str(num)];
        catch
            [a,~] = size(data);
            data(i:a,:)=[];
            legItems(i:a)=[];
            continue
        end
        img = imgaussfilt(img,gauss); % applies Gaussian filter. 10 is nice
        data(i,1) = num;
        
        if ismember(num,displayImg) == 1      % display selected images and
            img2 = imresize(img,ratio);
            if dispRects == 1
                img2 = insertMarker(img2,[x*ratio (y(1)+numRows/2)*ratio],'*','color','blue','size',5);
            end
        end
        for j = 2 : numPoints+1               % for each section...
            if ismember(num,displayImg) == 1  % display tested sections
                if dispRects == 1
                    dim = [xpoints(j-1) y numCols numRows ];
                	rectangle = int32(dim*ratio);
                    img2 = step(insertShape, img2, rectangle);
                end
            end
            RVals = zeros(1,numRows*numCols); % keep track of RedVals
            if num == 120 && j == 4
                RVals = zeros(1,numRows*numCols); % keep track of cval
                if dispRects == 1 && ismember(num,displayImg) == 1
                    img2 = insertMarker(img2,[cLoc*ratio (y(1)+numRows/2)*ratio],'o','color','green','size',5);
                end
            end
            for k = 0 : numRows               % for each column...
                for l = 0 : numCols           % for each row...
%                     RVals(numRows*k+l+1) =      img ( y + k, xpoints(j-1) + l, 1   ); % just Red
%                     RVals(numRows*k+l+1) =      img ( y + k, xpoints(j-1) + l, 2   ); % just Green
%                     RVals(numRows*k+l+1) =      img ( y + k, xpoints(j-1) + l, 3   ); % just Blue
                    RVals(numRows*k+l+1) = mean(img ( y + k, xpoints(j-1) + l, 1:3)); % average RGB % pretty good
%                     RVals(numRows*k+l+1) = mean(img ( y + k, xpoints(j-1) + l, 1:2)); % average RG_
%                     RVals(numRows*k+l+1) = mean(img ( y + k, xpoints(j-1) + l, 2:3)); % average _GB
                    if j == 4
                    	cval = mean(img ( y + k, cLoc + l, 1:3)); % average RGB
                    end
                end
            end
            data(i,j) = round(mean(RVals));
            if num == 120 && j == 1
                adjData = round(mean(cval)) - data(i,j);
                allData(g) = 255-adjData;
            end
            if j==4
                adjData = round(mean(cval)) - data(i,j);
                linData(i,g) = 255-adjData;
                linData(i,g) = 255-data(i,j);
            end
        end
        if ismember(num,displayImg) == 1 % Position images in eighth of screen
            f = figure('Name', [sampleName ' | ' int2str(num) ' minutes']);
            f.Color    = [.8,.8,.8]; % Gray
            imshow(img2);
            if imageStack == 0 
                if     imgLoc == 1; f.Position = [1         scrn(4)*3/4-50 scrn(3)/2 scrn(4)*2/10];
                elseif imgLoc == 2; f.Position = [scrn(3)/2 scrn(4)*3/4-50 scrn(3)/2 scrn(4)*2/10];
                elseif imgLoc == 3; f.Position = [1         scrn(4)/2-45   scrn(3)/2 scrn(4)*2/10];
                elseif imgLoc == 4; f.Position = [scrn(3)/2 scrn(4)/2-45   scrn(3)/2 scrn(4)*2/10];
                elseif imgLoc == 5; f.Position = [1         scrn(4)/4-40   scrn(3)/2 scrn(4)*2/10];
                elseif imgLoc == 6; f.Position = [scrn(3)/2 scrn(4)/4-40   scrn(3)/2 scrn(4)*2/10]; 
                elseif imgLoc == 7; f.Position = [1         1-40           scrn(3)/2 scrn(4)*2/10];
                elseif imgLoc == 8; f.Position = [scrn(3)/2 1-40           scrn(3)/2 scrn(4)*2/10]; imgLoc = 0;
                end
                imgLoc = imgLoc+1;
            end
        end

        fprintf([ int2str(num) ' ']);   % progress update of each image. 
    end
    
    %% Adjust Data
    [a,~] = size(data);
    if invert == 1 % Invert data (darker red = higher value)
        for i = 1 : a                     % for each image...
            for j = 2 : length(xpoints)+1 % for each point...
                data(i,j) = 255-data(i,j); % invert
            end
        end
    end
    
    %% Graph
    time2 = data(:,1);

    data2 = rot90(data,3);
    data2 = fliplr(data2);
    
    ypoints = data2(2:numPoints+1,:);
    if xpoints(2) < xpoints(1); 
        xpoints = fliplr(xpoints);
        ypoints = fliplr(ypoints);
    end
    xpoints = xpoints - xpoints(1);
%     linData(:,g) = data(:,3); % takes second picture
    
    title2 = [sampleName ' | Diffusion at different points (' int2str(numCols) 'x' int2str(numRows) ')'];
    if graph == 1
        v = figure('Name', title2);
        v.Color = [.8,.8,.8]; % Gray
        if graphStack == 0 % Position graphs in eighth of screen
%             if     graphLoc == 1; v.Position = [1         scrn(4)*3/4-50 scrn(3)/2 scrn(4)*2/10];
%             elseif graphLoc == 2; v.Position = [scrn(3)/2 scrn(4)*3/4-50 scrn(3)/2 scrn(4)*2/10];
%             elseif graphLoc == 3; v.Position = [1         scrn(4)/2-45   scrn(3)/2 scrn(4)*2/10];
%             elseif graphLoc == 4; v.Position = [scrn(3)/2 scrn(4)/2-45   scrn(3)/2 scrn(4)*2/10];
%             elseif graphLoc == 5; v.Position = [1         scrn(4)/4-40   scrn(3)/2 scrn(4)*2/10];
%             elseif graphLoc == 6; v.Position = [scrn(3)/2 scrn(4)/4-40   scrn(3)/2 scrn(4)*2/10]; 
%             elseif graphLoc == 7; v.Position = [1         1-40           scrn(3)/2 scrn(4)*2/10];
%             elseif graphLoc == 8; v.Position = [scrn(3)/2 1-40           scrn(3)/2 scrn(4)*2/10]; graphLoc = 0;
%             end
%             graphLoc = graphLoc+1;
            if     imgLoc == 1; v.Position = [1         scrn(4)*3/4-50 scrn(3)/2 scrn(4)*2/10];
            elseif imgLoc == 2; v.Position = [scrn(3)/2 scrn(4)*3/4-50 scrn(3)/2 scrn(4)*2/10];
            elseif imgLoc == 3; v.Position = [1         scrn(4)/2-45   scrn(3)/2 scrn(4)*2/10];
            elseif imgLoc == 4; v.Position = [scrn(3)/2 scrn(4)/2-45   scrn(3)/2 scrn(4)*2/10];
            elseif imgLoc == 5; v.Position = [1         scrn(4)/4-40   scrn(3)/2 scrn(4)*2/10];
            elseif imgLoc == 6; v.Position = [scrn(3)/2 scrn(4)/4-40   scrn(3)/2 scrn(4)*2/10]; 
            elseif imgLoc == 7; v.Position = [1         1-40           scrn(3)/2 scrn(4)*2/10];
            elseif imgLoc == 8; v.Position = [scrn(3)/2 1-40           scrn(3)/2 scrn(4)*2/10]; imgLoc = 0;
            end
            imgLoc = imgLoc+1;        
        else
            v.Position = [1 1 scrn(3) scrn(4)*2/5];
        end
        if bestfit ~= 2 % Graph best fit lines only if == 2
%             plot(xpoints, ypoints/255, 'LineWidth', 2);
            plot(xpoints, ypoints/255,'-o', 'LineWidth', 2);
        end
    end
    
    if bestfit == 1 % Create best fit lines and calculate slope
        color = {[62 117 181]/255;[188 100 62]/255;[221 178 81]/255;[107 68 137]/255;[140 164 71]/255;[126 188 230]/255;[0 0 1]/255};
        for i = 1 : x % Create Best Fit Lines
            coeffs = polyfit(rot90(xpoints,3), ypoints(:,i), 1);
            if graph == 1
                legItems{i} = [legItems{i} ' slope: ' num2str(coeffs(1))]; % edit legend  
                fprintf(['\n' legItems{i}]);
                fittedX = linspace(min(xpoints), max(xpoints), 200); % Get fitted values
                fittedY = polyval(coeffs, fittedX);
                hold on; % Plot the fitted line
                plot(fittedX, fittedY, 'r-', 'LineWidth',1,'Color',color{i}); 
            end
        end
    end
    
    %% Graph details
    if graph == 1
        grid on;
        grid minor;
        title ( title2,                       'FontSize', 24);  % title
        xlabel('Distance (pixels)',           'FontSize', 20);	% x-axis label
        ylabel('Intensity'  ,                 'FontSize', 20);  % y-axis label
        legend( legItems, 'Location', 'best', 'FontSize', 20);  % legend
        % set axes
        xStep = 50;
        yStep = .2;
        axis([0 xpoints(length(xpoints)) 0 1]);
        axis1 = gca;
        Xax = get(axis1, 'XLim');
        Yax = get(axis1, 'YLim');
        NumXTicks = ( ( Xax(2) - Xax(1) ) / xStep ) + 1;
        NumYTicks = ( ( Yax(2) - Yax(1) ) / yStep ) + 1;
        set(axis1, 'XTick', linspace(Xax(1), Xax(2), NumXTicks));
        set(axis1, 'YTick', linspace(Yax(1), Yax(2), NumYTicks));
    end
    fprintf('\n------------------------------\n');
    
end

%% Compare Tests
if compGraph == 1

    linData = linData(:,[ 2 3 13 4 6 7 8 9 10 ]);
    avr = ceil(mean(linData(1,:)));
    for i = 1 : 9
        linData(:,i) = linData(:,i)-linData(1,i)+avr;
    end
    legItems = { '   5% GelMA' '   5% GelMA' '   5% GelMA' '7.5% GelMA' '7.5% GelMA' '7.5% GelMA' ' 10% GelMA' ' 10% GelMA' ' 10% GelMA' };
    
    s = figure('Name', 'd=200 lines');
    grid on;
    s.Color = [.8,.8,.8]; % Gray
    s.Position = [1 1 scrn(3) scrn(4)*2/5];
    plot(time2, linData/255,'-o', 'LineWidth', 2);
    xlabel('Time (min)',                  'FontSize', 20);	% x-axis label
    ylabel('Intensity'  ,                 'FontSize', 20);  % y-axis label
    legend( legItems, 'Location', 'best', 'FontSize', 20);  % legend

    
	legItems = { '   5% GelMA' '7.5% GelMA' ' 10% GelMA' };

    avrLinData = zeros(length(imgs),2);

    [ii,~,v] = find(linData(:,1:3));
    avrLinData(:,1) = accumarray(ii,v,[],@mean);
    [ii,~,v] = find(linData(:,4:6));
    avrLinData(:,2) = accumarray(ii,v,[],@mean);
    [ii,~,v] = find(linData(:,7:9));
    avrLinData(:,3) = accumarray(ii,v,[],@mean);
    
%     disp(avrLinData);
    r = figure('Name', 'd=200 avr lines');
    r.Color = [.8,.8,.8]; % Gray
    r.Position = [1 1 scrn(3) scrn(4)*2/5];
    axis1 = gca;
    axis1.ColorOrderIndex=4;
    hold on
    plot(time2, avrLinData/255, 'LineWidth', 3);
 
    title2 = 'Average GelMA Diffusion of Groups';
    grid on;    
    grid minor;
    title ( title2,                       'FontSize', 24);  % title
    xlabel('Time (min)',                  'FontSize', 20);	% x-axis label
    ylabel('Intensity'  ,                 'FontSize', 20);  % y-axis label
    legend( legItems, 'Location', 'best', 'FontSize', 20);  % legend
    grid on;
    box on;
    xStep = 10;
    yStep = .2;    
    axis([0 imgs(length(imgs)) 0 1]);
    axis1 = gca;
    Xax = get(axis1, 'XLim');
    Yax = get(axis1, 'YLim');
    NumXTicks = ( ( Xax(2) - Xax(1) ) / xStep ) + 1;
    NumYTicks = ( ( Yax(2) - Yax(1) ) / yStep ) + 1;
    set(axis1, 'XTick', linspace(Xax(1), Xax(2), NumXTicks));
    set(axis1, 'YTick', linspace(Yax(1), Yax(2), NumYTicks));
    set(gca,'fontsize',20)
end

%% Done

fprintf('\nDone\n')


