function [xyzinput] = cpcorr3(varargin)
% INPUT_POINTS = CPCORR(INPUT_POINTS_IN,BASE_POINTS_IN,INPUT,BASE) uses
%   normalized cross-correlation to adjust each pair of control points
%   specified in INPUT_POINTS_IN and BASE_POINTS_IN.
% 
%   This version of cpcorr as been modified to accept three-dimensional
%   inputs for cross-correlation of volumes.  This version currently 
%   calls the function normxcorr3 in place of normxcorr2 and must be in
%   the current directory or in a folder in the path.
%
%   CPCORR Tune control point locations using cross-correlation.
%   INPUT_POINTS_IN must be an M-by-3 double matrix containing the
%   coordinates of control points in the input image.  BASE_POINTS_IN is
%   an M-by-3 double matrix containing the coordinates of control points
%   in the base image.
%
%   CPCORR3 returns the adjusted control points in INPUT_POINTS, a double
%   matrix the same size as INPUT_POINTS_IN.  If CPCORR cannot correlate a
%   pairs of control points, INPUT_POINTS will contain the same coordinates
%   as INPUT_POINTS_IN for that pair.
%
%   CPCORR will only move the position of a control point by up to 4
%   pixels.  This function is not yet capable to calculating correlation
%   with sub-pixel accuracy.
% 
%   ***********Adjusted coordinates are accurate up to one tenth of a
%   pixel.  CPCORR is designed to get subpixel accuracy from the image
%   content and coarse control point selection.***********************
%
%   Example from cpcorr
%   --------
%   This example uses CPCORR to fine-tune control points selected in an
%   image.  Note the difference in the values of the INPUT_POINTS matrix
%   and the INPUT_POINTS_ADJ matrix.
%
%       input = imread('onion.png');
%       base = imread('peppers.png');
%       input_points = [127 93; 74 59];
%       base_points = [323 195; 269 161];
%       input_points_adj = cpcorr(input_points,base_points,...
%                                 input(:,:,1),base(:,:,1))
%
%   Note that the INPUT and BASE images must have the same scale for
%   CPCORR to be effective.
%
%   CPCORR cannot adjust a point if any of the following occur:
%     - points are too near the edge of either image
%     - regions of images around points contain Inf or NaN
%     - region around a point in input image has zero standard deviation
%     - regions of images around points are poorly correlated
%
%   Class Support
%   -------------
%   The images can be numeric and must contain finite values. The input
%   control point pairs are double.
%
%   Adapted from MathWorks, Inc. COpyright 1993-2004 The MathWorks, Inc.
%   Written by Peter Matthews, University of Pennsylvania
%   Edited June 26th, 2010
%
%   Input-output specs
%   ------------------
%   INPUT_POINTS_IN: M-by-3 double matrix 
%              INPUT_POINTS_IN(:)>=0.5
%              INPUT_POINTS_IN(:,1)<=size(INPUT,2)+0.5
%              INPUT_POINTS_IN(:,2)<=size(INPUT,1)+0.5
%
%   BASE_POINTS_IN: M-by-3 double matrix 
%              BASE_POINTS_IN(:)>=0.5
%              BASE_POINTS_IN(:,1)<=size(BASE,2)+0.5
%              BASE_POINTS_IN(:,2)<=size(BASE,1)+0.5
%
%   INPUT:   3-D, real, full matrix
%            logical, uint8, uint16, or double
%            must be finite (no NaNs, no Infs inside regions being correlated)
%
%   BASE:    3-D, real, full matrix
%            logical, uint8, uint16, or double
%            must be finite (no NaNs, no Infs inside regions being correlated)

[input_cp,base_cp,input,base] = ParseInputs(varargin{:});

CORRSIZE = 8;

% get all rectangle coordinates
cubes_input = calc_cubes(input_cp,CORRSIZE,input);
cubes_base = calc_cubes(base_cp,2*CORRSIZE,base);

ncp = size(input_cp,1);

xyzinput = input_cp; % initialize adjusted control points matrix

for icp = 1:ncp
    
    %Commented out code for v 1.0 - to be adapted
    if isequal(cubes_input(icp,4:6),[0 0 0]) || ...
       isequal(cubes_base(icp,4:6),[0 0 0]) 
        % near edge, unable to adjust
        continue
    end
    
    
    %Call crop_volume which will loop the imcrop through the stack depth
%     sub_input = imcrop(input,rects_input(icp,:));
%     sub_base = imcrop(base,rects_base(icp,:));    


    sub_input = crop_volume(input,cubes_input(icp,:));
    sub_base = crop_volume(base,cubes_base(icp,:));
    
    inputsize = size(sub_input);
    
    % make sure finite
    if any(~isfinite(sub_input(:))) || any(~isfinite(sub_base(:)))
        % NaN or Inf, unable to adjust
        continue
    end

    % check that template rectangle sub_input has nonzero std
    if std(sub_input(:))==0
        % zero standard deviation of template image, unable to adjust
        continue
    end


    norm_cross_corr = normxcorr3(sub_input,sub_base);    

    %get subpixel resolution from cross correlation
    subpixel = true;
    [xpeak, ypeak, zpeak, max_cc] = findpeak3(norm_cross_corr,subpixel);


    %The following code has been copied from findpeak, which currently will
    %not accept 3-dim matrix
    % get absolute peak pixel
%     [max_cc, imax] = max(abs(norm_cross_corr(:)));
%     [ypeak, xpeak, zpeak] = ind2sub(size(norm_cross_corr),imax(1));
%     
% 
% Alternative interpolation method

%     max_location = [xpeak, ypeak, zpeak];
% 
%     array_dim=size(norm_cross_corr);
%     x=1:array_dim(1);
%     y=1:array_dim(2);
%     z=1:array_dim(3);
%     
%     x1_limit=1;
%     y1_limit=1;
%     z1_limit=1;
%     while x1_limit&&y1_limit&&z1_limit > 0.001
%         for x1=max_location(1)-x1_limit:x1_limit:max_location(1)+x1_limit
%             for y1=max_location(2)-y1_limit:y1_limit:max_location(2)+y1_limit
%                 for z1=max_location(3)-z1_limit:z1_limit:max_location(3)+z1_limit
%                     if interp3(x,y,z,norm_cross_corr,x1,y1,z1,'*cubic') > max_cc
%                         max_cc = interp3(x,y,z,norm_cross_corr,x1,y1,z1,'*cubic');
%                         max_location = [x1 y1 z1];
%                     end
%                 end
%             end
%         end
%         x1_limit=x1_limit*0.5;
%         y1_limit=y1_limit*0.5;
%         z1_limit=z1_limit*0.5;
%     end
%     
%     xpeak=max_location(1);
%     ypeak=max_location(2);
%     zpeak=max_location(3);
    
    
    
    % eliminate any poor correlations
    THRESHOLD = 0.5;
    if (max_cc < THRESHOLD) 
        disp('low correlation, unable to adjust');
        continue
    end

    
    % offset found by cross correlation
    corr_offset = [ (xpeak-inputsize(2)-CORRSIZE) (ypeak-inputsize(1)-CORRSIZE) (zpeak-inputsize(3)-CORRSIZE)];

    % eliminate any big changes in control points
    ind = find(abs(corr_offset) > (CORRSIZE-1));
    if ~isempty(ind)
        disp('peak of norxcorr3 not well constrained, unable to adjust')
        continue
    end

    input_fractional_offset = xyzinput(icp,:) - round(xyzinput(icp,:)*10000)/10000;
    base_fractional_offset = base_cp(icp,:) - round(base_cp(icp,:)*10000)/10000;    
    
    % adjust control point
    xyzinput(icp,:) = xyzinput(icp,:) - input_fractional_offset - corr_offset + base_fractional_offset;
    
   
end
end


%****END MAIN FUNCTION*****



%-------------------------------
%
function cubes = calc_cubes(xyz,halfwidth,img)

%img is not used, must be adapted to volumes
    
%Cube with equal edge lengths
default_width = 2*halfwidth;
default_height = default_width;
default_depth = default_width;

% xyz specifies center of cube, need upper left
upleftfront = round(xyz) - halfwidth;

% need to modify for pixels near edge of images

upper = upleftfront(:,2);
left = upleftfront(:,1);
front = upleftfront(:,3);

%These variables are only necessary for boundary checking

lower = upper + default_height;
right = left + default_width;
back = front + default_depth;


%******Code requires further updates to stop out of bounds errors
width = default_width * ones(size(left));
height = default_height * ones(size(upper));
depth = default_depth * ones(size(front));

% check edges for coordinates outside image
[upper,height] = adjust_lo_edge(upper,1,height);
[dum,height] = adjust_hi_edge(lower,size(img,1),height);
[left,width] = adjust_lo_edge(left,1,width);
[dum,width] = adjust_hi_edge(right,size(img,2),width);
[front,depth] = adjust_lo_edge(front,1,depth);
[dum,depth] = adjust_hi_edge(back,size(img,3),depth);

% set width, height and depth to zero when less than default size
iw = find(width<default_width);
ih = find(height<default_height);
id = find(depth<default_depth);
idx = unique([iw; ih; id]);
width(idx) = 0;
height(idx) = 0;
depth(idx) = 0;

cubes = [upper left front width height depth];
%cubes = [upper left front width*ones(size(upper)) height*ones(size(upper)) depth*ones(size(upper))];
end



%-------------------------------

function sub_vol = crop_volume(volume,cpt)
%Function returns sub-volume from the volume input and a set 
%The variable cpt contains cube points and edge lengths:
%left up front width height depth

        sub_vol = volume(cpt(2):cpt(2)+cpt(5),....
                         cpt(1):cpt(1)+cpt(4),....
                         cpt(3):cpt(3)+cpt(6));
        
end



function [coordinates, breadth] = adjust_lo_edge(coordinates,edge,breadth)

indx = find( coordinates<edge );
if ~isempty(indx)
    breadth(indx) = breadth(indx) - abs(coordinates(indx)-edge);
    coordinates(indx) = edge;
end

end


%-------------------------------
%
function [coordinates, breadth] = adjust_hi_edge(coordinates,edge,breadth)

indx = find( coordinates>edge );
if ~isempty(indx)
    breadth(indx) = breadth(indx) - abs(coordinates(indx)-edge);
    coordinates(indx) = edge;
end

end

%-------------------------------
%
function [input_cp,base_cp,input,base] = ParseInputs(varargin)

iptchecknargin(4,4,nargin,mfilename);

input_cp = varargin{1};
base_cp = varargin{2};
if size(input_cp,2) ~= 3 || size(base_cp,2) ~= 3
    msg = sprintf('In function %s, control point matrices must be M-by-3.',mfilename);
    eid = sprintf('Volumes:%s:cpMatrixMustBeMby3',mfilename);
    error(eid,msg);
end

if size(input_cp,1) ~= size(base_cp,1)
    msg = sprintf('In function %s, INPUT and BASE images need same number of control points.',mfilename);
    eid = sprintf('Volumes:%s:needSameNumOfControlPoints',mfilename);    
    error(eid,msg);
end

input = varargin{3};
base = varargin{4};
if ndims(input) ~= 3 || ndims(base) ~= 3
    msg = sprintf('In function %s, Volumes must be intensity volumes.',mfilename);
    eid = sprintf('Volumes:%s:intensityVolumeReq',mfilename);        
    error(eid,msg);
end

input = double(input);
base = double(base);

% Return to check this code following correct v1.0

if any(input_cp(:)<0.5) || any(input_cp(:,1)>size(input,2)+0.5) || ...
   any(input_cp(:,2)>size(input,1)+0.5) || ...
   any(input_cp(:,3)>size(input,3)+0.5) ||...
   any(base_cp(:)<0.5) || any(base_cp(:,1)>size(base,2)+0.5) || ...
   any(base_cp(:,2)>size(base,1)+0.5) || ...
   any(base_cp(:,3)>size(base,3)+0.5)
    msg = sprintf('In function %s, Control Points must be in pixel coordinates.',mfilename);
    eid = sprintf('Volumes:%s:cpPointsMustBeInPixCoord',mfilename);
    error(eid,msg);


end
end

