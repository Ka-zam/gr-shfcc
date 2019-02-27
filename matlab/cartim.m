function varargout = cartim(varargin)
% CARTIM MATLAB code for cartim.fig
%      CARTIM, by itself, creates a new CARTIM or raises the existing
%      singleton*.
%
%      H = CARTIM returns the handle to a new CARTIM or the handle to
%      the existing singleton*.
%
%      CARTIM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CARTIM.M with the given input arguments.
%
%      CARTIM('Property','Value',...) creates a new CARTIM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cartim_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cartim_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cartim

% Last Modified by GUIDE v2.5 26-Feb-2019 22:24:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cartim_OpeningFcn, ...
                   'gui_OutputFcn',  @cartim_OutputFcn, ...
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


% --- Executes just before cartim is made visible.
function cartim_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cartim (see VARARGIN)

% Choose default command line output for cartim
handles.output = hObject;
M = 4;
Nsym = 200;
handles.arity = 4;
handles.Nsym = Nsym;
handles.Nsps = 8;
handles.symbols = randi( M , Nsym , 1) - 1;
%Just make sure to start a I=-1 Q=1
handles.symbols(1:5) = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cartim wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cartim_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function myplot(handles)
% snr = get(handles.sl_snr,'Value');
% beta = get(handles.sl_beta,'Value');
% m = handles.arity;
% syms = handles.symbols;
% nsym = handles.Nsym;
% nsps = handles.Nsps;
[bb,idx] = bb_sample(...
    handles.Nsps,...
    handles.Nsym,...
    handles.symbols,...
    get(handles.sl_snr,'Value'),...
    handles.arity,...
    get(handles.sl_beta,'Value'),...
    get(handles.sl_cfo,'Value'),...
    get(handles.sl_cpo,'Value'),...
    get(handles.sl_cpn,'Value'),...
    get(handles.sl_tau,'Value'));
%[bb,idx] = bb_sample(nsps,nsym,syms,snr,m,beta,0,0,0,0);
i = [1:length(bb)]';
plot(handles.axes1,...
    i,real(bb),i,imag(bb),idx,real(bb(idx)),'b*',idx,imag(bb(idx)),'r*')
xlim(handles.axes1, [idx(1)-2*handles.Nsps idx(end)+2*handles.Nsps])
ylim(handles.axes1, [-1.5 1.5])
grid(handles.axes1, 'on')

plot(handles.axes2, bb(idx) , '*' );
xlim(handles.axes2, [-1.5 1.5])
ylim(handles.axes2, [-1.5 1.5])
grid(handles.axes2, 'on')

[pxx,w]= pwelch(bb(idx(1):idx(end)),[],[],[],96,'centered');
plot(handles.axes3, w, 10*log10(pxx) );




% --- Executes on slider movement.
function sl_snr_Callback(hObject, eventdata, handles)
% hObject    handle to sl_snr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
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


% --- Executes on slider movement.
function sl_beta_Callback(hObject, eventdata, handles)
% hObject    handle to sl_beta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
myplot(handles);



% --- Executes during object creation, after setting all properties.
function sl_beta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sl_beta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sl_cfo_Callback(hObject, eventdata, handles)
% hObject    handle to sl_cfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
myplot(handles);


% --- Executes during object creation, after setting all properties.
function sl_cfo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sl_cfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sl_cpo_Callback(hObject, eventdata, handles)
% hObject    handle to sl_cpo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
myplot(handles);


% --- Executes during object creation, after setting all properties.
function sl_cpo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sl_cpo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sl_cpn_Callback(hObject, eventdata, handles)
% hObject    handle to sl_cpn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
myplot(handles);


% --- Executes during object creation, after setting all properties.
function sl_cpn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sl_cpn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sl_tau_Callback(hObject, eventdata, handles)
% hObject    handle to sl_tau (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
myplot(handles);


% --- Executes during object creation, after setting all properties.
function sl_tau_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sl_tau (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider7_Callback(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
