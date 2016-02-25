function [grid_x,grid_y,grid_z]=grid_generator3(FileNameBase,PathNameBase)

% grid_generator3 function was written by Ryan McCaffrey and based on the 2D code (grid_generator) written by Chris Eberl, Dan Gianola and Rob Thompson
% Code to generate the DVC analysis grid
% 

% The grid_generator function will help you create grids of markers. The
% dialog has different options allowing you to create a marker grid which is rectangular,
% circular, a line or two rectangels of a shape or contains only of two
% markers. After choosing one of the shapes you will be asked for the base
% image which is typically your first image. After opening that image you
% will be asked to click at the sites of interest and the markers will be
% plotted on top of your image. You can choose if you want to keep these
% markers or if you want to try again.
% It has to be noted that you can
% always generate your own marker positions. Therefore the marker position
% in pixel has to be saved as a text based format where the x-position is
% saved as grid_x.dat and the y-position saved as grid_y.dat.
%



% Prompt user for base image
if exist('FileNameBase')==0
[FileNameBase,PathNameBase] = uigetfile( ...
    {'*.bmp;*.tif;*.jpg;*.TIF;*.BMP;*.JPG','Image files (*.bmp,*.tif,*.jpg)';'*.*',  'All Files (*.*)'}, ...
    'Open base image for grid creation');

end
cd(PathNameBase)
im_grid = imread(FileNameBase);

[grid_x,grid_y,grid_z,FileNameBase,PathNameBase] = gridtypeselection(FileNameBase, PathNameBase, im_grid);

close all

%-------------------------------
%
% Decide which type of grid you want to create

function [grid_x,grid_y,grid_z,FileNameBase,PathNameBase] = gridtypeselection(FileNameBase, PathNameBase, im_grid)

hold off
imshow(im_grid,'truesize');

gridselection = menu(sprintf('Which type of grid do you want to use'),...
    'Rectangular','Cancel');

if gridselection==1
    [grid_x,grid_y,grid_z,FileNameBase,PathNameBase] = rect_grid(FileNameBase, PathNameBase, im_grid);
    return
end

if gridselection==2
    return;
end

%-------------------------------
%

function [grid_x,grid_y,grid_z,FileNameBase,PathNameBase] = rect_grid(FileNameBase, PathNameBase, im_grid);

title(sprintf('Define the region of interest.  Pick (single click) a point in the LOWER LEFT region of the gage section.\n  Do the same for a point in the UPPER RIGHT portion of the gage section.'))

[x(1,1),y(1,1)]=ginput(1);
hold on
plot(x(1,1),y(1,1),'+b')

[x(2,1),y(2,1)]=ginput(1);
hold on
plot(x(2,1),y(2,1),'+b')

drawnow

xmin = min(x);
xmax = max(x);
ymin = min(y);
ymax = max(y);

lowerline=[xmin ymin; xmax ymin];
upperline=[xmin ymax; xmax ymax];
leftline=[xmin ymin; xmin ymax];
rightline=[xmax ymin; xmax ymax];

plot(lowerline(:,1),lowerline(:,2),'-b')
plot(upperline(:,1),upperline(:,2),'-b')
plot(leftline(:,1),leftline(:,2),'-b')
plot(rightline(:,1),rightline(:,2),'-b')

% closereq

cd(PathNameBase)

% Prompt user for grid spacing/resolution
prompt = {'Enter horizontal (x) resolution for image analysis [pixels]:', ...
        'Enter vertical (y) resolution for image analysis [pixels]:', ...
        'Enter out of plane (z) resolution for image analysis [pixels]:', ...
        'Enter depth of grid [pixels]:';};
dlg_title = 'Input for grid creation';
num_lines= 1;
def     = {'50','50','5','60'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
xspacing = str2num(cell2mat(answer(1,1)));
yspacing = str2num(cell2mat(answer(2,1)));
zspacing = str2num(cell2mat(answer(3,1)));
zmax = str2num(cell2mat(answer(4,1)));

% Round xmin,xmax and ymin,ymax "up" based on selected spacing
numXelem = ceil((xmax-xmin)/xspacing)-1;
numYelem = ceil((ymax-ymin)/yspacing)-1;

xmin_new = (xmax+xmin)/2-((numXelem/2)*xspacing);
xmax_new = (xmax+xmin)/2+((numXelem/2)*xspacing);
ymin_new = (ymax+ymin)/2-((numYelem/2)*yspacing);
ymax_new = (ymax+ymin)/2+((numYelem/2)*yspacing);

% Create the analysis grid and show user
[x,y,z] = meshgrid(xmin_new:xspacing:xmax_new,ymin_new:yspacing:ymax_new,10:zspacing:zmax);
[rows columns z_array] = size(x);
imshow(FileNameBase)
title(['Selected grid has ',num2str(rows*columns*z_array), ' rasterpoints'])    % plot a title onto the image
hold on;

d=1;
for a=1:size((x),1)
    for b=1:size((x),2)
        for c=1:size((x),3)
x_index(d)=sub2ind(size(x),a,b,c);
d=d+1;
        end
    end
end

d=1;
for a=1:size((y),1)
    for b=1:size((y),2)
        for c=1:size((y),3)
y_index(d)=sub2ind(size(y),a,b,c);
d=d+1;
        end
    end
end

d=1;
for a=1:size((z),1)
    for b=1:size((z),2)
        for c=1:size((z),3)
z_index(d)=sub2ind(size(z),a,b,c);
d=d+1;
        end
    end
end

stem3(x,y,z,'+b')

grid_x=x(x_index)';
grid_y=y(y_index)';
grid_z=z(z_index)';

% Do you want to keep the grid?
confirmselection = menu(sprintf('Do you want to use this grid?'),...
    'Yes','No, try again','Go back to grid-type selection');

if confirmselection==1
    % Save settings and grid files in the image directory for visualization/plotting later
    save settings.dat xspacing yspacing zspacing xmin_new xmax_new ymin_new ymax_new zmax -ascii -tabs
    save grid_x.dat grid_x /ascii
    save grid_y.dat grid_y /ascii
    save grid_z.dat grid_z /ascii
    close all
    hold off
end

if confirmselection==2
    close all
    hold off
    imshow(im_grid,'truesize');
    rect_grid(FileNameBase, PathNameBase, im_grid);
end

if confirmselection==3
    close all
    hold off
    gridtypeselection(FileNameBase, PathNameBase, im_grid);
end
