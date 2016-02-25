function [validx,validy,validz]=automate_image3(grid_x,grid_y,grid_z,filenamelist,validx,validy,validz)

% Code to start actual volumetric image correlation
% automate_image function was originally programmed by Chris and Rob
% This was modified by Ryan to create automate_image3

% The automation function is the central function and processes all markers and 
% images by the use of the matlab function cpcorr.m. 
% Therefore the Current directory in matlab has to be the folder where 
%  automate_image.m finds the filenamelist.mat, grid_x.dat and grid_y.dat as well 
% as the images specified in filenamelist.mat. Just type automate_image; and 
% press ENTER at the command line of matlab. 
% At first, automate_image.m will open the first image in the filenamelist.mat and 
% plot the grid as green crosses on top. The next step will need some time since 
% all markers in that image have to be processed for the first image. After correlating 
% image one and two the new raster positions will be plotted as red crosses. On top 
% of the image and the green crosses. The next dialog will ask you if you want to 
% continue with this correlation or cancel. If you press continue, automate_image.m 
% will process all images in the filenamelist.mat. The time it will take to process 
% all images will be plotted on the figure but can easily be estimated by knowing the 
% raster point processing speed (see processing speed). 
% Depending on the number of images and markers you are tracking, this process 
% can take between seconds and days. For 100 images and 200 markers a decent 
% computer should need 200 seconds. To get a better resolution you can always 
% run jobs overnight (e.g. 6000 markers in 1000 images) with higher resolutions. 
% Keep in mind that CORRSIZE which you changed in cpcorr.m will limit your 
% resolution. If you chose to use the 15 pixel as suggested a marker distance of 
% 30 pixel will lead to a full cover of the strain field. Choosing smaller marker 
% distances will lead to an interpolation since two neighboring markers share 
% pixels. Nevertheless a higher marker density can reduce the noise of the strain field.
% When all images are processed, automate_image will write the files validx.mat, 
% validy.mat, validx.txt and validy.txt. The text files are meant to store the result in a 
% format which can be accessed by other programs also in the future.

 
% exist('grid_x')
% exist('grid_y')
% exist('filenamelist')
% exist('validx')
% exist('validy')

% Load necessary files
if exist('grid_x')==0
    load('grid_x.dat')              % file with x position, created by grid_generator.m
end
if exist('grid_y')==0
    load('grid_y.dat')              % file with y position, created by grid_generator.m
end
if exist('grid_z')==0               
    load('grid_z.dat')              % file with z position, created by grid_generator.m
end
if exist('filenamelist')==0
    load('filenamelist')            % file with the list of filenames to be processed
end
resume=0;
if exist('validx')==1
    if exist('validy')==1
        if exist('validz')==1
        resume=1;
        [Rasternum current_z_stack]=size(validx);
        end
    end
end

% Prompt user for number of images in z-stack
prompt = {'Enter number of images in z-stack:'};
dlg_title = 'Input for volume assembly';
num_lines= 1;
def     = {'60'};
options.Resize='on';
options.WindowStyle='normal';
answer = inputdlg(prompt,dlg_title,num_lines,def,options);
z_stack_num = str2num(cell2mat(answer(1,1)));

z_stack_end = floor(length(filenamelist)/z_stack_num);

% Initialize variables
input_points_x=grid_x;
base_points_x=grid_x;

input_points_y=grid_y;
base_points_y=grid_y;

input_points_z=grid_z;
base_points_z=grid_z;

if resume==1
    input_points_x=validx(:,current_z_stack);
    input_points_y=validy(:,current_z_stack);
    input_points_z=validz(:,current_z_stack);
    inputpoints=1;
end

% initialize first volume
volume_one = assemble_volume(1,filenamelist);
% assemble current volume

[row,col,z_array]=size(base_points_x);      % this will determine the number of rasterpoints we have to run through
% [r,c]=size(filenamelist);                   % this will determine the number of images we have to loop through


% Open new figure so previous ones (if open) are not overwritten
%imshow(filenamelist(1,:))           % show the first image
%title('Initial Grid For Image Correlation (Note green crosses)')        % put a title
%hold on
plot3(grid_x,grid_y,grid_z,'g+')            % plot the grid onto the image
%hold off

% Start image correlation using cpcorr3.m
g = waitbar(0,sprintf('Processing images'));        % initialize the waitbar
set(g,'Position',[275,50,275,50])                               % set the position of the waitbar [left bottom width height]
z_stack_start=2;

if resume==1
    z_stack_start=current_z_stack+1;
end

for current_z_stack=z_stack_start:z_stack_end               % run through all volumes
    
    
    tic             % start the timer
    base = volume_one;            % read in the base image ( which is always  image number one. You might want to change that to improve correlation results in case the light conditions are changing during the experiment
    input = assemble_volume(current_z_stack,filenamelist);       % read in the image which has to be correlated
    
    input_points_for(:,1)=reshape(input_points_x,[],1);         % we reshape the input points to one row of values since this is the shape cpcorr will accept
    input_points_for(:,2)=reshape(input_points_y,[],1);
    input_points_for(:,3)=reshape(input_points_z,[],1);
    base_points_for(:,1)=reshape(base_points_x,[],1);
    base_points_for(:,2)=reshape(base_points_y,[],1);
    base_points_for(:,3)=reshape(base_points_z,[],1);
    input_correl(:,:,:)=cpcorr3(input_points_for, base_points_for, input, base);           % here we go and give all the markers and images to process to cpcorr.m which ic a function provided by the matlab image processing toolbox
    input_correl_x=input_correl(:,1);                                       % the results we get from cpcorr3 for the x-direction
    input_correl_y=input_correl(:,2);                                       % the results we get from cpcorr3 for the y-direction
    input_correl_z=input_correl(:,3);                                       % the results we get from cpcorr3 for the z-direction
    
    
    validx(:,current_z_stack)=input_correl_x;                                                     % lets save the data
    savelinex=input_correl_x';
    dlmwrite('resultsimcorrx.txt', savelinex , 'delimiter', '\t', '-append');       % Here we save the result from each image; if you are desperately want to run this function with e.g. matlab 6.5 then you should comment this line out. If you do that the data will be saved at the end of the correlation step - good luck ;-)
    
    validy(:,current_z_stack)=input_correl_y;
    saveliney=input_correl_y';
    dlmwrite('resultsimcorry.txt', saveliney , 'delimiter', '\t', '-append');
    
    validz(:,current_z_stack)=input_correl_z;
    savelinez=input_correl_z';
    dlmwrite('resultsimcorrz.txt', savelinez , 'delimiter', '\t', '-append');
    
    waitbar(current_z_stack/(z_stack_end-1))                                                                        % update the waitbar
    
    % Update base and input points for cpcorr3.m
    base_points_x=grid_x;
    base_points_y=grid_y;
    base_points_z=grid_z;
    input_points_x=input_correl_x;
    input_points_y=input_correl_y;
    input_points_z=input_correl_z;
    
    % imshow(filenamelist(i+1,:))                     % update image
    % hold on
    plot3(grid_x,grid_y,grid_z,'g+')                                % plot start position of raster
    plot3(input_correl_x,input_correl_y,input_correl_z,'r+')        % plot actual postition of raster
    hold off
    drawnow
    time(current_z_stack)=toc;                                                 % take time
    estimatedtime=sum(time)/current_z_stack*(z_stack_end-1);            % estimate time to process
    title(['# Im.: ', num2str((z_stack_end-1)),'; Proc. Im. #: ', num2str((current_z_stack)),'; # Rasterp.:',num2str(row*col*z_array), '; Est. Time [s] ', num2str(round(estimatedtime)), ';  Elapsed Time [s] ', num2str(round(sum(time)))]);    % plot a title onto the image
    drawnow
    
end    

    function volume = assemble_volume(current_z_stack,filenamelist)
       %volume=zeros([size((imread(filenamelist(1,:))),1),size((imread(filenamelist(1,:))),2),z_stack_num]);
         k=1;
        for j = ((current_z_stack-1)*(z_stack_num)+1):(current_z_stack)*(z_stack_num)
            [xy_slice,map] = imread(filenamelist(j,:));
            volume(:,:,k) = [xy_slice(:,:,1)];
            k=k+1;
        end
    end

close(g)
close all

% save

save time.dat time -ascii -tabs
save validx.dat validx -ascii -tabs
save validy.dat validy -ascii -tabs
save validz.dat validz -ascii -tabs
end
