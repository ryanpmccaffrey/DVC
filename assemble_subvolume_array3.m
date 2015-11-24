function sub_volume = assemble_subvolume_array3(volume_points_for,volume,CORRSIZE,ncp)

cubes_volume = calc_cubes(volume_points_for,CORRSIZE,volume);

sub_volume=int8(zeros(2*CORRSIZE+1,2*CORRSIZE+1,2*CORRSIZE+1,ncp));

disp('start subvolume array assembly');
%tic;
for icp = 1:ncp
    
    %Commented out code for v 1.0 - to be adapted
    if isequal(cubes_volume(icp,4:6),[0 0 0])
       % disp(' near edge, unable to adjust')
        continue
    end
    
    sub_volume(:,:,:,icp) = crop_volume(volume,cubes_volume(icp,:));
    
end
%toc;
disp('stop subvolume array assembly');

 function cubes = calc_cubes(xyz,halfwidth,img)
    
%Cube with equal edge lengths
default_width = 2*halfwidth;
default_height = default_width;
default_depth = default_width;

upleftfront = round(xyz) - halfwidth; 

% need to modify for pixels near edge of images

left = upleftfront(:,1);
upper = upleftfront(:,2);
front = upleftfront(:,3);

% These variables are only necessary for boundary checking

right = left + default_width;
lower = upper + default_height;
back = front + default_depth;

% Code requires further updates to stop out of bounds errors
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

cubes = [left upper front width height depth];
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
% function [input_cp,base_cp,input,base] = ParseInputs(varargin)
% 
% iptchecknargin(4,4,nargin,mfilename);
% 
% input_cp = varargin{1};
% base_cp = varargin{2};
% if size(input_cp,2) ~= 3 || size(base_cp,2) ~= 3
%     msg = sprintf('In function %s, control point matrices must be M-by-3.',mfilename);
%     eid = sprintf('Volumes:%s:cpMatrixMustBeMby3',mfilename);
%     error(eid,msg);
% end
% 
% if size(input_cp,1) ~= size(base_cp,1)
%     msg = sprintf('In function %s, INPUT and BASE images need same number of control points.',mfilename);
%     eid = sprintf('Volumes:%s:needSameNumOfControlPoints',mfilename);    
%     error(eid,msg);
% end
% 
% input = varargin{3};
% base = varargin{4};
% if ndims(input) ~= 3 || ndims(base) ~= 3
%     msg = sprintf('In function %s, Volumes must be intensity volumes.',mfilename);
%     eid = sprintf('Volumes:%s:intensityVolumeReq',mfilename);        
%     error(eid,msg);
% end
% 
% % Return to check this code following correct v1.0
% 
% if any(input_cp(:)<0.5) || any(input_cp(:,1)>size(input,2)+0.5) || ...
%    any(input_cp(:,2)>size(input,1)+0.5) || ...
%    any(input_cp(:,3)>size(input,3)+0.5) ||...
%    any(base_cp(:)<0.5) || any(base_cp(:,1)>size(base,2)+0.5) || ...
%    any(base_cp(:,2)>size(base,1)+0.5) || ...
%    any(base_cp(:,3)>size(base,3)+0.5)
%     msg = sprintf('In function %s, Control Points must be in pixel coordinates.',mfilename);
%     eid = sprintf('Volumes:%s:cpPointsMustBeInPixCoord',mfilename);
%     error(eid,msg);
% 
% 
% end
end