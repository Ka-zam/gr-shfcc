function varargout = phadif(varargin)
% PHADIF MATLAB code for phadif.fig
%      PHADIF, by itself, creates a new PHADIF or raises the existing
%      singleton*.
%
%      H = PHADIF returns the handle to a new PHADIF or the handle to
%      the existing singleton*.
%
%      PHADIF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHADIF.M with the given input arguments.
%
%      PHADIF('Property','Value',...) creates a new PHADIF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before phadif_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to phadif_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help phadif

% Last Modified by GUIDE v2.5 06-Apr-2019 11:22:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @phadif_OpeningFcn, ...
                   'gui_OutputFcn',  @phadif_OutputFcn, ...
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

function myplot(handles)
snr = get(handles.sl_snr , 'Value' );
amp = get(handles.sl_amp , 'Value' );
pha = get(handles.sl_pha , 'Value' );
x1 = cexp(1,10,100,snr);
x2 = cexp(1,10,100,snr)*amp*exp(1j*pha/180*pi);
xc = xcorr(x2,x1);

xc2 = ifft( fft(x1,200) .* conj(fft(x2,200)) );
%xc2 = ifft( fft(x1) .* conj(fft(x2)) );

pd1 = phasediff(x2,x1,100)*180/pi;


plot(handles.axes2 , abs(xc) );
hold(handles.axes2,'on')
plot(handles.axes2 , abs(xc2) );
hold(handles.axes2,'off')


plot(handles.axes1 , real([x1 x2] ) );

fac = amest(x1);
%Do filtering
%[tmpb,tmpa] = ellip(3,.5,20,.05);
%[b,a]= iirlp2xn(tmpb,tmpa,[-.05 .05],[ -.15 -.05]);
%x3 = filter(10*b,a,x1);
%x4 = filter(10*b,a,x2);
%hold(handles.axes1,'on')
%plot(handles.axes1 , real([x3 x4] ) );
%hold(handles.axes1,'off')

%xc = xcorr(x4,x3);

pd2 = angle(xc2(1))*180/pi;


s = {  ['Phase difference  : ' num2str(pd1) ] ,...
       ['Phase difference 2: ' num2str(pd2) ] ,...
       ['Est. frequency: ' num2str(fac(1)) ] };
set( handles.txt_res , 'String' , s);



% --- Executes just before phadif is made visible.
function phadif_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to phadif (see VARARGIN)

% Choose default command line output for phadif
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes phadif wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = phadif_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sl_amp_Callback(hObject, eventdata, handles)
% hObject    handle to sl_amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set( handles.ed_amp , 'String' , num2str(get(hObject,'Value')) );
myplot(handles);

% --- Executes during object creation, after setting all properties.
function sl_amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sl_amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function ed_amp_Callback(hObject, eventdata, handles)
% hObject    handle to ed_amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_amp as text
%        str2double(get(hObject,'String')) returns contents of ed_amp as a double
set( handles.sl_amp , 'Value' , get(hObject,'Value') );
myplot(handles);

% --- Executes during object creation, after setting all properties.
function ed_amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sl_pha_Callback(hObject, eventdata, handles)
% hObject    handle to sl_pha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set( handles.ed_pha , 'String' , num2str(get(hObject,'Value')) );
myplot(handles);

% --- Executes during object creation, after setting all properties.
function sl_pha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sl_pha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function ed_pha_Callback(hObject, eventdata, handles)
% hObject    handle to ed_pha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_pha as text
%        str2double(get(hObject,'String')) returns contents of ed_pha as a double
set( handles.sl_pha , 'Value' , get(hObject,'Value') );
myplot(handles);
% --- Executes during object creation, after setting all properties.
function ed_pha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_pha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sl_snr_Callback(hObject, eventdata, handles)
% hObject    handle to sl_snr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set( handles.ed_snr , 'String' , num2str(get(hObject,'Value')) );
myplot(handles);


% --- Executes during object creation, after setting all properties.
function sl_snr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sl_snr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function ed_snr_Callback(hObject, eventdata, handles)
% hObject    handle to ed_snr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_snr as text
%        str2double(get(hObject,'String')) returns contents of ed_snr as a double
set( handles.sl_snr , 'Value' , get(hObject,'Value') );
myplot(handles);

% --- Executes during object creation, after setting all properties.
function ed_snr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_snr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
