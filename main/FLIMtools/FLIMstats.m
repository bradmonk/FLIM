%function [] = FLIMstats()
%=================================================
%% -- Change the current folder to the folder of this m-file.
clc; close all; clear all;
if(~isdeployed);
cd(fileparts(which(mfilename)));
disp(['Changing to the folder containing: ' fileparts(which(mfilename))])
end


disp('Welcome to the FLIM stats Toolbox')


%%

home = cd;
thisfile='FLIMstatsToolbox';
LookInFolder = uigetdir(thisfile);
flimcsvfiles = dir(fullfile(LookInFolder,'/*matdat.csv'));

[fppath,fpdir,fpext] = fileparts(LookInFolder);

for nn = 1:numel(flimcsvfiles)
    flimcsv{nn} = flimcsvfiles(nn).name;

    flimfile{nn} = [LookInFolder '/' flimcsvfiles(nn).name];

end



%% --- IMPORT DATA FROM FILE

cd(LookInFolder);

for nn = 1:numel(flimcsvfiles)
    [FLIMdat,delimOut]=importdata(flimfile{nn});
    FLIMdatas{nn} = FLIMdat;
end



%%
FLIMx = [];
for nn = 1:numel(flimcsvfiles)
    FLIMx = [FLIMx; FLIMdatas{nn}.data];
end

FLIMdat = FLIMx;
FLIMd = FLIMx;

%% --- ORGANIZE VARIABLES

% A1     B2   C3       D4  E5      F6    G7      H8  I9    J10  K11     L12   M13
% ROI    NA   sLife    NA  sIntsy  sChi  sPix    NA  dLife NA   dIntsy  dChi  dPixels
% LifCut NA   IntsyCut NA  ChiMin  NA    ChiMax  NA  NA    NA   NA      NA    NA


FLIMn.Names = {'ROI','sLife','sIntsy','sChi','sPix','dLife','dIntsy','dChi','dPix'};
FLIMs.ROI = FLIMd(:,1);
FLIMs.sLife = FLIMd(:,2);
FLIMs.sIntsy = FLIMd(:,3);
FLIMs.sChi = FLIMd(:,4);
FLIMs.sPix = FLIMd(:,5);
FLIMs.dLife = FLIMd(:,6);
FLIMs.dIntsy = FLIMd(:,7);
FLIMs.dChi = FLIMd(:,8);
FLIMs.dPix = FLIMd(:,9);
FLIMt = struct2table(FLIMs);
disp(FLIMt)



%% --- GET DESCRIPTIVE STATISTICS

Nvals = numel(FLIMs.sLife);

MUsLife = mean(FLIMs.sLife);
MUdLife = mean(FLIMs.dLife);
SDsLife = std(FLIMs.sLife);
SDdLife = std(FLIMs.dLife);
SEMsLife = SDsLife/sqrt(Nvals);
SEMdLife = SDdLife/sqrt(Nvals);

MUsIntsy = mean(FLIMs.sIntsy);
MUdIntsy = mean(FLIMs.dIntsy);
SDsIntsy = std(FLIMs.sIntsy);
SDdIntsy = std(FLIMs.dIntsy);
SEMsIntsy = SDsIntsy/sqrt(Nvals);
SEMdIntsy = SDdIntsy/sqrt(Nvals);

MUsChi = mean(FLIMs.sChi);
MUdChi = mean(FLIMs.dChi);
SDsChi = std(FLIMs.sChi);
SDdChi = std(FLIMs.dChi);
SEMsChi = SDsChi/sqrt(Nvals);
SEMdChi = SDdChi/sqrt(Nvals);

MUsPix = mean(FLIMs.sPix);
MUdPix = mean(FLIMs.dPix);
SDsPix = std(FLIMs.sPix);
SDdPix = std(FLIMs.dPix);
SEMsPix = SDsPix/sqrt(Nvals);
SEMdPix = SDdPix/sqrt(Nvals);

Mus = [0, MUsLife, MUsIntsy, MUsChi, MUsPix, MUdLife, MUdIntsy, MUdChi, MUdPix];

spn = sprintf('\n');

spf0 = sprintf(' set: % 7s ',fpdir);
spf1 = sprintf(' Mean % 7s  = % 5.5g \n',FLIMn.Names{2},Mus(2));
spf2 = sprintf(' Mean % 7s  = % 5.4g \n',FLIMn.Names{3},Mus(3));
spf3 = sprintf(' Mean % 7s  = % 5.3g \n',FLIMn.Names{4},Mus(4));
spf4 = sprintf(' Mean % 7s  = % 5.4g \n',FLIMn.Names{5},Mus(5));
spf5 = sprintf(' Mean % 7s  = % 5.5g \n',FLIMn.Names{6},Mus(6));
spf6 = sprintf(' Mean % 7s  = % 5.4g \n',FLIMn.Names{7},Mus(7));
spf7 = sprintf(' Mean % 7s  = % 5.3g \n',FLIMn.Names{8},Mus(8));
spf8 = sprintf(' Mean % 7s  = % 5.4g \n',FLIMn.Names{9},Mus(9));
disp([spn, spf0, spf1,spf2,spf3,spf4,spf5,spf6,spf7,spf8])



%%
close all;
clear fh1 hax1 hax2 hax3 hax4

    fh1 = figure(1);
    set(fh1,'OuterPosition',[300 200 1300 900],'Color',[1,1,1],'Tag','GUIfh')
    hax1 = axes('Position',[.04 .55 .30 .40],'Color','none','XTick',[]);
    hax2 = axes('Position',[.38 .55 .30 .40],'Color','none','XTick',[]);
    hax3 = axes('Position',[.04 .05 .30 .40],'Color','none','XTick',[]);
    hax4 = axes('Position',[.38 .05 .30 .40],'Color','none','XTick',[]);
    %hax1.NextPlot = 'add';


axes(hax1); hold(hax1, 'on')
    bh1 = bar([-1 1],[MUsLife 0], .8, 'parent', hax1, 'facecolor', 'r');
    bh2 = bar([-1 1],[0 MUdLife], .8, 'parent', hax1, 'facecolor', 'b');
    set(gca, 'XTick', [-1, 1], 'XTickLabel', {'Spine', 'Dendrite'},'FontSize',14)
    eh1 = errorbar([-1 1],[MUsLife MUdLife],[SEMsLife SEMdLife],'k.');
    eh1.LineWidth = 2; title('Fluorescent Lifetime');
    hax1.YLim(1) = round(hax1.YLim(2) / 1.6);
    hax1.YLim(2) = round(hax1.YLim(2) * 0.90);


axes(hax2); hold(hax2, 'on'); %set(fh1,'CurrentAxes',hax2);
    bh1 = bar([-1 1],[MUsIntsy 0], .8, 'parent', hax2, 'facecolor', 'r');
    bh2 = bar([-1 1],[0 MUdIntsy], .8, 'parent', hax2, 'facecolor', 'b');
    set(gca, 'XTick', [-1, 1], 'XTickLabel', {'Spine', 'Dendrite'},'FontSize',14)
    eh1 = errorbar([-1 1],[MUsIntsy MUdIntsy],[SEMsIntsy SEMdIntsy],'k.');
    eh1.LineWidth = 2; title('Intensity')


axes(hax3); hold(hax3, 'on')
    bh1 = bar([-1 1],[MUsChi 0], .8, 'parent', hax3, 'facecolor', 'r');
    bh2 = bar([-1 1],[0 MUdChi], .8, 'parent', hax3, 'facecolor', 'b');
    set(gca, 'XTick', [-1, 1], 'XTickLabel', {'Spine', 'Dendrite'},'FontSize',14)
    eh1 = errorbar([-1 1],[MUsChi MUdChi],[SEMsChi SEMdChi],'k.');
    eh1.LineWidth = 2; title('Chi^{2} Goodnesss of Fit')


axes(hax4); hold(hax4, 'on')
    bh1 = bar([-1 1],[MUsPix 0], .8, 'parent', hax4, 'facecolor', 'r');
    bh2 = bar([-1 1],[0 MUdPix], .8, 'parent', hax4, 'facecolor', 'b');
    set(gca, 'XTick', [-1, 1], 'XTickLabel', {'Spine', 'Dendrite'},'FontSize',14)
    eh1 = errorbar([-1 1],[MUsPix MUdPix],[SEMsPix SEMdPix],'k.');
    eh1.LineWidth = 2; title('Number of Pixels')



% --- SET ANNOTATION AREA & CREATE ANON FUNCTION FOR CON MESSAGING


SPsL = spf1; SPsI = spf2; SPsC = spf3; SPsP = spf4;
SPdL = spf5; SPdI = spf6; SPdC = spf7; SPdP = spf8;
str = {spf0,spn,SPsL,SPdL,spn,SPsI,SPdI,spn,SPsC,SPdC,spn,SPsP,SPdP};
ft = annotation(fh1,'textbox', [.75 .55 .2 .42],'String', str,'FontSize',14);
set(ft,'interpreter','none')



%% --- SAVE PROCESSED DATASET



if exist('csvfilename')
%save([csvfilename '_mat'], 'FLIMt')
str = csvfilename; expression = '.csv'; replace = '_';
newStr = regexprep(str,expression,replace);
writetable(FLIMt,[newStr 'matdat.csv'],'Delimiter',',')
else
promptTXT = {'ENTER A FILENAME TO SAVE DATA'}; dlg_title = 'Input'; num_lines = 1;
presetval = {'combinedata_'};
dlgOut = inputdlg(promptTXT,dlg_title,num_lines,presetval);

%save(dlgOut{1}, 'FLIMt')
writetable(FLIMt,[dlgOut{1} '.csv'],'Delimiter',',')
end




%=================================================
%end
%=================================================
%%




%% --- NOTES
%{
clc; close all; clear all;

% -- FIGURE SETUP FOR CON MESSAGING

% uiimport
dat = importdata('cs6-16div-np-n2.dat');

        datadirectory = [];
        home = cd;
        if size(datadirectory)~= 0
            cd(datadirectory);
        end
        [tempfilename datadir] = uigetfile('*.dat', 'load a .dat file');
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

            %set(intimagewh, 'Visible', 'On');

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

        %intimagewh = 512;
        intimagewh = figure(1);
        set(intimagewh,'OuterPosition',[300 200 1300 900],'Color',[1,1,1],'Tag','GUIfh')
        hax1 = axes('Position',[.05 .22 .44 .7],'Color','none','XTick',[],'YTick',[]);
        hax2 = axes('Position',[.53 .22 .44 .7],'Color','none','XTick',[],'YTick',[]);
        axes(hax1);

        %intimageh = imagesc(intensityimage, 'Parent', intimageaxesh, [prctile(intensityimage(:),83) prctile(intensityimage(:),95)]);

        intimageh = imagesc(intensityimage);

        set(intimagewh, 'Colormap', gray);







        set(boxsizeh, 'String', int2str(15));
        set(intenlowerinputh, 'String', int2str(prctile(intensityimage(:),83)));
        set(intenupperinputh, 'String', int2str(prctile(intensityimage(:),95)));
        set(lftthresholdh, 'String', int2str(1200));
        set(intenthresholdh, 'String', int2str(2));
        set(chiminh, 'String', num2str(0.7));
        set(chimaxh, 'String', num2str(2.0));
        cd(home);

        set(intimagewh, 'Name', tempfilename);
        set(boxidh, 'String', int2str(1));
        set(intimageaxesh, 'XLim', [1 xdim]);
        set(intimageaxesh, 'YLim', [1 ydim]);
    end


%%


trainingImageLabeler
ROIobs = positiveInstances.objectBoundingBoxes;





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


%%



fh1 = figure(1);
set(fh1,'OuterPosition',[300 200 1300 900],'Color',[1,1,1],'Tag','GUIfh')
hax1 = axes('Position',[.05 .22 .44 .7],'Color','none','XTick',[],'YTick',[]);
hax2 = axes('Position',[.53 .22 .44 .7],'Color','none','XTick',[],'YTick',[]);
% hax3 = axes('Position',[.05 .02 .9 .15],'Color','none','XTick',[],'YTick',[]);
% axes(hax1); set(Fh1,'CurrentAxes',hax1); get(hax3); %clf(GUIfh)


% -- SET ANNOTATION AREA & CREATE ANON FUNCTION FOR CON MESSAGING
sp=sprintf(' ');sp1=sprintf('>>'); sp2=sprintf('>>');sp3=sprintf('>>');sp4=sprintf('>>');
str = {' ', sp1,sp2,sp3,sp4};
ft = annotation(fh1,'textbox', [0.05,0.03,0.7,0.13],'String', str,'FontSize',14);
set(ft,'interpreter','none')


% WRITE LAUNCH SEQUENCE TO CON
for x = 1:5;
    %-----------------------------------------------CON-----------
    con(sprintf('>> launching in... % 6.4g ',6-x),.1,ft);
    %-------------------------------------------------------------
end





% -- IMPORT IMAGE

% [iFileName,iPathName] = uigetfile({'*.tif';'*.bmp';'*.jpg';'*.png'},'Select image file');
iFileName = 'Color Image of cs6-16div-np-n2.bmp';
[I,map] = imread(iFileName);   % get image data from file

    %-----------------------------------------------CON-----------
    con(sprintf('importing image: % s ',iFileName),1,ft);
    %-------------------------------------------------------------


    axes(hax1)
image(I)
    colormap(hax1,map)
    axis off; axis image;
    title('I size = (512,512,3)')

% imshow(I,map)
% imtool(I)

    %-----------------------------------------------CON-----------
    con(sprintf('resizing and flattening image'),0,ft);
    %-------------------------------------------------------------

    % colormap will be a 512x512 matrix of class double (values range from 0-1)
    iDUBs = im2double(I);
    iDUBs = imresize(iDUBs, [512 NaN]);
    iDUBs(iDUBs > 1) = 1;  % In rare cases resizing results in some pixel vals > 1
        szImg = size(iDUBs);

iDUB = iDUBs(:,:,1) + iDUBs(:,:,2) + iDUBs(:,:,3);

        axes(hax2)
    imagesc(iDUB)
        colormap(hax2,'hot')
        title('iDUB size = (512,512)')

    %-----------------------------------------------CON-----------
    con(sprintf('image is now: % s ',num2str(size(iDUB))),1,ft);
    %-------------------------------------------------------------


% %% GET ONLY STRONGEST CHANNEL
% if numel(szImg) == 3
% AveR = mean(mean(iDUBs(:,:,1))); AveG = mean(mean(iDUBs(:,:,2))); AveB = mean(mean(iDUBs(:,:,3)));
%     if AveR > AveG; iDUB = iDUBs(:,:,1); else iDUB = iDUBs(:,:,2); end
% end



    %-----------------------------------------------CON-----------
    con(sprintf('DRAW CIRCLE AROUND A SPINE'),0,ft);
    %-------------------------------------------------------------

    %hpanel = impixelregion(hax1);
    %set(hpanel, 'Position',[10 10 300 300])


%endloop=1; x = 0;
%figure(fh1,'DeleteFcn',@figDelete)



%%
while endloop

x = x+1;
disp(x)

pause(1)
end



        axes(hax1)
    eh1 = imellipse;

    pos1 = round(getPosition(eh1)); % [xmin ymin width height]



    %-----------------------------------------------CON-----------
    con(sprintf('Coordinates:'),.3,ft);
    con(sprintf('% 6.4g ',pos1),.3,ft);
    %-------------------------------------------------------------


% A = exist('fh1','var')


%%

clc; close all; clear all;

iFileName = 'Color Image of cs6-16div-np-n2.bmp';
[I,map] = imread(iFileName);

    Fh1 = figure(1);
    set(Fh1,'OuterPosition',[300 200 700 700],'Color',[1,1,1],'Tag','GUIfh')

    himage = imshow(I,map);

    Fh2 = figure(2);
        set(Fh2,'OuterPosition',[1000 200 400 400])

hpanel = impixelregionpanel(Fh2, himage);
    set(hpanel, 'Position', [.05 .05 .9 .9])


%copyobj(fh2.Children(1),fh1);
%copyobj(allchild(fh2),fh1);


%%

figure, imshow('cameraman.tif');
h = imellipse(gca, [10 10 10 10]);
addNewPositionCallback(h,@(p) title(mat2str(p,3)));
fcn = makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'YLim'));
setPositionConstraintFcn(h,fcn);



    disp('DRAW BOX AROUND A BACKGROUND AREA')
        axes(hax1)
    fh1 = imellipse;
    pos1 = round(getPosition(fh1)); % [xmin ymin width height]
    disp('done')




%% DRAW RUBBER BAND BOX AND THEN DRAG IT SOMEWHERE
clc; close all; clear all;
fh1 = figure(1);
ih = imshow('cameraman.tif');

iX = ih.XData; iY = ih.YData;

set(gcf,'Units','normalized')
k = waitforbuttonpress;
rect_pos = rbbox;
annotation('rectangle',rect_pos,'Color','red')

waitforbuttonpress
point1 = get(gcf,'CurrentPoint') % button down detected
% rect = [point1(1,1) point1(1,2) 30 30]
rect = round(iX(2) .* rect_pos)
[r2] = dragrect(rect)


%}
%{
%%
clc; close all; clear all;

load accidents hwydata
load 'accidents.mat'

usmean = ushwydata(4)/ushwydata(14);

%[hwydata hwyidx] = sortrows(hwydata,1);
% statelabel = statelabel(hwyidx);

plot(hwydata(:,14),hwydata(:,4),'.')


hf1 = figure;
plot(hwydata(:,14),hwydata(:,4));
xlabel(hwyheaders(14))
ylabel(hwyheaders(4))



line([min(hwydata(:,14)) max(hwydata(:,14))],...
     [min(hwydata(:,14))*usmean max(hwydata(:,14)*usmean)],...
      'Color','m');



hdt = datacursormode;
set(hdt,'DisplayStyle','window');
% Declare a custom datatip update function
% to display state names:
set(hdt,'UpdateFcn',{@labeldtips,hwydata,statelabel,usmean})

hf2 = figure
hist(hwydata(:,9),5)
xlabel(hwyheaders(9))


linkdata(hf1)
linkdata(hf2)


hf3 = figure;
load usapolygon
patch(uslon,uslat,[1 .9 .8],'Edgecolor','none');
hold on



scatter(hwydata(:,2),hwydata(:,3),36,'b','filled');
xlabel('Longitude')
ylabel('Latitude')
rectangle('Position',[-115,25,115-77,36-25],...
    'EdgeColor',[.75 .75 .75])

%}
