function varargout = FLIM(varargin)

clc; close all; clear;
disp('clearing matlab workspace');


thisfile = 'FLIManalyzerV9';
% thisfilepath = '/Users/bradleymonk/Documents/MatLab/myToolbox/LAB/FRET_FLIM/FLIManalyzerV7';
thisfilepath = fileparts(which(thisfile)); % fileparts(which(mfilename))
disp(['Changing to dir: ' thisfilepath])
cd(thisfilepath);


datadir = '/Users/bradleymonk/Documents/MatLab/myToolbox/LAB/FRET_FLIM/FRETdata/ActinThymosin/';
disp(['Changing to dir: ' datadir])
cd(datadir);

global tempfilename
tempfilename = '';


%{
if(~isdeployed);

cd(fileparts(which(mfilename)));
% cd ../..
cd ..

%     if ~exist('datadir','var')
%         disp('Select the data directory');
%         datadir = uigetdir(pwd,'Select the data directory');
%         cd(datadir);
%     end

datadir = '/Users/bradleymonk/Documents/MatLab/myToolbox/LAB/FRET_FLIM/FRETdata/ActinThymosin/';
cd(datadir);

end
%}

%Initialization code. Function creates a datastack variable for storing the
%files. It then displays the initial menu options - to compile a file or to
%load a file. Also sets up lifetime image and intensity image windows -
%these are set to invisible unless the 'load file' button is selected.
initmenuh = figure('Position', [100 100 400 150], 'BusyAction', 'cancel', 'Menubar', 'none', 'Name', 'FLIM analysis', 'Tag', 'FLIM analysis');
loadfileh = uicontrol('Parent', initmenuh, 'Position', [20 50 150 50], 'String', 'Load data file', 'FontSize', 11, 'Tag', 'Load data file', 'Callback', @loadfile);
compilefileh = uicontrol('Parent', initmenuh, 'Position', [230 50 150 50], 'String', 'Compile data file', 'FontSize', 11, 'Tag', 'Compile data file', 'Callback', @compilefile);
intimagewh = figure('Position', [60 10 750 650], 'BusyAction', 'cancel', 'Menubar', 'none', 'Name', 'Lifetime image', 'Tag', 'lifetime image', 'Visible', 'Off', 'KeyPressFcn', @keypress);



%The following code sets up the intensity image window.
intimageaxesh = axes('Parent', intimagewh, 'NextPlot', 'Add', 'PlotBoxAspectRatio', [1 1 1], 'OuterPosition', [0.05 0.05 0.8 0.8], 'Position', [0.05 0.15 0.72 0.72]);
boxidh = uicontrol('Parent', intimagewh, 'Style', 'Edit', 'Units', 'normalized', 'Position', [0.88 0.9 0.06 0.04], 'FontSize', 11);
boxidselecth = uicontrol('Parent', intimagewh, 'Units', 'normalized', 'Position', [0.75 0.9 0.12 0.04], 'FontSize', 11, 'String', 'Box ID', 'Callback', @GetMouseLoc);
boxsizetexth = uicontrol('Parent', intimagewh, 'Style', 'Text', 'Units', 'normalized', 'Position', [0.75 0.85 0.12 0.04], 'FontSize', 11, 'String', 'Box Size');
boxsizeh = uicontrol('Parent', intimagewh, 'Style', 'Edit', 'Units', 'normalized', 'Position', [0.88 0.85 0.06 0.04], 'FontSize', 11);

denspineh = uicontrol('Parent', intimagewh, 'Style', 'popupmenu', 'Units', 'normalized', 'Position', [0.75 0.78 0.13 0.04], 'FontSize', 11, 'String', {'Dendrite (Y)', 'Spine (R)'});
moveboxuph = uicontrol('Parent', intimagewh, 'Units', 'normalized', 'Position', [0.88 0.78 0.05 0.04], 'FontSize', 11, 'String', 'Up', 'Callback', @moveboxup);
moveboxdownh = uicontrol('Parent', intimagewh, 'Units', 'normalized', 'Position', [0.93 0.78 0.06 0.04], 'FontSize', 11, 'String', 'Down', 'Callback', @moveboxdown);
moveboxlefth = uicontrol('Parent', intimagewh, 'Units', 'normalized', 'Position', [0.88 0.73 0.05 0.04], 'FontSize', 11, 'String', 'Left', 'Callback', @moveboxleft);
moveboxrighth = uicontrol('Parent', intimagewh, 'Units', 'normalized', 'Position', [0.93 0.73 0.06 0.04], 'FontSize', 11, 'String', 'Right', 'Callback', @moveboxright);
movespeedh = uicontrol('Parent', intimagewh, 'Style', 'popupmenu', 'Units', 'normalized', 'Position', [0.75 0.73 0.13 0.04], 'FontSize', 11, 'String', {'Slow', 'Fast', 'All Slow', 'All Fast'});
rotateh = uicontrol('Parent', intimagewh, 'Units', 'normalized', 'Position', [0.75 0.68 0.12 0.04], 'String', 'Rotate', 'FontSize', 11, 'Callback', @rotatebox);

zoomh = uicontrol('Parent', intimagewh, 'Units', 'normalized', 'Position', [0.88 0.68 0.12 0.04], 'String', 'Zoom', 'FontSize', 11, 'Callback', @zoomlifetime);
analyzeh = uicontrol('Parent', intimagewh, 'Units', 'normalized', 'Position', [0.75 0.63 0.12 0.04], 'String', 'Analyze', 'FontSize', 11, 'Callback', @analyze);
deleteboxh = uicontrol('Parent', intimagewh, 'Units', 'normalized', 'Position', [0.88 0.63 0.12 0.04], 'String', 'Delete Box', 'FontSize', 11, 'Callback', @deletebox);

intenlowerh = uicontrol('Parent', intimagewh, 'Style', 'Text', 'Units', 'normalized', 'Position', [0.75 0.58 0.12 0.04], 'FontSize', 11, 'String', 'Min intensity');
intenupperh = uicontrol('Parent', intimagewh, 'Style', 'Text', 'Units', 'normalized', 'Position', [0.75 0.53 0.12 0.04], 'FontSize', 11, 'String', 'Max intensity');
intenlowerinputh = uicontrol('Parent', intimagewh, 'Style', 'Edit', 'FontSize', 11, 'Units', 'normalized', 'Position', [0.88 0.58 0.06 0.04]);
intenupperinputh = uicontrol('Parent', intimagewh, 'Style', 'Edit', 'FontSize', 11, 'Units', 'normalized', 'Position', [0.88 0.53 0.06 0.04]);
setintenh = uicontrol('Parent', intimagewh, 'Units', 'normalized', 'Position', [0.75 0.48 0.12 0.04], 'FontSize', 11, 'String', 'Set intensity',  'Callback', @setinten);
dftintenh = uicontrol('Parent', intimagewh, 'Units', 'normalized', 'Position', [0.75 0.43 0.18 0.04], 'FontSize', 11, 'String', 'Default intensities',  'Callback', @defaultinten);

lifetimethresholdh = uicontrol('Parent', intimagewh, 'Style', 'Text',  'Units', 'normalized', 'Position', [0.75 0.38 0.14 0.04], 'FontSize', 11, 'String', 'Lifetime Cutoff');
lftthresholdh = uicontrol('Parent', intimagewh, 'Style', 'Edit',  'Units', 'normalized', 'Position', [0.90 0.38 0.06 0.04], 'FontSize', 11);
intensitythresholdh = uicontrol('Parent', intimagewh, 'Style', 'Text',  'Units', 'normalized', 'Position', [0.75 0.33 0.14 0.04], 'FontSize', 11, 'String', 'Intensity Cutoff');
intenthresholdh = uicontrol('Parent', intimagewh, 'Style', 'Edit',  'Units', 'normalized', 'Position', [0.90 0.33 0.06 0.04], 'FontSize', 11);
chithresholdminh = uicontrol('Parent', intimagewh, 'Style', 'Text',  'Units', 'normalized', 'Position', [0.75 0.28 0.14 0.04], 'FontSize', 11, 'String', 'Chi Min');
chiminh = uicontrol('Parent', intimagewh, 'Style', 'Edit',  'Units', 'normalized', 'Position', [0.90 0.28 0.06 0.04], 'FontSize', 11);
chithresholdmaxh = uicontrol('Parent', intimagewh, 'Style', 'Text',  'Units', 'normalized', 'Position', [0.75 0.23 0.14 0.04], 'FontSize', 11, 'String', 'Chi Max');
chimaxh = uicontrol('Parent', intimagewh, 'Style', 'Edit',  'Units', 'normalized', 'Position', [0.90 0.23 0.06 0.04], 'FontSize', 11);

savefileh = uicontrol('Parent', intimagewh, 'Units', 'normalized', 'Position', [0.75 0.18 0.12 0.04], 'String', 'Save File', 'FontSize', 11, 'Callback', @saveFile);
saveROIh = uicontrol('Parent', intimagewh, 'Units', 'normalized', 'Position', [0.88 0.18 0.11 0.04], 'String', 'Save ROIs', 'FontSize', 11, 'Callback', @saveROIs);
loadROIh = uicontrol('Parent', intimagewh, 'Units', 'normalized', 'Position', [0.75 0.13 0.12 0.04], 'String', 'Load ROIs', 'FontSize', 11, 'Callback', @loadROIs);
chithresholdviewerh = uicontrol('Parent', intimagewh, 'Units', 'normalized', 'Position', [0.88 0.13 0.12 0.04], 'String', 'Chi view', 'FontSize', 11, 'Callback', @chithresholdviewer);
closeimagesh = uicontrol('Parent', intimagewh, 'Units', 'normalized', 'Position', [0.75 0.08 0.18 0.04], 'FontSize', 11, 'String', 'Close Windows', 'Callback', @closelftintenw);


intimageh = imagesc('Parent', intimageaxesh);


datastack = zeros(1,1,3,'double');
lifetime = zeros(1, 1);
intensity = zeros(1, 1);
chi = zeros(1, 1);

lifetimeimage = zeros(1, 1);
intensityimage = zeros(1, 1);

xdim = 0;
ydim = 0;

saveROI = zeros(200, 17);
saveData = zeros(200, 9);

datadirectory = '';
home = cd;

%Compile function triggers the user input for three datafiles. (Will return
%error if files are not of the right size, etc.) Compile then writes a new
%file that is the stacked version of all three files.
function compilefile(hObject, eventdata)
    set(initmenuh, 'Visible', 'Off');

    home = cd;
    if size(datadirectory) == 0
        datadir = uigetdir;
        datadirectory = datadir;

        cd(datadirectory);
    else
        datadirectory = uigetdir;
        cd(datadirectory);
    end

    filelist = dir(datadirectory);
    filelistsize = size(filelist);



    for ii=1:filelistsize

        chifile = '';
        chifilename = '';
        colorfile = '';
        colorfilename = '';
        intenfile = '';
        intenfilename = '';
        currentfile = filelist(ii,1).name;


        if(length(currentfile) >=7)

            if (strcmp('Chi of ', currentfile(1:7))==1) ||...
               (strcmp('chi.asc', currentfile(end-6:end))==1)

                chifile = currentfile;
                if (strcmp('Chi of ', chifile(1:7))==1)
                    chifilename = chifile(8:end);
                else
                    chifilename = chifile(1:end-8);
                end


                for jj=1:filelistsize

                    searchcolorfile = filelist(jj,1).name;

                    if(length(searchcolorfile) >=21)


                        if (strcmp('Color coded value of ', searchcolorfile(1:21))==1) ||...
                           (strcmp('color coded value.asc', searchcolorfile(end-20:end))==1)

                            if (strcmp(chifilename, searchcolorfile(22:end))==1) ||...
                               (strcmp(chifilename, searchcolorfile(1:end-22))==1)

                                colorfile = searchcolorfile;
                                if (strcmp(chifilename, colorfile(22:end))==1)
                                    colorfilename = colorfile(22:end);
                                else
                                    colorfilename = colorfile(1:end-22);
                                end


                                for kk=1:filelistsize
                                    searchintenfile = filelist(kk,1).name;

                                    if(length(searchintenfile) >=12)

                                        if (strcmp('Photons of ', searchintenfile(1:11))==1) ||...
                                           (strcmp('photons.asc', searchintenfile(end-10:end))==1)


                                            if (strcmp(chifilename, searchintenfile(12:end))==1) ||...
                                               (strcmp(chifilename, searchintenfile(1:end-12))==1)

                                                intenfile = searchintenfile;
                                                if (strcmp(chifilename, colorfile(22:end))==1)
                                                    intenfilename = intenfile(12:end);
                                                else
                                                    intenfilename = intenfile(1:end-12);
                                                end


                                                if(strcmp(chifilename, colorfilename)==1 && strcmp(chifilename, intenfilename)==1)

                                                    lifetime = load(colorfile);
                                                    lifetimedim = size(lifetime);
                                                    intensity = load(intenfile);
                                                    intensitydim = size(intensity);
                                                    chitemp = load(chifile);
                                                    chidim = size(chitemp);
                                                    chi = zeros(chidim(1), chidim(2));
                                                    if isequal(lifetimedim, intensitydim, chidim)==1
                                                        for nn=1:chidim(1)
                                                            for mm=1:chidim(2)
                                                                if(chitemp(nn,mm)> 100)
                                                                    chi(nn,mm) = 0;
                                                                else
                                                                    chi(nn,mm) = chitemp(nn,mm);
                                                                end
                                                            end
                                                        end

                                                        savefilename = mat2str(strcat(chifilename, '.dat'));
                                                        savefilename = savefilename(2:end-1);
                                                        save(savefilename, 'lifetime', '-ascii');
                                                        save(savefilename, 'intensity', '-ascii', '-append');
                                                        save(savefilename, 'chi', '-ascii', '-append');

                                                        disp(strcat(savefilename, ' was successfully compiled.'));
                                                    else
                                                        savefilename = mat2str(strcat(chifilename, '.dat'));
                                                        savefilename = savefilename(2:end-1);
                                                        disp('Error compiling ', savefilename, '. One or more of the component files may be incorrect');

                                                    end

                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    msgbox('All files successfully compiled.');



    cd(home);

    set(initmenuh, 'Visible', 'On');


end



%Load file triggers uiresume; the initial menu is set to invisible. Prompts
%user for file to load, copies the datastack from the file; sets the image
%windows to visible, and plots the images.
function loadfile(hObject, eventdata)
        set(initmenuh, 'Visible', 'Off');

        home = cd;
        if size(datadirectory)~= 0
            cd(datadirectory);
        end
        [tempfilename, datadir] = uigetfile('*.dat', 'load a .dat file');
        if(strcmp(datadir, datadirectory) == 0)
            datadirectory = datadir;
            cd(datadirectory);
        end

        tempdata = load(tempfilename);
        tempdatadim = size(tempdata);
        totxdim = tempdatadim(1); ydim = tempdatadim(2);


        if mod(totxdim,3)~=0
            disp('This does not appear to be a properly compiled file.');
            return
        else
            xdim = totxdim/3;
            datastack = zeros(xdim,ydim,3,'double');
            lifetime = zeros(xdim, ydim);
            intensity = zeros(xdim, ydim);
            chi = zeros(xdim, ydim);

            lifetimeimage = zeros(xdim, ydim);
            intensityimage = zeros(xdim, ydim);

            set(intimagewh, 'Visible', 'On');

            for i=1:xdim; for j=1:ydim;
               datastack(i,j,1) = tempdata(i,j);
               end
            end
            for i=xdim+1:2*xdim; for j=1:ydim;
               datastack(i-xdim,j,2) = tempdata(i,j);
               end
            end
            for i=2*xdim+1:3*xdim; for j=1:ydim;
               datastack(i-2*xdim,j,3) = tempdata(i,j);
               end
            end

            lifetime = datastack(:,:,1);
            intensity = datastack(:,:,2);
            chi = datastack(:,:,3);


            for i=1:xdim;
                for j=1:ydim;
                    intensityimage(i,j) = intensity(i,j);
                end
            end


        intimageh = imagesc(intensityimage, 'Parent', intimageaxesh, [prctile(intensityimage(:),83) prctile(intensityimage(:),95)]);
        % set(intimagewh, 'Colormap', gray);
        set(intimagewh, 'Colormap', hot);



        set(boxsizeh, 'String', int2str(11));
        set(intenlowerinputh, 'String', int2str(prctile(intensityimage(:),80)));
        set(intenupperinputh, 'String', int2str(prctile(intensityimage(:),97)));
        set(lftthresholdh, 'String', int2str(900));
        set(intenthresholdh, 'String', int2str(2));
        set(chiminh, 'String', num2str(0.7));
        set(chimaxh, 'String', num2str(2.0));
        cd(home);

        set(intimagewh, 'Name', tempfilename);
        set(boxidh, 'String', int2str(1));
        set(intimageaxesh, 'XLim', [1 xdim]);
        set(intimageaxesh, 'YLim', [1 ydim]);


    end


end



function setinten(hObject, eventdata)
       intensityimage = zeros(xdim, ydim);

       for i=1:xdim;
            for j=1:ydim;
                intensityimage(i,j) = intensity(i,j);
            end
       end

       lowerinten = str2num(get(intenlowerinputh, 'String'));
       upperinten = str2num(get(intenupperinputh, 'String'));

       intimageh = imagesc(intensityimage, 'Parent', intimageaxesh, [lowerinten upperinten]);
       drawROIs();
end



function defaultinten(hObject, eventdata)
       intensityimage = zeros(xdim, ydim);

       for i=1:xdim;
            for j=1:ydim;
                intensityimage(i,j) = intensity(i,j);
            end
       end

       intimageh = imagesc(intensityimage, 'Parent', intimageaxesh, [prctile(intensityimage(:),80) prctile(intensityimage(:),97)]);

       set(intenlowerinputh, 'String', int2str(prctile(intensityimage(:),80)));
       set(intenupperinputh, 'String', int2str(prctile(intensityimage(:),97)));
       drawROIs();
end






%Closelftintenw sets both lifetime image and intensity image windows to
%invisible. The initial menu becomes visible again for further selection.
function closelftintenw(hObject, eventdata)
       set(intimagewh, 'Visible', 'Off');
       set(initmenuh, 'Visible', 'On');
       saveROI = zeros(200, 17);
       saveData = zeros(200, 9);
       datastack = zeros(1,1,3,'double');
       lifetime = zeros(1, 1);
       intensity = zeros(1, 1);
       chi = zeros(1, 1);
       lifetimeimage = zeros(1, 1);
       intensityimage = zeros(1, 1);
       xdim = 0;
       ydim = 0;
end




function GetMouseLoc(boxidselecth, eventdata)

% set(gcf,'Pointer','hand')

        if(saveROI(str2double(get(boxidh, 'String')),1)==0)
            %[x, y] = ginput(2);
            [x,y] = FLIMginput(2,'custom');
            x1=x(1);
            y1=y(1);
            x2=x(2);
            y2=y(2);
            calcROIcoor(x1, y1, x2, y2, str2double(get(boxidh, 'String')));
        else
            duplicateROI = questdlg('Box already exists. Overwrite?', 'Duplicate ROI', 'Yes', 'No', 'No');
            switch duplicateROI
                case 'Yes'
                    [x, y] = ginput(2);
                    x1=x(1);
                    y1=y(1);
                    x2=x(2);
                    y2=y(2);
                    calcROIcoor(x1, y1, x2, y2, str2double(get(boxidh, 'String')));
                case 'No'
            end
        end

        doagainROI = questdlg('Select next ROI?', 'Select next ROI?', 'Yes', 'No', 'No');
        switch doagainROI
           case 'Yes'
                set(boxidh,'String',num2str((str2num(boxidh.String)+1)) );
                GetMouseLoc
           case 'No'
        end

set(gcf,'Pointer','arrow')

end




function calcROIcoor(x1, y1, x2, y2, boxIDcounter)
        ROIsize = str2double(get(boxsizeh, 'String'));
        d=sqrt((y2-y1)^2+(x2-x1)^2);

        if d==0
            errordlg('You have selected the same point!');
        else

        SpineVertex1_x = (x1 + ROIsize*(x2-x1+y1-y2)/(2*d));
        SpineVertex1_y = (y1 + ROIsize*(y2-y1+x2-x1)/(2*d));
        SpineVertex2_x = (x1 + ROIsize*(x1-x2+y1-y2)/(2*d));
        SpineVertex2_y = (y1 + ROIsize*(y1-y2+x2-x1)/(2*d));
        SpineVertex3_x = (x1 + ROIsize*(x1-x2+y2-y1)/(2*d));
        SpineVertex3_y = (y1 + ROIsize*(y1-y2+x1-x2)/(2*d));
        SpineVertex4_x = (x1 + ROIsize*(x2-x1+y2-y1)/(2*d));
        SpineVertex4_y = (y1 + ROIsize*(y2-y1+x1-x2)/(2*d));

        DenVertex1_x = x2 + ROIsize*(x2-x1+y1-y2)/(2*d);
        DenVertex1_y = y2 + ROIsize*(y2-y1+x2-x1)/(2*d);
        DenVertex2_x = x2 + ROIsize*(x1-x2+y1-y2)/(2*d);
        DenVertex2_y = y2 + ROIsize*(y1-y2+x2-x1)/(2*d);
        DenVertex3_x = x2 + ROIsize*(x1-x2+y2-y1)/(2*d);
        DenVertex3_y = y2 + ROIsize*(y1-y2+x1-x2)/(2*d);
        DenVertex4_x = x2 + ROIsize*(x2-x1+y2-y1)/(2*d);
        DenVertex4_y = y2 + ROIsize*(y2-y1+x1-x2)/(2*d);

        saveROI(boxIDcounter, 1) = boxIDcounter;
        saveROI(boxIDcounter, 2) = SpineVertex1_x;
        saveROI(boxIDcounter, 3) = SpineVertex1_y;
        saveROI(boxIDcounter, 4) = SpineVertex2_x;
        saveROI(boxIDcounter, 5) = SpineVertex2_y;
        saveROI(boxIDcounter, 6) = SpineVertex3_x;
        saveROI(boxIDcounter, 7) = SpineVertex3_y;
        saveROI(boxIDcounter, 8) = SpineVertex4_x;
        saveROI(boxIDcounter, 9) = SpineVertex4_y;
        saveROI(boxIDcounter, 10) = DenVertex1_x;
        saveROI(boxIDcounter, 11) = DenVertex1_y;
        saveROI(boxIDcounter, 12) = DenVertex2_x;
        saveROI(boxIDcounter, 13) = DenVertex2_y;
        saveROI(boxIDcounter, 14) = DenVertex3_x;
        saveROI(boxIDcounter, 15) = DenVertex3_y;
        saveROI(boxIDcounter, 16) = DenVertex4_x;
        saveROI(boxIDcounter, 17) = DenVertex4_y;

        drawROIs();
        end

end



function zoomlifetime(zoomh, eventData)
        zoom on;
end



function analyze(analyzeh, eventData)
        ID = str2double(get(boxidh, 'String'));

        lftthreshold = str2double(get(lftthresholdh, 'String'));
        intenthreshold = str2double(get(intenthresholdh, 'String'));
        chimin = str2double(get(chiminh, 'String'));
        chimax = str2double(get(chimaxh, 'String'));

        if(saveROI(ID,1) ~=0)

        Spine_x = [saveROI(ID,2) saveROI(ID,4) saveROI(ID,6) saveROI(ID,8) saveROI(ID,2)];
        Spine_y = [saveROI(ID,3) saveROI(ID,5) saveROI(ID,7) saveROI(ID,9) saveROI(ID,3)];
        Den_x = [saveROI(ID,10) saveROI(ID,12) saveROI(ID,14) saveROI(ID,16) saveROI(ID,10)];
        Den_y = [saveROI(ID,11) saveROI(ID,13) saveROI(ID,15) saveROI(ID,17) saveROI(ID,11)];

        newspine = poly2mask(Spine_x, Spine_y, xdim, ydim);
        spinepixels = cell2mat(struct2cell(regionprops(newspine, 'PixelList')));

        newden = poly2mask(Den_x, Den_y, xdim, ydim);
        denpixels = cell2mat(struct2cell(regionprops(newden, 'PixelList')));

        spinesize = size(spinepixels, 1);
        spinelifetime = 0;
        spinetotinten = 0;
        spineavgchi = 0;
        numsigspinepixels = 0;
        spinematrix = zeros(1, spinesize);
        for i=1:spinesize;
                pixel_x = spinepixels(i,2);
                pixel_y = spinepixels(i,1);
                spinematrix(1,i) = lifetime(pixel_x, pixel_y);
                if(lifetime(pixel_x, pixel_y) >= lftthreshold &&...
                   intensity(pixel_x, pixel_y) >= intenthreshold &&...
                   chi(pixel_x, pixel_y) >= chimin &&...
                   chi(pixel_x, pixel_y) <= chimax)
                    numsigspinepixels = numsigspinepixels + 1;
                    if numsigspinepixels == 1
                        spinetotinten = intensity(pixel_x, pixel_y);
                        spinelifetime = lifetime(pixel_x, pixel_y);
                        spineavgchi = chi(pixel_x, pixel_y);
                    else
                        spinetotinten = spinetotinten + intensity(pixel_x, pixel_y);
                        spinelifetime = (spinelifetime * (spinetotinten - intensity(pixel_x, pixel_y)) + intensity(pixel_x, pixel_y)*lifetime(pixel_x, pixel_y)) / spinetotinten;
                        spineavgchi = ((numsigspinepixels-1)*spineavgchi + chi(pixel_x, pixel_y))/numsigspinepixels;
                    end
                end
        end

        densize = size(denpixels, 1);
        denlifetime = 0;
        dentotinten = 0;
        denavgchi = 0;
        numsigdenpixels = 0;
        denmatrix = zeros(1, densize);
        for i=1:densize;
                pixel_x = denpixels(i,2);
                pixel_y = denpixels(i,1);
                denmatrix(1,i) = lifetime(pixel_x, pixel_y);
                if(lifetime(pixel_x, pixel_y) >= lftthreshold &&...
                   intensity(pixel_x, pixel_y) >= intenthreshold &&...
                   chi(pixel_x, pixel_y) >= chimin &&...
                   chi(pixel_x, pixel_y) <= chimax)
                    numsigdenpixels = numsigdenpixels + 1;
                    if numsigdenpixels == 1
                        dentotinten = intensity(pixel_x, pixel_y);
                        denlifetime = lifetime(pixel_x, pixel_y);
                        denavgchi = chi(pixel_x, pixel_y);
                    else
                        dentotinten = dentotinten + intensity(pixel_x, pixel_y);
                        denlifetime = (denlifetime * (dentotinten - intensity(pixel_x, pixel_y)) + intensity(pixel_x, pixel_y)*lifetime(pixel_x, pixel_y)) / dentotinten;
                        denavgchi = ((numsigdenpixels-1)*denavgchi + chi(pixel_x, pixel_y))/numsigdenpixels;
                    end
                end
        end

        saveData(ID+1, 1) = ID;
        saveData(ID+1, 2) = spinelifetime;
        saveData(ID+1, 3) = spinetotinten;
        saveData(ID+1, 4) = numsigspinepixels;
        saveData(ID+1, 5) = denlifetime;
        saveData(ID+1, 6) = dentotinten;
        saveData(ID+1, 7) = numsigdenpixels;

        outputmsgbox = msgbox({horzcat('BoxID = ', num2str(ID), '.');...
                               horzcat('The weighted spine lifetime is ', num2str(spinelifetime), ' picoseconds.');...
                               horzcat('Total spine intensity is ', num2str(spinetotinten), ' photons.');...
                               horzcat('The average spine chi value is ', num2str(spineavgchi));...
                               horzcat('The weighted dendrite lifetime is ', num2str(denlifetime), ' picoseconds.');...
                               horzcat('Total dendrite intensity is ', num2str(dentotinten), ' photons.')
                               horzcat('The average dendrite chi value is ', num2str(denavgchi))}, 'Analysis');

        tempspinehisth = figure('Name', 'Histogram of spine pixels');
        tempspineaxesh = axes('Parent', tempspinehisth);
        spinebins = floor(spinesize^0.75);
        hist(tempspineaxesh, spinematrix, spinebins);

        tempdenhisth = figure('Name', 'Histogram of dendrite pixels');
        tempdenaxesh = axes('Parent', tempdenhisth);
        denbins = floor(densize^0.75);
        hist(tempdenaxesh, denmatrix, denbins);

        else
            errordlg('Spine / Dendrite pair does not exist!');
        end

end



function deletebox(deleteboxh, eventData)
        currentboxID = str2double(get(boxidh, 'String'));
        if(saveROI(currentboxID,1) ~= 0)
            for i=1:17
                saveROI(currentboxID,i) = 0;
            end
        drawROIs();

        else
            errordlg('Spine / Dendrite pair does not exist!');
        end

end



function drawROIs
        childrenlftimage = get(intimageaxesh, 'Children');
        clftimagesize = size(get(intimageaxesh,'Children'));

        for i=1:clftimagesize
            if childrenlftimage(i) ~= intimageh
                delete(childrenlftimage(i));
            end
        end

        for i=1:200
                if(saveROI(i,1) ~= 0)
                SpineVertex_x = [saveROI(i,2) saveROI(i,4) saveROI(i,6) saveROI(i,8) saveROI(i,2)];
                SpineVertex_y = [saveROI(i,3) saveROI(i,5) saveROI(i,7) saveROI(i,9) saveROI(i,3)];
                DenVertex_x = [saveROI(i,10) saveROI(i,12) saveROI(i,14) saveROI(i,16) saveROI(i,10)];
                DenVertex_y = [saveROI(i,11) saveROI(i,13) saveROI(i,15) saveROI(i,17) saveROI(i,11)];




                line(SpineVertex_x, SpineVertex_y, 'Color', 'r', 'Parent', intimageaxesh);
                text((saveROI(i,2)+saveROI(i,6))/2, (saveROI(i,3)+saveROI(i,7))/2, int2str(i), 'Parent', intimageaxesh, 'Color', 'r');

                line(DenVertex_x, DenVertex_y, 'Color', 'y', 'Parent', intimageaxesh);
                text((saveROI(i,10)+saveROI(i,14))/2, (saveROI(i,11)+saveROI(i,15))/2, int2str(i), 'Parent', intimageaxesh, 'Color', 'y');
                end
        end
end




function keypress(lifetimeimagewh, eventData)
    key = get(lifetimeimagewh, 'CurrentKey');

    currentboxID = str2double(get(boxidh, 'String'));
    selection = get(denspineh, 'Value');
    speed = get(movespeedh, 'Value');
    switch speed
        case 1
            speed = 1;
        case 2
            speed = 5;
        case 3
            speed = 1;
        case 4
            speed = 5;
    end

    if(saveROI(currentboxID,1) ~= 0)

        if(strcmp(key, 'uparrow')==1)
            if(selection == 1 && get(movespeedh, 'Value') < 3)
                saveROI(currentboxID, 11) = saveROI(currentboxID, 11)+speed;
                saveROI(currentboxID, 13) = saveROI(currentboxID, 13)+speed;
                saveROI(currentboxID, 15) = saveROI(currentboxID, 15)+speed;
                saveROI(currentboxID, 17) = saveROI(currentboxID, 17)+speed;
            elseif(selection == 2 && get(movespeedh, 'Value') < 3)
                saveROI(currentboxID, 3) = saveROI(currentboxID, 3)+speed;
                saveROI(currentboxID, 5) = saveROI(currentboxID, 5)+speed;
                saveROI(currentboxID, 7) = saveROI(currentboxID, 7)+speed;
                saveROI(currentboxID, 9) = saveROI(currentboxID, 9)+speed;
                elseif(selection == 1 && get(movespeedh, 'Value') >=3)
                for i=1:200
                    if(saveROI(i,1) ~= 0)
                        saveROI(i, 11) = saveROI(i, 11)+speed;
                        saveROI(i, 13) = saveROI(i, 13)+speed;
                        saveROI(i, 15) = saveROI(i, 15)+speed;
                        saveROI(i, 17) = saveROI(i, 17)+speed;
                    end
                end
            elseif(selection == 2 && get(movespeedh, 'Value') >=3)
                for i=1:200
                    if(saveROI(i,1) ~= 0)
                        saveROI(i, 3) = saveROI(i, 3)+speed;
                        saveROI(i, 5) = saveROI(i, 5)+speed;
                        saveROI(i, 7) = saveROI(i, 7)+speed;
                        saveROI(i, 9) = saveROI(i, 9)+speed;
                    end
                end
            end

        elseif(strcmp(key,'downarrow')==1)
            if(selection == 1 && get(movespeedh, 'Value') < 3)
                saveROI(currentboxID, 11) = saveROI(currentboxID, 11)-speed;
                saveROI(currentboxID, 13) = saveROI(currentboxID, 13)-speed;
                saveROI(currentboxID, 15) = saveROI(currentboxID, 15)-speed;
                saveROI(currentboxID, 17) = saveROI(currentboxID, 17)-speed;
            elseif(selection == 2 && get(movespeedh, 'Value') < 3)
                saveROI(currentboxID, 3) = saveROI(currentboxID, 3)-speed;
                saveROI(currentboxID, 5) = saveROI(currentboxID, 5)-speed;
                saveROI(currentboxID, 7) = saveROI(currentboxID, 7)-speed;
                saveROI(currentboxID, 9) = saveROI(currentboxID, 9)-speed;
            elseif(selection == 1 && get(movespeedh, 'Value') >=3)
                for i=1:200
                    if(saveROI(i,1) ~= 0)
                        saveROI(i, 11) = saveROI(i, 11)-speed;
                        saveROI(i, 13) = saveROI(i, 13)-speed;
                        saveROI(i, 15) = saveROI(i, 15)-speed;
                        saveROI(i, 17) = saveROI(i, 17)-speed;
                    end
                end
            elseif(selection == 2 && get(movespeedh, 'Value') >=3)
                for i=1:200
                    if(saveROI(i,1) ~= 0)
                        saveROI(i, 3) = saveROI(i, 3)-speed;
                        saveROI(i, 5) = saveROI(i, 5)-speed;
                        saveROI(i, 7) = saveROI(i, 7)-speed;
                        saveROI(i, 9) = saveROI(i, 9)-speed;
                    end
                end
            end

        elseif(strcmp(key,'leftarrow') == 1)
            if(selection == 1 && get(movespeedh, 'Value') < 3)
                saveROI(currentboxID, 10) = saveROI(currentboxID, 10)-speed;
                saveROI(currentboxID, 12) = saveROI(currentboxID, 12)-speed;
                saveROI(currentboxID, 14) = saveROI(currentboxID, 14)-speed;
                saveROI(currentboxID, 16) = saveROI(currentboxID, 16)-speed;
            elseif(selection == 2 && get(movespeedh, 'Value') < 3)
                saveROI(currentboxID, 2) = saveROI(currentboxID, 2)-speed;
                saveROI(currentboxID, 4) = saveROI(currentboxID, 4)-speed;
                saveROI(currentboxID, 6) = saveROI(currentboxID, 6)-speed;
                saveROI(currentboxID, 8) = saveROI(currentboxID, 8)-speed;
            elseif(selection == 1 && get(movespeedh, 'Value') >=3)
                for i=1:200
                    if(saveROI(i,1) ~= 0)
                        saveROI(i, 10) = saveROI(i, 10)-speed;
                        saveROI(i, 12) = saveROI(i, 12)-speed;
                        saveROI(i, 14) = saveROI(i, 14)-speed;
                        saveROI(i, 16) = saveROI(i, 16)-speed;
                    end
                end
            elseif(selection == 2 && get(movespeedh, 'Value') >=3)
                for i=1:200
                    if(saveROI(i,1) ~= 0)
                        saveROI(i, 2) = saveROI(i, 2)-speed;
                        saveROI(i, 4) = saveROI(i, 4)-speed;
                        saveROI(i, 6) = saveROI(i, 6)-speed;
                        saveROI(i, 8) = saveROI(i, 8)-speed;
                    end
                end
            end
        elseif(strcmp(key,'rightarrow') == 1)
            if(selection == 1 && get(movespeedh, 'Value') < 3)
                saveROI(currentboxID, 10) = saveROI(currentboxID, 10)+speed;
                saveROI(currentboxID, 12) = saveROI(currentboxID, 12)+speed;
                saveROI(currentboxID, 14) = saveROI(currentboxID, 14)+speed;
                saveROI(currentboxID, 16) = saveROI(currentboxID, 16)+speed;
            elseif(selection == 2 && get(movespeedh, 'Value') < 3)
                saveROI(currentboxID, 2) = saveROI(currentboxID, 2)+speed;
                saveROI(currentboxID, 4) = saveROI(currentboxID, 4)+speed;
                saveROI(currentboxID, 6) = saveROI(currentboxID, 6)+speed;
                saveROI(currentboxID, 8) = saveROI(currentboxID, 8)+speed;
            elseif(selection == 1 && get(movespeedh, 'Value') >=3)
                for i=1:200
                    if(saveROI(i,1) ~= 0)
                        saveROI(i, 10) = saveROI(i, 10)+speed;
                        saveROI(i, 12) = saveROI(i, 12)+speed;
                        saveROI(i, 14) = saveROI(i, 14)+speed;
                        saveROI(i, 16) = saveROI(i, 16)+speed;
                    end
                end
            elseif(selection == 2 && get(movespeedh, 'Value') >=3)
                for i=1:200
                    if(saveROI(i,1) ~= 0)
                        saveROI(i, 2) = saveROI(i, 2)+speed;
                        saveROI(i, 4) = saveROI(i, 4)+speed;
                        saveROI(i, 6) = saveROI(i, 6)+speed;
                        saveROI(i, 8) = saveROI(i, 8)+speed;
                    end
                end
            end
        end

        drawROIs();

    else
        errordlg('Spine / Dendrite pair does not exist!');
    end

end

%moves the selected box up (note:up is defined as +1 in the image, because
%the axes read from 0 upwards).
function moveboxup(moveboxuph, eventData)
    currentboxID = str2double(get(boxidh, 'String'));
    selection = get(denspineh, 'Value');
    speed = get(movespeedh, 'Value');
    switch speed
        case 1
            speed = 1;
        case 2
            speed = 5;
        case 3
            speed = 1;
        case 4
            speed = 5;
    end

    if(saveROI(currentboxID,1) ~= 0)

    if(selection == 1 && get(movespeedh, 'Value') < 3)
        saveROI(currentboxID, 11) = saveROI(currentboxID, 11)+speed;
        saveROI(currentboxID, 13) = saveROI(currentboxID, 13)+speed;
        saveROI(currentboxID, 15) = saveROI(currentboxID, 15)+speed;
        saveROI(currentboxID, 17) = saveROI(currentboxID, 17)+speed;
    elseif(selection == 2 && get(movespeedh, 'Value') < 3)
        saveROI(currentboxID, 3) = saveROI(currentboxID, 3)+speed;
        saveROI(currentboxID, 5) = saveROI(currentboxID, 5)+speed;
        saveROI(currentboxID, 7) = saveROI(currentboxID, 7)+speed;
        saveROI(currentboxID, 9) = saveROI(currentboxID, 9)+speed;
    elseif(selection == 1 && get(movespeedh, 'Value') >=3)
        for i=1:200
            if(saveROI(i,1) ~= 0)
                saveROI(i, 11) = saveROI(i, 11)+speed;
                saveROI(i, 13) = saveROI(i, 13)+speed;
                saveROI(i, 15) = saveROI(i, 15)+speed;
                saveROI(i, 17) = saveROI(i, 17)+speed;
            end
        end
    elseif(selection == 2 && get(movespeedh, 'Value') >=3)
        for i=1:200
            if(saveROI(i,1) ~= 0)
                saveROI(i, 3) = saveROI(i, 3)+speed;
                saveROI(i, 5) = saveROI(i, 5)+speed;
                saveROI(i, 7) = saveROI(i, 7)+speed;
                saveROI(i, 9) = saveROI(i, 9)+speed;
            end
        end
    end
    drawROIs();

    else
        errordlg('Spine / Dendrite pair does not exist!');
    end
end

function moveboxdown(moveboxdownh, eventData)
    currentboxID = str2double(get(boxidh, 'String'));
    selection = get(denspineh, 'Value');
    speed = get(movespeedh, 'Value');
    switch speed
        case 1
            speed = 1;
        case 2
            speed = 5;
        case 3
            speed = 1;
        case 4
            speed = 5;
    end

    if(saveROI(currentboxID,1) ~= 0)

    if(selection == 1 && get(movespeedh, 'Value') < 3)
        saveROI(currentboxID, 11) = saveROI(currentboxID, 11)-speed;
        saveROI(currentboxID, 13) = saveROI(currentboxID, 13)-speed;
        saveROI(currentboxID, 15) = saveROI(currentboxID, 15)-speed;
        saveROI(currentboxID, 17) = saveROI(currentboxID, 17)-speed;
    elseif(selection == 2 && get(movespeedh, 'Value') < 3)
        saveROI(currentboxID, 3) = saveROI(currentboxID, 3)-speed;
        saveROI(currentboxID, 5) = saveROI(currentboxID, 5)-speed;
        saveROI(currentboxID, 7) = saveROI(currentboxID, 7)-speed;
        saveROI(currentboxID, 9) = saveROI(currentboxID, 9)-speed;
    elseif(selection == 1 && get(movespeedh, 'Value') >=3)
        for i=1:200
            if(saveROI(i,1) ~= 0)
                saveROI(i, 11) = saveROI(i, 11)-speed;
                saveROI(i, 13) = saveROI(i, 13)-speed;
                saveROI(i, 15) = saveROI(i, 15)-speed;
                saveROI(i, 17) = saveROI(i, 17)-speed;
            end
        end
    elseif(selection == 2 && get(movespeedh, 'Value') >=3)
        for i=1:200
            if(saveROI(i,1) ~= 0)
                saveROI(i, 3) = saveROI(i, 3)-speed;
                saveROI(i, 5) = saveROI(i, 5)-speed;
                saveROI(i, 7) = saveROI(i, 7)-speed;
                saveROI(i, 9) = saveROI(i, 9)-speed;
            end
        end
    end
    drawROIs();

    else
        errordlg('Spine / Dendrite pair does not exist!');
    end
end

function moveboxleft(moveboxlefth, eventData)
    currentboxID = str2double(get(boxidh, 'String'));
    selection = get(denspineh, 'Value');
    speed = get(movespeedh, 'Value');
    switch speed
        case 1
            speed = 1;
        case 2
            speed = 5;
        case 3
            speed = 1;
        case 4
            speed = 5;
    end

    if(saveROI(currentboxID,1) ~= 0)

    if(selection == 1 && get(movespeedh, 'Value') < 3)
        saveROI(currentboxID, 10) = saveROI(currentboxID, 10)-speed;
        saveROI(currentboxID, 12) = saveROI(currentboxID, 12)-speed;
        saveROI(currentboxID, 14) = saveROI(currentboxID, 14)-speed;
        saveROI(currentboxID, 16) = saveROI(currentboxID, 16)-speed;
    elseif(selection == 2 && get(movespeedh, 'Value') < 3)
        saveROI(currentboxID, 2) = saveROI(currentboxID, 2)-speed;
        saveROI(currentboxID, 4) = saveROI(currentboxID, 4)-speed;
        saveROI(currentboxID, 6) = saveROI(currentboxID, 6)-speed;
        saveROI(currentboxID, 8) = saveROI(currentboxID, 8)-speed;
    elseif(selection == 1 && get(movespeedh, 'Value') >=3)
        for i=1:200
            if(saveROI(i,1) ~= 0)
                saveROI(i, 10) = saveROI(i, 10)-speed;
                saveROI(i, 12) = saveROI(i, 12)-speed;
                saveROI(i, 14) = saveROI(i, 14)-speed;
                saveROI(i, 16) = saveROI(i, 16)-speed;
            end
        end
    elseif(selection == 2 && get(movespeedh, 'Value') >=3)
        for i=1:200
            if(saveROI(i,1) ~= 0)
                saveROI(i, 2) = saveROI(i, 2)-speed;
                saveROI(i, 4) = saveROI(i, 4)-speed;
                saveROI(i, 6) = saveROI(i, 6)-speed;
                saveROI(i, 8) = saveROI(i, 8)-speed;
            end
        end
    end
    drawROIs();

    else
        errordlg('Spine / Dendrite pair does not exist!');
    end
end

function moveboxright(moveboxrighth, eventData)
    currentboxID = str2double(get(boxidh, 'String'));
    selection = get(denspineh, 'Value');
    speed = get(movespeedh, 'Value');
    switch speed
        case 1
            speed = 1;
        case 2
            speed = 5;
        case 3
            speed = 1;
        case 4
            speed = 5;
    end

    if(saveROI(currentboxID,1) ~= 0)

    if(selection == 1 && get(movespeedh, 'Value') < 3)
        saveROI(currentboxID, 10) = saveROI(currentboxID, 10)+speed;
        saveROI(currentboxID, 12) = saveROI(currentboxID, 12)+speed;
        saveROI(currentboxID, 14) = saveROI(currentboxID, 14)+speed;
        saveROI(currentboxID, 16) = saveROI(currentboxID, 16)+speed;
    elseif(selection == 2 && get(movespeedh, 'Value') < 3)
        saveROI(currentboxID, 2) = saveROI(currentboxID, 2)+speed;
        saveROI(currentboxID, 4) = saveROI(currentboxID, 4)+speed;
        saveROI(currentboxID, 6) = saveROI(currentboxID, 6)+speed;
        saveROI(currentboxID, 8) = saveROI(currentboxID, 8)+speed;
    elseif(selection == 1 && get(movespeedh, 'Value') >=3)
        for i=1:200
            if(saveROI(i,1) ~= 0)
                saveROI(i, 10) = saveROI(i, 10)+speed;
                saveROI(i, 12) = saveROI(i, 12)+speed;
                saveROI(i, 14) = saveROI(i, 14)+speed;
                saveROI(i, 16) = saveROI(i, 16)+speed;
            end
        end
    elseif(selection == 2 && get(movespeedh, 'Value') >=3)
        for i=1:200
            if(saveROI(i,1) ~= 0)
                saveROI(i, 2) = saveROI(i, 2)+speed;
                saveROI(i, 4) = saveROI(i, 4)+speed;
                saveROI(i, 6) = saveROI(i, 6)+speed;
                saveROI(i, 8) = saveROI(i, 8)+speed;
            end
        end
    end
    drawROIs();

    else
        errordlg('Spine / Dendrite pair does not exist!');
    end
end




function rotatebox(rotateh, eventData)
    currentboxID = str2double(get(boxidh, 'String'));
    selection = get(denspineh, 'Value');
    theta = 10;
    rotationmatrix = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];

    if(saveROI(currentboxID,1) ~= 0)

    if(selection == 1)
        denboxcenter_x = (saveROI(currentboxID, 10)+ saveROI(currentboxID, 14))/2;
        denboxcenter_y = (saveROI(currentboxID, 11)+ saveROI(currentboxID, 15))/2;

        for i=1:4
            vec_x = saveROI(currentboxID, 8+2*i) - denboxcenter_x;
            vec_y = saveROI(currentboxID, 9+2*i) - denboxcenter_y;

            newvec = [vec_x vec_y] * rotationmatrix;

            saveROI(currentboxID, 8+2*i) = denboxcenter_x + newvec(1,1);
            saveROI(currentboxID, 9+2*i) = denboxcenter_y + newvec(1,2);
        end
    else
        spineboxcenter_x = (saveROI(currentboxID, 2)+ saveROI(currentboxID, 6))/2;
        spineboxcenter_y = (saveROI(currentboxID, 3)+ saveROI(currentboxID, 7))/2;

        for i=1:4
            vec_x = saveROI(currentboxID, 2*i) - spineboxcenter_x;
            vec_y = saveROI(currentboxID, 1+2*i) - spineboxcenter_y;

            newvec = [vec_x vec_y] * rotationmatrix;

            saveROI(currentboxID, 2*i) = spineboxcenter_x + newvec(1,1);
            saveROI(currentboxID, 1+2*i) = spineboxcenter_y + newvec(1,2);
        end
    end
    drawROIs();

    else
        errordlg('Spine / Dendrite pair does not exist!');
    end

end




function saveROIs(saveROIh, eventData)

        finalROIlist = zeros(201, 33);

        finalROIlist(1, 1) = str2double(get(lftthresholdh, 'String'));
        finalROIlist(1, 3) = str2double(get(intenthresholdh, 'String'));
        finalROIlist(1, 5) = str2double(get(chiminh, 'String'));
        finalROIlist(1, 7) = str2double(get(chimaxh, 'String'));

        counter = 1;
        for i=1:200
            if(saveROI(i,1) ~= 0)
                for j=1:17;
                    finalROIlist(counter+1,2*j-1) = saveROI(i,j);
                end
                counter = counter + 1;
            end
        end

        cd(datadirectory);
        saveROIfilename = inputdlg('Enter a filename to save ROIs');
        ROIfilename = char(strcat(saveROIfilename));

        if size(ROIfilename) == 0
            errordlg('No filename entered. ROIs not saved.');
        else
        xlswrite(ROIfilename, finalROIlist);
            msgbox('ROIs saved successfully');
        end

        cd(home);

end



function saveFile(savefileh, eventData)

        lftthreshold = str2double(get(lftthresholdh, 'String'));
        intenthreshold = str2double(get(intenthresholdh, 'String'));
        chimin = str2double(get(chiminh, 'String'));
        chimax = str2double(get(chimaxh, 'String'));

        finalAnalysisList = zeros(201,13);
        finalAnalysisList(1,1) = str2double(get(lftthresholdh, 'String'));
        finalAnalysisList(1,3) = str2double(get(intenthresholdh, 'String'));
        finalAnalysisList(1,5) = str2double(get(chiminh, 'String'));
        finalAnalysisList(1,7) = str2double(get(chimaxh, 'String'));
        counter = 1;

        for ID=1:200
            if(saveROI(ID,1) ~=0)

            Spine_x = [saveROI(ID,2) saveROI(ID,4) saveROI(ID,6) saveROI(ID,8) saveROI(ID,2)];
            Spine_y = [saveROI(ID,3) saveROI(ID,5) saveROI(ID,7) saveROI(ID,9) saveROI(ID,3)];
            Den_x = [saveROI(ID,10) saveROI(ID,12) saveROI(ID,14) saveROI(ID,16) saveROI(ID,10)];
            Den_y = [saveROI(ID,11) saveROI(ID,13) saveROI(ID,15) saveROI(ID,17) saveROI(ID,11)];

            newspine = poly2mask(Spine_x, Spine_y, xdim, ydim);
            spinepixels = cell2mat(struct2cell(regionprops(newspine, 'PixelList')));

            newden = poly2mask(Den_x, Den_y, xdim, ydim);
            denpixels = cell2mat(struct2cell(regionprops(newden, 'PixelList')));

            spinesize = size(spinepixels, 1);
            spinelifetime = 0;
            spinetotinten = 0;
            spineavgchi = 0;
            numsigspinepixels = 0;
            for i=1:spinesize;
                pixel_x = spinepixels(i,2);
                pixel_y = spinepixels(i,1);
                if(lifetime(pixel_x, pixel_y) >= lftthreshold &&...
                   intensity(pixel_x, pixel_y) >= intenthreshold &&...
                   chi(pixel_x, pixel_y) >= chimin &&...
                   chi(pixel_x, pixel_y) <= chimax)
                    numsigspinepixels = numsigspinepixels + 1;
                    if numsigspinepixels == 1
                        spinetotinten = intensity(pixel_x, pixel_y);
                        spinelifetime = lifetime(pixel_x, pixel_y);
                        spineavgchi = chi(pixel_x, pixel_y);
                    else
                        spinetotinten = spinetotinten + intensity(pixel_x, pixel_y);
                        spinelifetime = (spinelifetime * (spinetotinten - intensity(pixel_x, pixel_y)) + intensity(pixel_x, pixel_y)*lifetime(pixel_x, pixel_y)) / spinetotinten;
                        spineavgchi = ((numsigspinepixels-1)*spineavgchi + chi(pixel_x, pixel_y))/numsigspinepixels;
                    end
                end
            end

            densize = size(denpixels, 1);
            denlifetime = 0;
            dentotinten = 0;
            denavgchi = 0;
            numsigdenpixels = 0;
            for i=1:densize;
                pixel_x = denpixels(i,2);
                pixel_y = denpixels(i,1);
                if(lifetime(pixel_x, pixel_y) >= lftthreshold &&...
                   intensity(pixel_x, pixel_y) >= intenthreshold &&...
                   chi(pixel_x, pixel_y) >= chimin &&...
                   chi(pixel_x, pixel_y) <= chimax)
                    numsigdenpixels = numsigdenpixels + 1;
                    if numsigdenpixels == 1
                        dentotinten = intensity(pixel_x, pixel_y);
                        denlifetime = lifetime(pixel_x, pixel_y);
                        denavgchi = chi(pixel_x, pixel_y);
                    else
                        dentotinten = dentotinten + intensity(pixel_x, pixel_y);
                        denlifetime = (denlifetime * (dentotinten - intensity(pixel_x, pixel_y)) + intensity(pixel_x, pixel_y)*lifetime(pixel_x, pixel_y)) / dentotinten;
                        denavgchi = ((numsigdenpixels-1)*denavgchi + chi(pixel_x, pixel_y))/numsigdenpixels;
                    end
                end
            end

            finalAnalysisList(counter+1, 1) = counter;
            finalAnalysisList(counter+1, 3) = spinelifetime;
            finalAnalysisList(counter+1, 5) = spinetotinten;
            finalAnalysisList(counter+1, 6) = spineavgchi;
            finalAnalysisList(counter+1, 7) = numsigspinepixels;
            finalAnalysisList(counter+1, 9) = denlifetime;
            finalAnalysisList(counter+1, 11) = dentotinten;
            finalAnalysisList(counter+1, 12) = denavgchi;
            finalAnalysisList(counter+1, 13) = numsigdenpixels;

            counter = counter + 1;
            end
        end

        cd(datadirectory);

%         currentdir = cd;
%         savedatdir = uigetdir;
%         cd(savedatdir);
%         cd(currentdir);


        defin = {tempfilename(1:end-4)};
        saveDatafilename = inputdlg('Enter a filename to save data','file name',1,defin);
        Datafilename = char(strcat(saveDatafilename));
        if size(Datafilename) == 0
            errordlg('No filename entered. Data not saved.');
        else
        xlswrite(Datafilename, finalAnalysisList);
            msgbox('Data saved successfully');
        end




        OpenFLIMdata = questdlg('Open FLIM data toolbox?', 'Open FLIM data toolbox?', 'Yes', 'No', 'No');
        switch OpenFLIMdataTool
           case 'Yes'
                assignin('base','CVSfile',Datafilename)
                assignin('base','FLIMdata',finalAnalysisList)
                disp('Welcome to the FLIM data toolbox')
                %edit FLIMdataToolbox.m
                %FLIMdataToolbox(Datafilename,finalAnalysisList,defin)
                FLIMdata(Datafilename,finalAnalysisList,defin)
                close all
           case 'No'
        end

        cd(home);


end



 function loadROIs(loadROIh, eventData)
        saveROI = zeros(200,17);
        % datadir = uigetdir;
        % cd(datadir);
        temp = csvread(uigetfile('*.csv'));

        cd(home);
        for i=2:201
            if temp(i,1)~=0
                for j=1:17
                saveROI(temp(i,1),j) = temp(i, 2*j-1);
                end
            end
        end
        drawROIs();

        prevlftthreshold = temp(1,1);
        previntthreshold = temp(1,3);
        prevchimin = temp(1,5);
        prevchimax = temp(1,7);

        set(lftthresholdh, 'String', num2str(prevlftthreshold));
        set(intenthresholdh, 'String', num2str(previntthreshold));
        set(chiminh, 'String', num2str(prevchimin));
        set(chimaxh, 'String', num2str(prevchimax));
        cd(home);
 end



function chithresholdviewer(chithresholdviewerh, eventData)
    chiminmaxanswer = inputdlg({'Enter chi min value', 'Enter chi max value'}, 'Chi threshold viewer', 1, {'0.5', '1.6'});
    chimin = str2num(cell2mat(chiminmaxanswer(1,1)));
    chimax = str2num(cell2mat(chiminmaxanswer(2,1)));
    chiviewer = zeros(xdim,ydim);
    for i=1:xdim,
        for j=1:ydim
            if chi(i,j)>= chimin && chi(i,j) <= chimax
                chiviewer(i,j) = 1;
            end
        end
    end
    chiviewerwh = figure('Name', 'Pixels that fall within the chi limits', 'Position', [210 110 550 450] );
    chivieweraxesh = axes('Parent', chiviewerwh, 'PlotBoxAspectRatio', [1 1 1]);
    chiviewerh = imagesc(chiviewer, 'Parent', chivieweraxesh);
    set(chiviewerwh, 'ColorMap', gray);
end



end

