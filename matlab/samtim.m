function varargout = samtim(varargin)
% SAMTIM MATLAB code for samtim.fig
%      SAMTIM, by itself, creates a new SAMTIM or raises the existing
%      singleton*.
%
%      H = SAMTIM returns the handle to a new SAMTIM or the handle to
%      the existing singleton*.
%
%      SAMTIM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAMTIM.M with the given input arguments.
%
%      SAMTIM('Property','Value',...) creates a new SAMTIM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before samtim_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to samtim_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help samtim

% Last Modified by GUIDE v2.5 19-Mar-2019 00:11:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @samtim_OpeningFcn, ...
                   'gui_OutputFcn',  @samtim_OutputFcn, ...
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
function s = rrcspan( beta )
if beta < 0.2
    s = 30;
elseif beta < 0.65
    s = -floor( beta*44 ) + 33;
    if mod(s,2) == 1
        s = s + 1;
    end
else
    s =  4;   
end

function myplot(handles)
if isfield( handles , 'data' )
    data = handles.data;
else
    return;
end
Nspan = rrcspan( handles.beta );
Nsps = ceil(get(handles.slider2 , 'Value' ));
B = rcosdesign(handles.beta , Nspan , Nsps , 'sqrt');
data = filter( B , 1 , data );

%Downconvert
data = hilbert( data );
t = linspace( 0 , (length(data)-1)/handles.fs , length(data) )';
fc = get(handles.slider1,'Value')*handles.fs;

carrier = exp(-1j*2*pi*fc*t);
data = data.*carrier;
plot(handles.axes1, t , real(data));
hold(handles.axes1,'on')
plot(handles.axes1, t , imag(data),'r');

% Sample at Tsym
start = get(handles.slider3 , 'Value' )/handles.fs;
xp = [ start : get(handles.slider2 , 'Value' )/handles.fs : t(end)  ];
syms = interp1( t , data , xp );

plot(handles.axes1, xp , real(syms),'b*');
plot(handles.axes1, xp , imag(syms),'r*');
hold(handles.axes1,'off')
plot(handles.axes3, real(syms) , imag(syms),'*');
axis(handles.axes3, [-1 1 -1 1]);


X = fftshift(fft(data));
w = linspace( -handles.fs*.5 , handles.fs*.5 , length(X ) )/1e3;
plot(handles.axes2, w , 10*log10(abs(X)));
xlim(handles.axes2,[-5 5])





% --- Executes just before samtim is made visible.
function samtim_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to samtim (see VARARGIN)

% Choose default command line output for samtim
handles.output = hObject;

% Update handles structure
handles.fs = 96e3;
handles.beta = 0.2;

guidata(hObject, handles);

% UIWAIT makes samtim wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = samtim_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
varname = get(handles.edit1, 'String' );
if isempty(varname)
    return;
end

try 
    handles.data = evalin( 'base' , varname );
catch
    return
end
guidata(hObject, handles);
myplot(handles);  


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
fc = get(hObject,'Value')*handles.fs;
set( handles.text2 , 'String' , ['CF: ' num2str(fc) ]);
myplot(handles);


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sps = get(hObject,'Value');
set( handles.text3 , 'String' , ['SPS: ' num2str(sps) ]);
myplot(handles);


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
tau = get(hObject,'Value');
set( handles.text4 , 'String' , ['TAU: ' num2str(tau) ]);
myplot(handles);


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
