function varargout = trackRGB(varargin)
% TRACKRGB MATLAB code for trackRGB.fig
%      TRACKRGB, by itself, creates a new TRACKRGB or raises the existing
%      singleton*.
%
%      H = TRACKRGB returns the handle to a new TRACKRGB or the handle to
%      the existing singleton*.
%
%      TRACKRGB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKRGB.M with the given input arguments.
%
%      TRACKRGB('Property','Value',...) creates a new TRACKRGB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trackRGB_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trackRGB_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trackRGB

% Last Modified by GUIDE v2.5 06-Dec-2022 18:18:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trackRGB_OpeningFcn, ...
                   'gui_OutputFcn',  @trackRGB_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before trackRGB is made visible.
function trackRGB_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trackRGB (see VARARGIN)

% Choose default command line output for trackRGB
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes trackRGB wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = trackRGB_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonr.

function buttonr_Callback(hObject, eventdata, handles)

% hObject    handle to buttonr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    stimaqreset;
imaqreset;
clear all;
clc;
cla;

% 使用视频输入功能捕获视频帧
vid = videoinput('winvideo', 1, 'YUY2_640x480');
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb')
vid.FrameGrabInterval = 1;
start(vid)
red=[];
%参数初始化
%采样时间参数
%初始化控制器相关信号
x=[0,0,0];
xdu_1=0;
xu_1=0;
x_1=0;

y=[0,0,0];
ydu_1=0;
yu_1=0;
y_1=0;
%初始化前两个时间单元的误差信号
xerror_2=0;xerror_1=0;
yerror_2=0;yerror_1=0;
% 颜色追踪主程序循环
while(1)
    % 获取当前帧的快照
    data = getsnapshot(vid);
    % 现在实时跟踪红色对象
    % 我们必须减去红色分量
    % 以提取图像中的红色成分
    diff_im = imsubtract(data(:,:,1), rgb2gray(data));
    %使用中值滤波器滤除噪声
    diff_im = medfilt2(diff_im, [3 3]);
    % 将生成的灰度图像转换为二进制图像。
    diff_im = im2bw(diff_im,0.10);
    % 删除所有小于300px的像素
    diff_im = bwareaopen(diff_im,300);
    % 标记图像中所有连接的物体
    bw = bwlabel(diff_im, 8);
    % 这里我们进行图像斑点分析
    % 我们得到每个标记区域的一组属性
    stats = regionprops(bw, 'BoundingBox', 'Centroid');
    % 显示图像
    imshow(data)
    hold on

    

%预置存储空间
xtime=zeros(1,length(stats));
xrin=zeros(1,length(stats));
xa=zeros(1,length(stats));
xout=zeros(1,length(stats));
xerror=zeros(1,length(stats));
xkp=zeros(1,length(stats));
xki=zeros(1,length(stats));
xkd=zeros(1,length(stats));
xdu=zeros(1,length(stats));
xu=zeros(1,length(stats));

ytime=zeros(1,length(stats));
yrin=zeros(1,length(stats));
ya=zeros(1,length(stats));
yout=zeros(1,length(stats));
yerror=zeros(1,length(stats));
ykp=zeros(1,length(stats));
yki=zeros(1,length(stats));
ykd=zeros(1,length(stats));
ydu=zeros(1,length(stats));
yu=zeros(1,length(stats));

    %这是将红色物体锁定在红色矩形框中的循环
    for k =1:1:length(stats)
        
        bb  = stats(k).BoundingBox;
        bc = stats(k).Centroid;
        rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
        plot(bc(1),bc(2), '-m+')
        a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
        set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
        red=[red;bc];
        
        
 xtime(k)=k;
 xrin(k)=bc(1);
 %被控制对象的非线性模型
 xout(k)=x_1+xu_1;
 xerror(k)=xrin(k)-xout(k);
 x(1)=xerror(k)-xerror_1;
 x(2)=xerror(k);
 x(3)=xerror(k)-2*xerror_1+xerror_2;
 xepid=[x(1);x(2);x(3)];
 xkp(k)=0.6;
 xki(k)=0.3;
 xkd(k)=0.1;
 xKpid=[xkp(k),xki(k),xkd(k)];
 xdu(k)=xKpid*xepid;
 xu(k)=xu_1+xdu(k)+0.05*rand(1);
 %参数更新
 xdu_1=xdu(k);
 xu_1=xu(k);
 x_1=xout(k);
 xerror_2=xerror_1;xerror_1=xerror(k);
 
 ytime(k)=k;
 yrin(k)=bc(2);
 %被控制对象的非线性模型
 yout(k)=y_1+yu_1;
 yerror(k)=yrin(k)-yout(k);
 y(1)=yerror(k)-yerror_1;
 y(2)=yerror(k);
 y(3)=yerror(k)-2*yerror_1+yerror_2;
 yepid=[y(1);y(2);y(3)];
 ykp(k)=0.6;
 yki(k)=0.3;
 ykd(k)=0.1;
 yKpid=[ykp(k),yki(k),ykd(k)];
 ydu(k)=yKpid*yepid;
 yu(k)=yu_1+ydu(k)+0.05*rand(1);
 %参数更新
 ydu_1=ydu(k);
 yu_1=yu(k);
 y_1=yout(k);
 yerror_2=yerror_1;yerror_1=yerror(k);
 
 plot(xout(k),yout(k),'-b.','MarkerSize',10);

    end
    hold off
    flushdata(vid);
    
end
% 两个循环都在这里结束。
% 停止视频采集。
stop(vid);

% 刷新存储在内存缓冲区中的所有图像数据。
flushdata(vid);





% --- Executes on button press in buttong.
function buttong_Callback(hObject, eventdata, handles)
% hObject    handle to buttong (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imaqreset;
clear all;
clc;
cla;

% Capture the video frames using the videoinput function

% You have to replace the resolution & your installed adaptor name.
vid = videoinput('winvideo', 1, 'YUY2_640x480');

% Set the properties of the video object
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb')
vid.FrameGrabInterval = 1;

%start the video aquisition here
start(vid)
green=[];

%参数初始化
%采样时间参数
%初始化控制器相关信号
x2=[0,0,0];
y2=[0,0,0];
%du_2=0;
x_2=0;
y_2=0;
xu_2=0;
yu_2=0;
%初始化前两个时间单元的误差信号
xerror2_2=0;xerror2_1=0;
yerror2_2=0;yerror2_1=0;
% 颜色追踪主程序循环

% Set a loop that runs until interrupter externally (ctrl+c)
while(1)
    % Get the snapshot of the current frame
    data = getsnapshot(vid);
    
    % Now to track red objects in real time
    % we have to subtract the red component 
    % from the grayscale image to extract the red components in the image.
    diff_im2 = imsubtract(data(:,:,2), rgb2gray(data));
    %Use a median filter to filter out noise
    diff_im2 = medfilt2(diff_im2, [3 3]);
    
%     figure(5),imshow(diff_im);
    % Convert the resulting grayscale image into a binary image.
    diff_im2 = imbinarize(diff_im2,0.10);
    
    % Remove all those pixels less than 300px
    diff_im2 = bwareaopen(diff_im2,300);
    
    % Label all the connected components in the image.
    bw2 = bwlabel(diff_im2, 8);
    
    % Here we do the image blob analysis.
    % We get a set of properties for each labeled region.
    stats2 = regionprops(bw2, 'BoundingBox', 'Centroid');
    
    % Display the image
    imshow(data)
    
    %预置存储空间
    hold on
    
xtime2=zeros(1,length(stats2));
xrin2=zeros(1,length(stats2));
xa2=zeros(1,length(stats2));
xyout2=zeros(1,length(stats2));
xerror2=zeros(1,length(stats2));
xkp2=zeros(1,length(stats2));
xki2=zeros(1,length(stats2));
xkd2=zeros(1,length(stats2));
xdu2=zeros(1,length(stats2));
xu2=zeros(1,length(stats2));

ytime2=zeros(1,length(stats2));
yrin2=zeros(1,length(stats2));
ya2=zeros(1,length(stats2));
yyout2=zeros(1,length(stats2));
yerror2=zeros(1,length(stats2));
ykp2=zeros(1,length(stats2));
yki2=zeros(1,length(stats2));
ykd2=zeros(1,length(stats2));
ydu2=zeros(1,length(stats2));
yu2=zeros(1,length(stats2));

    %This is a loop to bound the red objects in a rectangular box.
    for k2 = 1:1:length(stats2)
        bb2 = stats2(k2).BoundingBox;
        bc2 = stats2(k2).Centroid;
        rectangle('Position',bb2,'EdgeColor','g','LineWidth',2)
        plot(bc2(1),bc2(2), '-m+')
        a2=text(bc2(1)+15,bc2(2), strcat('X: ', num2str(round(bc2(1))), '    Y: ', num2str(round(bc2(2)))));
        set(a2, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
        green=[green;bc2];
        
        
 xtime2(k2)=k2;
 xrin2(k2)=bc2(1);
 %被控制对象的非线性模型
 xout2(k2)=x_2+xu_2;
 xerror2(k2)=xrin2(k2)-xout2(k2);
 x2(1)=xerror2(k2)-xerror2_1;
 x2(2)=xerror2(k2);
 x2(3)=xerror2(k2)-2*xerror2_1+xerror2_2;
 xepid2=[x2(1);x2(2);x2(3)];
 xkp2(k2)=0.6;
 xki2(k2)=0.3;
 xkd2(k2)=0.1;
 xKpid2=[xkp2(k2),xki2(k2),xkd2(k2)];
 xdu2(k2)=xKpid2*xepid2;
 xu2(k2)=xu_2+xdu2(k2)+0.05*rand(1);
 %参数更新
 xdu_2=xdu2(k2);
 xu_2=xu2(k2);
 x_2=xout2(k2);
 xerror2_2=xerror2_1;xerror2_1=xerror2(k2);

 ytime2(k2)=k2;
 yrin2(k2)=bc2(2);
 %被控制对象的非线性模型
 yout2(k2)=y_2+yu_2;
 yerror2(k2)=yrin2(k2)-yout2(k2);
 y2(1)=yerror2(k2)-yerror2_1;
 y2(2)=yerror2(k2);
 y2(3)=yerror2(k2)-2*yerror2_1+yerror2_2;
 yepid2=[y2(1);y2(2);y2(3)];
 ykp2(k2)=0.6;
 yki2(k2)=0.3;
 ykd2(k2)=0.1;
 yKpid2=[ykp2(k2),yki2(k2),ykd2(k2)];
 ydu2(k2)=yKpid2*yepid2;
 yu2(k2)=yu_2+ydu2(k2)+0.05*rand(1);
 %参数更新
 ydu_2=ydu2(k2);
 yu_2=yu2(k2);
 y_2=yout2(k2);
 yerror2_2=yerror2_1;yerror2_1=yerror2(k2)

 plot(xout2(k2),yout2(k2),'-b.','MarkerSize',10);
 %disp(yout2(k2));
    end
    
    hold off
    flushdata(vid);
end

% --- Executes on button press in buttonb.
function buttonb_Callback(hObject, eventdata, handles)
% hObject    handle to buttonb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imaqreset;
clear all;
clc;
cla;


% Capture the video frames using the videoinput function

% You have to replace the resolution & your installed adaptor name.
vid = videoinput('winvideo', 1, 'YUY2_640x480');

% Set the properties of the video object
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb')
vid.FrameGrabInterval = 1;

%start the video aquisition here
start(vid)
blue=[];

%参数初始化
%采样时间参数
%初始化控制器相关信号
x3=[0,0,0];
y3=[0,0,0];
xdu_3=0;
xu_3=0;
x_3=0;
yu_3=0;
ydu_3=0;
y_3=0;
%初始化前两个时间单元的误差信号
xerror3_2=0;xerror3_1=0;
yerror3_2=0;yerror3_1=0;
% 颜色追踪主程序循环
% Set a loop that runs until interrupter externally (ctrl+c)
while(1)
    % Get the snapshot of the current frame
    data = getsnapshot(vid);
    
    % Now to track red objects in real time
    % we have to subtract the red component 
    % from the grayscale image to extract the red components in the image.
    diff_im3 = imsubtract(data(:,:,3), rgb2gray(data));
    %Use a median filter to filter out noise
    diff_im3 = medfilt2(diff_im3, [3 3]);
    
%     figure(5),imshow(diff_im);
    % Convert the resulting grayscale image into a binary image.
    diff_im3 = imbinarize(diff_im3,0.10);
    
    % Remove all those pixels less than 300px
    diff_im3 = bwareaopen(diff_im3,300);
    
    % Label all the connected components in the image.
    bw3 = bwlabel(diff_im3, 8);
    
    % Here we do the image blob analysis.
    % We get a set of properties for each labeled region.
    stats3 = regionprops(bw3, 'BoundingBox', 'Centroid');
    
    % Display the image
    imshow(data)
    
    hold on
    
xtime3=zeros(1,length(stats3));
xrin3=zeros(1,length(stats3));
xa3=zeros(1,length(stats3));
xyout3=zeros(1,length(stats3));
xerror3=zeros(1,length(stats3));
xkp3=zeros(1,length(stats3));
xki3=zeros(1,length(stats3));
xkd3=zeros(1,length(stats3));
xdu3=zeros(1,length(stats3));
xu3=zeros(1,length(stats3));

ytime3=zeros(1,length(stats3));
yrin3=zeros(1,length(stats3));
ya3=zeros(1,length(stats3));
yyout3=zeros(1,length(stats3));
yerror3=zeros(1,length(stats3));
ykp3=zeros(1,length(stats3));
yki3=zeros(1,length(stats3));
ykd3=zeros(1,length(stats3));
ydu3=zeros(1,length(stats3));
yu3=zeros(1,length(stats3));
    %This is a loop to bound the red objects in a rectangular box.
    for k3 = 1:1:length(stats3)
        bb3 = stats3(k3).BoundingBox;
        bc3 = stats3(k3).Centroid;
        rectangle('Position',bb3,'EdgeColor','b','LineWidth',2)
        plot(bc3(1),bc3(2), '-m+')
        a3=text(bc3(1)+15,bc3(2), strcat('X: ', num2str(round(bc3(1))), '    Y: ', num2str(round(bc3(2)))));
        set(a3, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
        blue=[blue;bc3];
        
 xtime3(k3)=k3;
 xrin3(k3)=bc3(1);
 %被控制对象的非线性模型
 xyout3(k3)=x_3+xu_3;
 xerror3(k3)=xrin3(k3)-xyout3(k3);
 x3(1)=xerror3(k3)-xerror3_1;
 x3(2)=xerror3(k3);
 x3(3)=xerror3(k3)-2*xerror3_1+xerror3_2;
 xepid3=[x3(1);x3(2);x3(3)];
 xkp3(k3)=0.6;
 xki3(k3)=0.3;
 xkd3(k3)=0.1;
 xKpid3=[xkp3(k3),xki3(k3),xkd3(k3)];
 xdu3(k3)=xKpid3*xepid3;
 xu3(k3)=xu_3+xdu3(k3)+0.05*rand(1);
 %参数更新
 xdu_3=xdu3(k3);
 xu_3=xu3(k3);
 x_3=xyout3(k3);
 xerror3_2=xerror3_1;xerror3_1=xerror3(k3);

 ytime3(k3)=k3;
 yrin3(k3)=bc3(2);
 %被控制对象的非线性模型
 yyout3(k3)=y_3+yu_3;
 yerror3(k3)=yrin3(k3)-yyout3(k3);
 y3(1)=yerror3(k3)-yerror3_1;
 y3(2)=yerror3(k3);
 y3(3)=yerror3(k3)-2*yerror3_1+yerror3_2;
 yepid3=[y3(1);y3(2);y3(3)];
 ykp3(k3)=0.6;
 yki3(k3)=0.3;
 ykd3(k3)=0.1;
 yKpid3=[ykp3(k3),yki3(k3),ykd3(k3)];
 ydu3(k3)=yKpid3*yepid3;
 yu3(k3)=yu_3+ydu3(k3)+0.05*rand(1);
 %参数更新
 ydu_3=ydu3(k3);
 yu_3=yu3(k3);
 y_3=yyout3(k3);
 yerror3_2=yerror3_1;yerror3_1=yerror3(k3);


 %plot(xout(k),yout(k),'-b.','MarkerSize',10);
 plot(xyout3(k3),yyout3(k3),'-b.','MarkerSize',10);
 %disp(yout3(k3));
    end
    
    hold off
    flushdata(vid);
end



% --- Executes on button press in shexiangtou.
function shexiangtou_Callback(hObject, eventdata, handles)
% hObject    handle to shexiangtou (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vid = videoinput('winvideo', 1, 'YUY2_640x480');
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb')
vid.FrameGrabInterval = 1;
usbVidRes1=get(vid,'videoResolution');
nBands1=get(vid,'NumberOfBands');%'NumberOfBands'
axes(handles.axes1);
hImage1=imshow(zeros(usbVidRes1(2),usbVidRes1(1),nBands1));
preview(vid,hImage1);


% --- Executes on button press in jieshu.
function jieshu_Callback(hObject, eventdata, handles)
% hObject    handle to jieshu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all;
clear all;
objects = imaqfind;
stop(objects);
