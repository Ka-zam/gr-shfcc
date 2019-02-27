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

% Last Modified by GUIDE v2.5 27-Feb-2019 15:32:07

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
handles.arity = 4;
handles.Nsym = 200;
handles.Nsps = 8;
handles.symbols = randi( handles.arity , handles.Nsym , 1) - 1;
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
fs=96;
cstr = cell(4,1);
cstr{1} = ['Symbol rate : ' num2str(fs/handles.Nsps) ' kbaud' ];
cstr{2} = ['Bitrate     : ' num2str(fs/handles.Nsps*log2(handles.arity)) ' kbps' ];
cstr{3} = ['OBW         : ' ...
    num2str((1.0+get(handles.sl_beta,'Value'))*fs/handles.Nsps,'%5.2f') ' kHz' ];
cstr{4} = ['BER         : ' ];
cstr{5} = ['EVM         : ' ];
set(handles.txt_data,'String',cstr);
[bb,idx,rf] = bb_sample(...
    handles.Nsps,...
    handles.Nsym,...
    handles.symbols,...
    get(handles.sl_snr,'Value'),...
    handles.arity,...
    get(handles.sl_beta,'Value'),...
    get(handles.sl_cfo,'Value'),...
    get(handles.sl_cpo,'Value'),...
    get(handles.sl_cpn,'Value'),...
    get(handles.sl_tau,'Value'),...
    get(handles.sl_pt_pwr,'Value'),...
    get(handles.sl_pt_freq,'Value')...
    );
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

if strcmp( get(handles.bt_time_freq,'String') , 'Time' )
    plot(handles.axes3, rf );
    xlim(handles.axes3, [0 length(rf)])
    ylim(handles.axes3, [-1.2 1.2])
    grid(handles.axes3, 'on')
else
    %[pxx,w]= pwelch(bb(idx(1):idx(end)),[],[],[],96,'centered');
    [pxx,w]= pwelch(rf(idx(1):idx(end)),[],[],[],96,'centered');
    plot(handles.axes3, w, 10*log10(pxx) );
    xlim(handles.axes3, [-48 48])
    grid(handles.axes3, 'on')
end



% --- Executes on slider movement.
function sl_snr_Callback(hObject, eventdata, handles)
% hObject    handle to sl_snr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
str = ['SNR: ' num2str( get(hObject,'Value') , '%4.1f' ) ' dB' ];
set(handles.txt_snr,'String',str);
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
str = ['Excess BW: ' num2str( get(hObject,'Value') , '%4.2f' ) ];
set(handles.txt_exbw,'String',str);
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
str = ['Carrier freq: ' num2str( get(hObject,'Value') , '%4.2f' ) ];
set(handles.txt_cfo,'String',str);
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
str = ['Carrier phase: ' num2str( get(hObject,'Value') , '%4.0f' ) ' deg' ];
set(handles.txt_cpo,'String',str);
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
str = ['Carrier PN: ' num2str( get(hObject,'Value') , '%4.2f' ) ' deg' ];
set(handles.txt_cpn,'String',str);
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
str = ['Timing Error: ' num2str( get(hObject,'Value') , '%4.1f' ) ];
set(handles.txt_tau,'String',str);
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
function sl_pt_pwr_Callback(hObject, eventdata, handles)
% hObject    handle to sl_pt_pwr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
str = ['Pilot pwr: ' num2str( get(hObject,'Value') , '%4.1f' ) ' dB' ];
set(handles.txt_pt_pwr,'String',str);
myplot(handles);

% --- Executes during object creation, after setting all properties.
function sl_pt_pwr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sl_pt_pwr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in bt_time_freq.
function bt_time_freq_Callback(hObject, eventdata, handles)
% hObject    handle to bt_time_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bt_time_freq
if get(hObject,'Value') == 1
    %Enabled for freq domain
    set(hObject,'String','Freq');
else
    set(hObject,'String','Time');
end
myplot(handles);


% --- Executes on slider movement.
function sl_pt_freq_Callback(hObject, eventdata, handles)
% hObject    handle to sl_pt_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
str = ['Pilot freq: ' num2str( get(hObject,'Value') , '%4.2f' ) ];
set(handles.txt_pt_freq,'String',str);
myplot(handles);

% --- Executes during object creation, after setting all properties.
function sl_pt_freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sl_pt_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in lb_modulation.
function lb_modulation_Callback(hObject, eventdata, handles)
% hObject    handle to lb_modulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lb_modulation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lb_modulation
if get(hObject,'Value') == 1
    handles.arity = 2;
elseif get(hObject,'Value') == 2
    handles.arity = 4;
elseif get(hObject,'Value') == 3
    handles.arity = 8;
elseif get(hObject,'Value') == 4
    handles.arity = 16;
elseif get(hObject,'Value') == 5
    handles.arity = 64;
elseif get(hObject,'Value') == 6
    handles.arity = 256;
elseif get(hObject,'Value') == 7
    handles.arity = 1024;
end
handles.symbols = randi( handles.arity , handles.Nsym , 1) - 1;
guidata(hObject, handles);
myplot(handles);


% --- Executes during object creation, after setting all properties.
function lb_modulation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb_modulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_nsym_Callback(hObject, eventdata, handles)
% hObject    handle to ed_nsym (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_nsym as text
%        str2double(get(hObject,'String')) returns contents of ed_nsym as a double

sym = str2num(get(hObject,'String'));
sym = round(sym);
if sym < 6
    sym = 6;
    set(hObject,'String','6');
elseif sym > 1000
    sym = 1000;
    set(hObject,'String','1000');
end
handles.Nsym = sym;
handles.symbols = randi( handles.arity , handles.Nsym , 1) - 1;
guidata(hObject, handles);
myplot(handles);


% --- Executes during object creation, after setting all properties.
function ed_nsym_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_nsym (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_nsps_Callback(hObject, eventdata, handles)
% hObject    handle to ed_nsps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_nsps as text
%        str2double(get(hObject,'String')) returns contents of ed_nsps as a double
sps = str2num(get(hObject,'String'));
sps = round(sps);
if sps < 2
    sps = 2;
    set(hObject,'String','2');
elseif sps > 100
    sps = 100;
    set(hObject,'String','100');    
end
handles.Nsps = sps;
guidata(hObject, handles);
myplot(handles);


% --- Executes during object creation, after setting all properties.
function ed_nsps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_nsps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
