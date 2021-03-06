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

% Last Modified by GUIDE v2.5 22-Aug-2019 10:31:41

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
% Update handles structure
handles.order = 2;
handles.orderhaschanged = false;
N = str2double( get(handles.ed_nsym,'String') );
symbols = randi( handles.order , N , 1) - 1;
handles.bb = qammod( symbols , 2 , 'UnitAveragePower', true );
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

function fpt = tapesync( rf , input )
%Estimate parameters from real passband signal
% and knowledge of:
%  Nominal omega  (center freq)
%  - " -   alpha  (samples per symbol)
%  p(k)    Pilot symbol(s)
%  s       Pilot spacing


% alpha_hat = alpha*(1-(omega_hat-omega)/omega)


fpt = length(rf);

function e = qpsk_magnitude_error( rf , param , input)
%

idx_start = 800;
omega_hat = param(1);
tau_hat = param(2);
phi_hat = param(3);

lo = cexp(-omega_hat, input.fs , length(rf) );
rf = rf.*lo;

bb = interp1( bb , [1+input.tau : 1 : length(bb) ] );




%Compute the error
   

function myplot(handles,flag)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup
if nargin < 2
    AUTO = false;
elseif strcmp(flag,'auto')
    AUTO = true;
else
    AUTO = false;
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input
input.fs = 96e3;
input.fup = str2double( get(handles.ed_fup,'String') );
input.fdw = input.fup*(1 + get(handles.sl_cfo,'Value')/1000);


order = handles.order;
Nsym = str2double( get(handles.ed_nsym,'String') );

if get(handles.cb_rndsym , 'Value') > 0.
    symbols = randi( order , Nsym , 1) - 1;
else
    symbols = mod([0:Nsym-1]', order );
    %symbols = 2*ones(Nsym,1);
end

if handles.orderhaschanged
    if order == 8
        input.bb = exp(1j*22.5*pi/180)*pskmod( symbols , order , 0 , 'gray' );
        mag = 1.0;
    else
        input.bb = qammod( symbols , order , 'UnitAveragePower', true );
        % Zero:th symbol always in lower left corner
        mag = 1.25*abs( qammod(0, order , 'UnitAveragePower', true ) );        
    end
    %Insert pilot symbols
    if get(handles.rb_pilot,'Value') > 0
        if order == 8
            input.bb(1:10:end) = mag*exp(1j*0*pi/180);
        else
            % "A New Design of Pilot Symbol in 16QAM Channels" 
%            psym = [ -1j*mag 1*mag ];
            psym = [ -1j*mag ];       
            input.bb = insert_vector( input.bb , psym , 15 , true);
            
        end
    end
    handles.bb = input.bb;
    handles.orderhaschanged = false;    
else
    input.bb = handles.bb;
end

input.snr = get(handles.sl_snr,'Value');
input.sps = str2double( get(handles.ed_nsps,'String') );

input.var0 = get(handles.sl_cpn,'Value')*0.015; %DRM800-A == 1.0
input.var3 = get(handles.sl_cpn,'Value')*0.0045;
input.beta = get(handles.sl_beta,'Value');
input.rrcspan = rrcspan( input.beta );
input.tau = get(handles.sl_tau,'Value');
input.phi = get(handles.sl_cpo,'Value');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Printing
cstr = cell(7,1);
cstr{1} = ['Symbol rate : ' num2str(input.fs/input.sps/1e3,'%5.2f') ' kbaud' ];
cstr{2} = ['Bitrate     : ' num2str(input.fs/input.sps*log2(order)/1e3,'%5.2f') ' kbps' ];
cstr{3} = ['OBW         : ' ...
    num2str((1.0+get(handles.sl_beta,'Value'))*input.fs/input.sps/1e3,'%5.2f') ' kHz' ];
cstr{4} = ['BER         : ' ];
cstr{5} = ['EVM         : ' ];
cstr{6} = ['RRC#        : ' num2str(input.sps*input.rrcspan+1) ];

%Change sps according to SRO
sps =  1/(1+get(handles.sl_cfo,'Value')/1000)*input.sps;

cstr{7} = ['SPS         : ' num2str( sps , '%5.3f' ) ];

cstr{4} = ['FDW         : ' num2str( input.fdw , '%5.3f' ) ];
cstr{8} = ['PWR         : ' num2str( 0 , '%5.3f' ) ];


set(handles.txt_data,'String',cstr);
set(handles.uipanel2,'Title',['Fs: ' num2str(input.fs/1e3) ' kHz']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Selection
if isfield(handles,'meabb') && get(handles.rb_measured,'Value')
    rf = handles.meabb(:);
    %%% CHANNEL
    %BFIR = fir2(12,[linspace(0,.25,7) .3 1],[linspace(1,2.,7) 1 1]);
    %rf = filter(BFIR,1,rf);
    %%%%%%%%%%%
    rf_tmp = rf; %Save for later
    t = linspace(0,(length(rf)-1)/input.fs,length(rf))';
    rf = hilbert( rf );
    carrier = exp(-1j*(2*pi*input.fdw*t + input.phi/180*pi));
    bb = rf.*carrier;
    rf = rf_tmp;
    Nsym = floor(length(bb)/input.sps);
    
    %Filter
    Brrc = rcosdesign( input.beta , input.rrcspan , input.sps , 'sqrt');
    bb = filter( Brrc , 1 , bb );

    if input.tau > 0.0
        bb = interp1( bb , [1+input.tau : 1 : length(bb) ] );
    end
else
    [bb,rf] = tapebb( input );
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimation
if AUTO
    fpt = tapesync( rf );    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting

% Axes1
i = [1:length(bb)]';
Nsym = min( [Nsym floor( (length(bb)-input.sps*input.rrcspan)/input.sps) ] );

idx = [ input.rrcspan*input.sps+1 : sps :...
    input.sps*( input.rrcspan + Nsym ) ]';
intbb = interp1( i , bb , idx );
%Now we have baseband so print power

cstr{8} = ['PWR         : ' num2str( sum(intbb.*conj(intbb))/length(intbb) , '%6.4f' ) ];
set(handles.txt_data,'String',cstr);

lim1 = get(handles.axes1,{'xlim','ylim'});  % Get axes limits.


%plot(handles.axes1,...
%    i,real(bb),i,imag(bb),idx,real(bb(idx)),'b*',idx,imag(bb(idx)),'r*')
plot(handles.axes1, i , real(bb) , i , imag(bb) );
hold( handles.axes1 , 'on' );
plot(handles.axes1 , idx , real(intbb) , 'b*' , idx , imag(intbb), 'r*' );
hold( handles.axes1 , 'off' );

xmin = max([idx(1)-2*input.sps 1]);
xmax = i(end);
xlim(handles.axes1, [xmin xmax ])
ymin = min([-max(abs(real(bb))) -max(abs(imag(bb)))])*1.1;
ymax= -ymin;
ylim(handles.axes1, [ymin ymax])
grid(handles.axes1, 'on')
if get(handles.cb_keep_zoom,'Value') > 0.0
    set(handles.axes1,{'xlim','ylim'},lim1);
end
legend( handles.axes1 , 'RE' , 'IM' )

% Axes2
if strcmp( get(handles.tb_const,'String') , 'Const' )
%if true
    cla(handles.axes2,'reset');
    yyaxis(handles.axes2, 'right');
    yyaxis(handles.axes2, 'left');
    cla(handles.axes2);
    lim2 = get(handles.axes2,{'xlim','ylim'});  % Get axes limits.
    
    plot(handles.axes2, intbb , '*' );
    rmax = max(abs(real(intbb)));
    imax = max(abs(imag(intbb)));
    rmax = max([rmax imax])*1.1;
    
    
    xlim(handles.axes2, [-rmax rmax])
    ylim(handles.axes2, [-rmax rmax])
    grid(handles.axes2, 'on')
    if get(handles.cb_keep_zoom,'Value') > 0.0
        set(handles.axes2,{'xlim','ylim'},lim2);
    end    
else
    %eyediagram( handles.axes2 , bb , input.sps );
    cla(handles.axes2,'reset');
    yyaxis(handles.axes2, 'left');
    plot(handles.axes2, abs(intbb) , 'b-*' );
    xlim(handles.axes2, [1 length(idx)])
    yyaxis(handles.axes2, 'right');
    lim2 = get(handles.axes2,{'xlim','ylim'});  % Get axes limits.    
%    plot(handles.axes2, 180/pi*unwrap(angle(intbb)) , 'r-*' );
    plot(handles.axes2, 180/pi*angle(intbb) , 'r-*' );
    xlim(handles.axes2, [1 length(idx)])
    grid(handles.axes2, 'on')
    legend( handles.axes2 , 'ABS' , 'PHA' , 'Location' , 'north')
    
    if get(handles.cb_keep_zoom,'Value') > 0.0
        set(handles.axes2,{'xlim','ylim'},lim2);
    end    
    
end



% Axes3
if strcmp( get(handles.tb_time_freq,'String') , 'Time' )
    lim3 = get(handles.axes3,{'xlim','ylim'});  % Get axes limits.    
    plot(handles.axes3, rf );
    xlim(handles.axes3, [0 length(rf)])
    ylim(handles.axes3, [-1.1*max(rf) 1.1*max(rf)])
    grid(handles.axes3, 'on')
    if get(handles.cb_keep_zoom,'Value') > 0.0
        set(handles.axes3,{'xlim','ylim'},lim3);
    end  
elseif strcmp( get(handles.tb_time_freq,'String') , 'Freq' )
    %[pxx,w]= pwelch(rf(idx(1):idx(end)),[],[],[],96,'centered');
    [pxx,w]= pwelch(rf,[],[],[],96,'onesided');
    plot(handles.axes3, w, 10*log10(pxx) );
    xlim(handles.axes3, [0 48])
    grid(handles.axes3, 'on')
else
    %Early Late
    sps = input.sps;
    len = length(bb(sps:end-3*sps*5))-1;
    eld = real( conj( bb(sps:end-3*sps*5) ) .*...
        ( bb(3*sps/2: 3*sps/2+len ) - bb(sps/2: sps/2+len) ));
    plot(handles.axes3, eld );    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

guidata(gcbo, handles);




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
str = ['Epsilon: ' num2str( get(hObject,'Value') , '%4.2f' ) ];
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
str = ['Carrier PN: ' num2str( get(hObject,'Value') , '%4.2f' ) ];
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
str = ['Timing Error: ' num2str( get(hObject,'Value') , '%4.2f' ) ];
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


% --- Executes on button press in tb_time_freq.
function tb_time_freq_Callback(hObject, eventdata, handles)
% hObject    handle to tb_time_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tb_time_freq
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
    handles.order = 2;
elseif get(hObject,'Value') == 2
    handles.order = 4;
elseif get(hObject,'Value') == 3
    handles.order = 8;
elseif get(hObject,'Value') == 4
    handles.order = 16;
elseif get(hObject,'Value') == 5
    handles.order = 64;
elseif get(hObject,'Value') == 6
    handles.order = 256;
elseif get(hObject,'Value') == 7
    handles.order = 1024;
end
handles.orderhaschanged = true;
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
elseif sym > 4096
    sym = 4096;
    set(hObject,'String','4096');
elseif isnan(sym)
    sym = 8;
    set(hObject,'String','8');
end
handles.orderhaschanged = true;
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

if get(handles.sl_tau,'Value') > sps
    set(handles.sl_tau,'Value' , sps);
    str = ['Timing Error: ' num2str( sps , '%4.2f' ) ];
    set(handles.txt_tau,'String' , str );
end
set(handles.sl_tau,'Max',sps);
set(handles.sl_tau,'SliderStep',[.05/sps  .5/sps ]);

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


% --- Executes on button press in rb_pilot.
function rb_pilot_Callback(hObject, eventdata, handles)
% hObject    handle to rb_pilot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_pilot
if get(hObject,'Value') < 1
    set( handles.sl_pt_pwr , 'Enable' , 'off' );
    set( handles.sl_pt_freq , 'Enable' , 'off' );
else
    set( handles.sl_pt_pwr , 'Enable' , 'on' );
    set( handles.sl_pt_freq , 'Enable' , 'on' );
end
handles.orderhaschanged = true;
guidata(hObject, handles);
myplot(handles);



function ed_fup_Callback(hObject, eventdata, handles)
% hObject    handle to ed_fup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_fup as text
%        str2double(get(hObject,'String')) returns contents of ed_fup as a double
fup = str2num(get(hObject,'String'));
fup = round(fup);
if fup < 0
    fup = 0;
    set(hObject,'String','0');
elseif fup > 48000
    fup = 48000;
    set(hObject,'String','48000');
end
myplot(handles);


% --- Executes during object creation, after setting all properties.
function ed_fup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_fup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_var_Callback(hObject, eventdata, handles)
% hObject    handle to ed_var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_var as text
%        str2double(get(hObject,'String')) returns contents of ed_var as a double
str = get(hObject,'String');
handles.meabb = evalin('base',str);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function ed_var_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rb_measured.
function rb_measured_Callback(hObject, eventdata, handles)
% hObject    handle to rb_measured (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_measured
%if get(hObject,'Value') > 0
    myplot(handles);
%end


% --- Executes on button press in tb_const.
function tb_const_Callback(hObject, eventdata, handles)
% hObject    handle to tb_const (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tb_const
if get(hObject,'Value') == 0
    %Enabled for freq domain
    set(hObject,'String','Const');
else
    set(hObject,'String','Eye');
end
myplot(handles);


% --- Executes on button press in cb_keep_zoom.
function cb_keep_zoom_Callback(hObject, eventdata, handles)
% hObject    handle to cb_keep_zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_keep_zoom


% --- Executes on button press in cb_rndsym.
function cb_rndsym_Callback(hObject, eventdata, handles)
% hObject    handle to cb_rndsym (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_rndsym
handles.orderhaschanged = true;
guidata(hObject, handles);
myplot(handles);


% --- Executes on button press in pb_auto.
function pb_auto_Callback(hObject, eventdata, handles)
% hObject    handle to pb_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myplot(handles,'auto')


% --- Executes on button press in cb_applychannel.
function cb_applychannel_Callback(hObject, eventdata, handles)
% hObject    handle to cb_applychannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_applychannel



function ed_droop_Callback(hObject, eventdata, handles)
% hObject    handle to ed_droop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_droop as text
%        str2double(get(hObject,'String')) returns contents of ed_droop as a double


% --- Executes during object creation, after setting all properties.
function ed_droop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_droop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
