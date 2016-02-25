% Original displacement function was developed by Chris and Dan
% displacement3 was developed by Ryan. Code was rewritten for post-processing 3D displacements.

function [validx,validy,validz,indx,indy,indz]=displacement3(validx,validy,validz,indx,indy,indz)

%load data in case you did not load it into workspace yet
if exist('validx')==0
    [validxname,Pathvalidx] = uigetfile('*.dat','Open validx.dat');
    if validxname==0
        disp('You did not select a file!')
        return
    end
    cd(Pathvalidx);
    validx=importdata(validxname,'\t');
end
if exist('validy')==0
    [validyname,Pathvalidy] = uigetfile('*.dat','Open validy.dat');
    if validyname==0
        disp('You did not select a file!')
        return
    end
    cd(Pathvalidy);
    validy=importdata(validyname,'\t');
end
if exist('validz')==0
    [validzname,Pathvalidz] = uigetfile('*.dat','Open validz.dat');
    if validzname==0
        disp('You did not select a file!')
        return
    end
    cd(Pathvalidz);
    validz=importdata(validzname,'\t');
end

%define the size of the data set
sizevalidx=size(validx);
sizevalidy=size(validy);
sizevalidz=size(validz);

%calculate the displacement relative to the first image in x and y
%direction

% clear displx;
% validxfirst=zeros(size(validx));
% validxfirst=mean(validx(:,1),2)*ones(1,sizevalidx(1,2));
% displx=validx-validxfirst;
% indx=find(displx);
% clear validxfirst
% 
% clear disply;
% validyfirst=zeros(size(validy));
% validyfirst=mean(validy(:,1),2)*ones(1,sizevalidy(1,2));
% disply=validy-validyfirst;
% indy=find(disply);
% clear validyfirst
% 
% clear displz;
% validzfirst=zeros(size(validz));
% validzfirst=mean(validz(:,1),2)*ones(1,sizevalidz(1,2));
% displz=validz-validzfirst;
% indz=find(displz);
% clear validzfirst


clear displx indx;
displx=validx(:,5)-validx(:,1);
indx=find(displx);

clear disply indy;
disply=validy(:,5)-validy(:,1);
indy=find(disply);

clear displz indz;
displz=validz(:,5)-validz(:,1);
indz=find(displz);

%Prompt user for type of plotting / visualization
selection1 = menu(sprintf('How do you want to visualize your data?'),'Delete markers from displacement vs. control point plot',...
    'View data with cumulative distribution function','Visual 3D displacements with vector plot','Calculate average 1D strain','Save validx, validy and validz','Cancel');

% Selection for Cancel - All windows will be closed and you jump back to
% the command line
if selection1==6
    close all;
    return
end

% Save validx, validy and validz, very useful if you cleaned up your dataset. Data
% will be saved as -ascii text file. If you send data like this by email
% you can reduce the size tremendously by compressing it. Use ZIP or RAR.
if selection1==5
    [FileName,PathName] = uiputfile('validx_corr.dat','Save validx');
    if FileName==0
        disp('You did not save your file!')
        [validx validy validz]=displacement3(validx,validy, validz);
        return
    else
        cd(PathName)
        save(FileName,'validx','-ascii')
        [FileName,PathName] = uiputfile('validy_corr.dat','Save validy');
        if FileName==0
            disp('You did not save your file!')
            [validx validy validz]=displacement3(validx,validy,validz);
            return
        else
            cd(PathName)
            save(FileName,'validy','-ascii')
            [FileName,PathName] = uiputfile('validz_corr.dat','Save validz');
            if FileName ==0
                disp('You did not save your file!')
                [validx validy validz]=displacement3(validx,validy,validz);
            else
                cd(PathName)
                save(FileName,'validz','-ascii')
            end
        [validx validy validz]=displacement3(validx,validy,validz);
        return
        end
    end
end

% Calculate average 1D strain
if selection1==4
    [validx validy validz]=strain_1D_average_func(validx,validy,validz,displx,disply,displz);
    [validx validy validz]=displacement3(validx,validy,validz);
end

% Plot displacements with quiver3 function
if selection1==3
    close all
    % [maxrow maxcol]=size(validx);
    quiver3(validx(indx,1),validy(indy,1),validz(indz,1),validx(indx,2)-validx(indx,1),validy(indy,2)-validy(indy,1),validz(indz,2)-validz(indz,1))
    [validx validy validz indx indy indz]=displacement3(validx,validy,validz,indx,indy,indz);
end

% Visual data with cumulative distribution function
if selection1==2
    close all
    scrsz = get(0,'ScreenSize');
    figure('Position',[scrsz(3)*0.2 scrsz(4)*0.1 scrsz(3)*0.6 scrsz(4)*0.8])
subplot(3,1,1); set(cdfplot(displx(indx)),'Marker','o')
title(['X-DIRECTION:', 10, 'Cumulative distribution function vs. control point displacement [Voxels]']), xlabel('x'), ylabel('F(x)');
subplot(3,1,2); set(cdfplot(disply(indy)),'Marker','o')
title(['Y-DIRECTION:', 10, 'Cumulative distribution function vs. control point displacement [Voxels]']), xlabel('y'), ylabel('F(y)');
subplot(3,1,3); set(cdfplot(displz(indz)),'Marker','o')
title(['Z-DIRECTION:', 10, 'Cumulative distribution function vs. control point displacement [Voxels]']), xlabel('z'), ylabel('F(z)');

[validx validy validz]=displacement3(validx,validy,validz);
  
end

% Remove datapoints from displacement vs. control point plot
if selection1==1
    close all
    [validx validy validz indx indy indz]=removepoints_func(validx,validy,validz,displx,disply,displz,indx,indy,indz);   
    [validx validy validz indx indy indz]=displacement3(validx,validy,validz,indx,indy,indz);
end


%--------------------------------------------------------------------------
    function [validx,validy,validz,displx,disply,displz] = strain_1D_average_func(validx,validy,validz,displx,disply,displz) 
    
    selection3 = menu(sprintf('How do you want to process your data?'),'Calculate average 1D strain from validx',...
    'Calculate average 1D strain from validy','Calculate average 1D strain from validz','Cancel');
        
    if selection3==1
        videoselection = menu(sprintf('Do you want to create a video?'),'Yes','No');
        if videoselection==1
            mkdir('videostrain')
            cd('videostrain');
            Vid='Vid';
        end
        selection50=1;
        validx_fit=validx;
        displx_fit=displx;
        minminvalidx=min(min(validx));
        maxmaxvalidx=max(max(validx));
        minmindisplx=min(min(displx));
        maxmaxdisplx=max(max(displx));
        h= figure
        while selection50==1
            %     figure
            [pointnumber volumenumber]=size(displx);
            for i=1:volumenumber;
                figure;
                plot(validx_fit(:,i),displx_fit(:,i),'o');
                xdata=validx_fit(:,i);
                ydata=displx_fit(:,i);
                if i==1
                    x(1)=0
                    x(2)=0
                end
                [x,resnormx,residual,exitflagx,output]  = lsqcurvefit(@linearfit, [x(1) x(2)], xdata, ydata);
                hold on;
                ydatafit=x(1)*xdata+x(2);
                plot(xdata,ydatafit,'r');
                
                hold off
                slope(i,:)=[i x(1)];
                disp(slope);
                axis([minminvalidx maxmaxvalidx minmindisplx maxmaxdisplx])
                xlabel('position [pixel]')
                ylabel('displacement [pixel]')
                title(['Displacement versus position',sprintf(' (Current image #: %1g)',i)]);
                drawnow
                if videoselection==1
                    u=i+10000;
                    ustr=num2str(u);
                    videoname=[Vid ustr '.jpg']
                    saveas(h,videoname,'jpg')
                end
            end
            g1 = figure, plot(slope(:,1),slope(:,2));
            hold on
            plot(slope(:,1),slope(:,2),'.');
            xlabel('Image [ ]')
            ylabel('True Strain [ ]')
            title(['True Strain vs. Image #']);
            
            selection40 = menu(sprintf('Do you want to save the data as file?'),'Yes','No');
            if selection40==2
            end
            
            if selection40==1
                alltemp = [slope(:,1) slope(:,2)];
                [FileNameBase,PathNameBase] = uiputfile('','Save file with image# vs. 1Dstrain');
                cd(PathNameBase)
                save(FileNameBase,'alltemp','-ASCII');
                %         save image_1Dstrain_avg.txt alltemp -ASCII
            end
            
            selection50 = menu(sprintf('Do you want to analyse a selected area again?'),'Yes','No');
            if selection50==2
                clear validx_fit
                clear displx_fit
                return
            end
            if selection50==1
                close(g1)
                plot(validx_fit(:,imagenumber),displx_fit(:,imagenumber),'o');
                title(['True strain versus image from all markers']);
                xlabel('Image number [ ]');
                ylabel('True Strain [ ]');
                prompt = {'Min. x-position:','Max. x-position:'};
                dlg_title = 'Regime to be analyzed in pixels';
                num_lines= 1;
                def     = {'800','1200'};
                answer = inputdlg(prompt,dlg_title,num_lines,def);
                minx= str2num(cell2mat(answer(1,1)));
                maxx= str2num(cell2mat(answer(2,1)));
                counter=0
                clear validx_fit
                clear displx_fit
                selectedmarkers=find(validx(:,imagenumber)>minx  & validx(:,imagenumber)<maxx);
                validx_fit=validx(selectedmarkers,:);
                displx_fit=displx(selectedmarkers,:);
                continue
            end
            
        end
    end
    
    if selection3==2
        videoselection = menu(sprintf('Do you want to create a video?'),'Yes','No');
        if videoselection==1
            mkdir('videostrain')
            cd('videostrain');
            Vid='Vid';
        end
        selection50=1;
        validy_fit=validy;
        disply_fit=disply;
        minminvalidy=min(min(validy));
        maxmaxvalidy=max(max(validy));
        minmindisply=min(min(disply));
        maxmaxdisply=max(max(disply));
        h= figure
        while selection50==1
            %     figure
            [pointnumber imagenumber]=size(disply);
            for i=1:imagenumber;
                plot(validy_fit(:,i),disply_fit(:,i),'o');
                xdata=validy_fit(:,i);
                ydata=disply_fit(:,i);
                if i==1
                    y(1)=0
                    y(2)=0
                end
                [y,resnormy,residual,exitflagy,output]  = lsqcurvefit(@linearfit, [y(1) y(2)], xdata, ydata);
                hold on; 
                ydatafit=y(1)*xdata+y(2);
                plot(xdata,ydatafit,'r');
                
                hold off
                slope(i,:)=[i y(1)];
                axis([minminvalidy maxmaxvalidy minmindisply maxmaxdisply])
                xlabel('position [pixel]')
                ylabel('displacement [pixel]')
                title(['Displacement versus position',sprintf(' (Current image #: %1g)',i)]);
                drawnow
                if videoselection==1
                    u=i+10000;
                    ustr=num2str(u);
                    videoname=[Vid ustr '.jpg']
                    saveas(h,videoname,'jpg')
                end
            end
            g1 = figure, plot(slope(:,1),slope(:,2));
            hold on
            plot(slope(:,1),slope(:,2),'.');
            xlabel('Image [ ]')
            ylabel('True Strain [ ]')
            title(['True Strain vs. Image #']);
            
            selection40 = menu(sprintf('Do you want to save the data as file?'),'Yes','No');
            if selection40==2
                
            end
            if selection40==1
                alltemp = [slope(:,1) slope(:,2)];
                [FileNameBase,PathNameBase] = uiputfile('','Save file with image# vs. 1Dstrain');
                cd(PathNameBase)
                save(FileNameBase,'alltemp','-ASCII');
                %         save image_1Dstrain_avg.txt alltemp -ASCII
            end
            
            selection50 = menu(sprintf('Do you want to analyse a selected area again?'),'Yes','No');
            if selection50==2
                clear validy_fit
                clear disply_fit
                return
            end
            if selection50==1
                close(g1)
                plot(validx_fit(:,imagenumber),displx_fit(:,imagenumber),'o');
                title(['True strain versus image from all markers']);
                xlabel('Image number [ ]');
                ylabel('True Strain [ ]');
                prompt = {'Min. y-position:','Max. y-position:'};
                dlg_title = 'Regime to be analyzed in pixels';
                num_lines= 1;
                def     = {'800','1200'};
                answer = inputdlg(prompt,dlg_title,num_lines,def);
                miny= str2num(cell2mat(answer(1,1)));
                maxy= str2num(cell2mat(answer(2,1)));
                counter=0
                clear validy_fit
                clear disply_fit
                selectedmarkers=find(validy(:,imagenumber)>miny  & validy(:,imagenumber)<maxy);
                validy_fit=validy(selectedmarkers,:);
                disply_fit=disply(selectedmarkers,:);
                continue
            end
            
        end
    end
   
     if selection3==3
        videoselection = menu(sprintf('Do you want to create a video?'),'Yes','No');
        if videoselection==1
            mkdir('videostrain')
            cd('videostrain');
            Vid='Vid';
        end
        selection50=1;
        validz_fit=validz;
        displz_fit=displz;
        minminvalidz=min(min(validz));
        maxmaxvalidz=max(max(validz));
        minmindisplz=min(min(displz));
        maxmaxdisplz=max(max(displz));
        h= figure
        while selection50==1
            %     figure
            [pointnumber imagenumber]=size(displz);
            for i=1:imagenumber;
                plot(validz_fit(:,i),displz_fit(:,i),'o');
                xdata=validz_fit(:,i);
                ydata=displz_fit(:,i);
                if i==1
                    z(1)=0
                    z(2)=0
                end
                [z,resnormz,residual,exitflagz,output]  = lsqcurvefit(@linearfit, [z(1) z(2)], xdata, ydata);
                hold on; 
                ydatafit=z(1)*xdata+z(2);
                plot(xdata,ydatafit,'r');
                
                hold off
                slope(i,:)=[i z(1)];
                axis([minminvalidz maxmaxvalidz minmindisplz maxmaxdisplz])
                xlabel('position [pixel]')
                ylabel('displacement [pixel]')
                title(['Displacement versus position',sprintf(' (Current image #: %1g)',i)]);
                drawnow
                if videoselection==1
                    u=i+10000;
                    ustr=num2str(u);
                    videoname=[Vid ustr '.jpg']
                    saveas(h,videoname,'jpg')
                end
            end
            g1 = figure, plot(slope(:,1),slope(:,2));
            hold on
            plot(slope(:,1),slope(:,2),'.');
            xlabel('Image [ ]')
            ylabel('True Strain [ ]')
            title(['True Strain vs. Image #']);
            
            selection40 = menu(sprintf('Do you want to save the data as file?'),'Yes','No');
            if selection40==2
                
            end
            if selection40==1
                alltemp = [slope(:,1) slope(:,2)];
                [FileNameBase,PathNameBase] = uiputfile('','Save file with image# vs. 1Dstrain');
                cd(PathNameBase)
                save(FileNameBase,'alltemp','-ASCII');
                %         save image_1Dstrain_avg.txt alltemp -ASCII
            end
            
            selection50 = menu(sprintf('Do you want to analyse a selected area again?'),'Yes','No');
            if selection50==2
                clear validz_fit
                clear displz_fit
                return
            end
            if selection50==1
                close(g1)
                plot(validz_fit(:,imagenumber),displz_fit(:,imagenumber),'o');
                title(['True strain versus image from all markers']);
                xlabel('Image number [ ]');
                ylabel('True Strain [ ]');
                prompt = {'Min. z-position:','Max. z-position:'};
                dlg_title = 'Regime to be analyzed in pixels';
                num_lines= 1;
                def     = {'800','1200'};
                answer = inputdlg(prompt,dlg_title,num_lines,def);
                miny=str2num(cell2mat(answer(1,1)));
                maxy=str2num(cell2mat(answer(2,1)));
                counter=0
                clear validz_fit
                clear displz_fit
                selectedmarkers=find(validz(:,imagenumber)>minz  & validz(:,imagenumber)<maxz);
                validz_fit=validz(selectedmarkers,:);
                displz_fit=displz(selectedmarkers,:);
                continue
            end
            
        end
     end
        
    end

%-------------------------------------------------------------------------

function [validx validy validz indx indy indz]=removepoints_func(validx,validy,validz,displx,disply,displz,indx,indy,indz)

doitonemoretime =1;     
    
selection2 = menu(sprintf('How do you want to process your data?'),'Delete markers from validx displacements',...
    'Delete markers from validy displacements','Delete markers from validz displacements','Cancel');

if selection2==1
    while doitonemoretime==1
        
        % Select an upper and lower boundary
    xlabel('Control point number')
    ylabel('Relative marker dispacement [Voxels]')
    title(sprintf('Define the upper and lower bound by clicking above and below the valid points'))
    plot(indx,displx(indx),'o')
    v = axis;
    marker_pt=(ginput(1));
    x_mark(1,1) = marker_pt(1);
    y_mark(1,1) = marker_pt(2);

    title(sprintf('Define the upper and lower bound by clicking above and below the valid points'))
    marker_pt=(ginput(1));
    x_mark(1,2) = marker_pt(1);
    y_mark(1,2) = marker_pt(2);

    upperbound=max(y_mark);
    lowerbound=min(y_mark);
        
    validxtemp=zeros(size(validx));
    validytemp=zeros(size(validy));
    validztemp=zeros(size(validz));
  
  clear i
      for i=1:length(indx)
        if (displx(indx(i))<upperbound && displx(indx(i))>lowerbound)
        indx_temp(i)=indx(i);
        else
       	indx_temp(i)=[0];
        end
      end
    indx_temp=indx_temp(find(indx_temp));
    plot(indx_temp,displx(indx_temp),'o'),axis([v(1) v(2) v(3) v(4)])
    xlabel('Control point number')
    ylabel('Relative marker dispacement [Voxels]')
    
    validxtemp(indx_temp,:)=validx(indx_temp,:);
    validytemp(indx_temp,:)=validy(indx_temp,:);
    validztemp(indx_temp,:)=validz(indx_temp,:);
    
 selection_filter = menu('Do you like the result?','Take it as is','Want to select more','Try again','Cancel');
    if selection_filter==1
        validx=validxtemp;
        validy=validytemp;
        validz=validztemp;
        indx=indx_temp;
        indy=indx_temp;
        indz=indx_temp;
        doitonemoretime=0;
    elseif selection_filter==2
        validx=validxtemp;
        validy=validytemp;
        validz=validztemp;
        indx=indx_temp;
        indy=indx_temp;
        indz=indx_temp;
        doitonemoretime=1;
    elseif selection_filter==3
        doitonemoretime=1;
    elseif selection_filter==4
        return
    end    
        
    end
end

if selection2==2
    
     while doitonemoretime==1
        
   % Select an upper and lower boundary
    xlabel('Control point number')
    ylabel('Relative marker dispacement [Voxels]')
    title(sprintf('Define the upper and lower bound by clicking above and below the valid points'))
    plot(indy,disply(indy),'o')
    v = axis;
    marker_pt=(ginput(1));
    x_mark(1,1) = marker_pt(1);
    y_mark(1,1) = marker_pt(2);

    title(sprintf('Define the upper and lower bound by clicking above and below the valid points'))
    marker_pt=(ginput(1));
    x_mark(1,2) = marker_pt(1);
    y_mark(1,2) = marker_pt(2);

    upperbound=max(y_mark);
    lowerbound=min(y_mark);
        
    validxtemp=zeros(size(validx));
    validytemp=zeros(size(validy));
    validztemp=zeros(size(validz));
  
  clear i
      for i=1:length(indy)
        if (disply(indy(i))<upperbound && disply(indy(i))>lowerbound)
        indy_temp(i)=indy(i);
        else
       	indy_temp(i)=[0];
        end
      end
    indy_temp=indy_temp(find(indy_temp));
    plot(indy_temp,disply(indy_temp),'o'),axis([v(1) v(2) v(3) v(4)])
    xlabel('Control point number')
    ylabel('Relative marker dispacement [Voxels]')
    
    validxtemp(indy_temp,:)=validx(indy_temp,:);
    validytemp(indy_temp,:)=validy(indy_temp,:);
    validztemp(indy_temp,:)=validz(indy_temp,:);
    
 selection_filter = menu('Do you like the result?','Take it as is','Want to select more','Try again','Cancel');
    if selection_filter==1
        validx=validxtemp;
        validy=validytemp;
        validz=validztemp;
        indx=indy_temp;
        indy=indy_temp;
        indz=indy_temp;
        doitonemoretime=0;
    elseif selection_filter==2
        validx=validxtemp;
        validy=validytemp;
        validz=validztemp;
        indx=indy_temp;
        indy=indy_temp;
        indz=indy_temp;
        doitonemoretime=1;
    elseif selection_filter==3
        doitonemoretime=1;
    elseif selection_filter==4
        return
    end    
        
    end
end
   

if selection2==3
  
     while doitonemoretime==1
        
   % Select an upper and lower boundary
    xlabel('Control point number')
    ylabel('Relative marker dispacement [Voxels]')
    title(sprintf('Define the upper and lower bound by clicking above and below the valid points'))
    plot(indz,displz(indz),'o')
    v = axis;
    marker_pt=(ginput(1));
    x_mark(1,1) = marker_pt(1);
    y_mark(1,1) = marker_pt(2);

    title(sprintf('Define the upper and lower bound by clicking above and below the valid points'))
    marker_pt=(ginput(1));
    x_mark(1,2) = marker_pt(1);
    y_mark(1,2) = marker_pt(2);

    upperbound=max(y_mark);
    lowerbound=min(y_mark);
        
    validxtemp=zeros(size(validx));
    validytemp=zeros(size(validy));
    validztemp=zeros(size(validz));
  
  clear i
      for i=1:length(indz)
        if (displz(indz(i))<upperbound && displz(indz(i))>lowerbound)
        indz_temp(i)=indz(i);
        else
       	indz_temp(i)=[0];
        end
      end
    indz_temp=indz_temp(find(indz_temp));
    plot(indz_temp,displz(indz_temp),'o'),axis([v(1) v(2) v(3) v(4)])
    xlabel('Control point number')
    ylabel('Relative marker dispacement [Voxels]')
    
    validxtemp(indz_temp,:)=validx(indz_temp,:);
    validytemp(indz_temp,:)=validy(indz_temp,:);
    validztemp(indz_temp,:)=validz(indz_temp,:);
    
 selection_filter = menu('Do you like the result?','Take it as is','Want to select more','Try again','Cancel');
    if selection_filter==1
        validx=validxtemp;
        validy=validytemp;
        validz=validztemp;
        indx=indz_temp;
        indy=indz_temp;
        indz=indz_temp;
        doitonemoretime=0;
    elseif selection_filter==2
        validx=validxtemp;
        validy=validytemp;
        validz=validztemp;
        indx=indz_temp;
        indy=indz_temp;
        indz=indz_temp;
        doitonemoretime=1;
    elseif selection_filter==3
        doitonemoretime=1;
    elseif selection_filter==4
        return
    end    
        
    end
    
    
end

end

end
