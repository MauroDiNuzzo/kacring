% Name:           KacRing.m
% Description:    A Matlab implementation of the Kac Ring.
% Author:         Mauro Di Nuzzo
% Version:        1.0
% Last modified:  2018-06-30
% Source code:    Freely available.
% License:        BSD License.


function KacRing

global quit_flag
global state

quit_flag = 0;
state = -1; % -1: stop/reset, 0: pause; 1: start/continue

pause('on');

global figure_handler

figure_handler = figure(1);
clf;

set(figure_handler, 'renderer', 'opengl');

background_color = 0.93*[1, 1, 1];

set(figure_handler, 'color', background_color);
set(figure_handler, 'NumberTitle', 'off');
set(figure_handler, 'doublebuffer', 'on');
set(figure_handler, 'Name', 'Kac Ring');
set(figure_handler, 'Units', 'normalized');
set(figure_handler, 'menubar', 'none');
set(figure_handler, 'toolbar', 'none');
set(figure_handler, 'Position', [0.05 0.1 0.9 0.8]);
set(figure_handler, 'InvertHardcopy', 'off');

set(figure_handler, 'CloseRequestFcn', @closerequest);

uicontrol(figure_handler, 'Style','text', 'Fontsize', 8, ...
    'backgroundcolor', background_color, ...    
    'HorizontalAlignment','right', 'Units','normalized', ...
    'Position',[0.65 0 0.3 0.04],'string','Kac Ring (C) 2018 by Mauro DiNuzzo');
      

panel_plots_handler = uipanel('Title','Plots', 'Units','normalized', ...
    'backgroundcolor', background_color, ...
    'Fontsize', 12, ...
    'Position',[0.5  0.05 0.45 0.9]);

global axis_handler_1 axis_handler_2 axis_handler_time

axis_handler_1 = subplot(6, 1, [1, 2, 3], 'Parent', panel_plots_handler, 'XColor', 'none');
ylabel('\Delta(t)');

axis_handler_2 = subplot(6, 1, [4, 5], 'Parent', panel_plots_handler, 'XColor', 'none');
ylabel('\mu');

axis_handler_time = subplot(6, 1, 6, 'Parent', panel_plots_handler, 'Color', 'none', 'YColor', 'none');
xlabel('Time step (#)');
axis([0 1 0 1]);
pos = get(axis_handler_time, 'Position');
set(axis_handler_time, 'Position', [pos(1), pos(2)+0.8*pos(4), pos(3), pos(4)]);


set(axis_handler_1, 'sortmethod' , 'depth'); 
set(axis_handler_2, 'sortmethod' , 'depth'); 


uicontrol(panel_plots_handler, 'Style','pushbutton', 'Fontsize', 10, 'Units','normalized', ...
          'Position',[0.15  0.03 0.15 0.04],...
          'String','Start/Continue','Callback','global state; state=1;');
uicontrol(panel_plots_handler, 'Style','pushbutton', 'Fontsize', 10, 'Units','normalized', ...
          'Position',[0.31  0.03 0.15 0.04],...
          'String','Pause','Callback','global state; state=0;');
uicontrol(panel_plots_handler, 'Style','pushbutton', 'Fontsize', 10, 'Units','normalized', ...
          'Position',[0.47  0.03 0.20 0.04],...
          'String','Stop/Reset - Save','Callback','global state; state=-1;');
uicontrol(panel_plots_handler, 'Style','pushbutton', 'Fontsize', 10, 'Units','normalized', ...
          'Position',[0.78  0.03 0.1 0.04],...
          'String','Quit','Callback','global quit_flag; quit_flag=1;');


      
panel_parameters_handler = uipanel('Title','Model parameters', 'Units','normalized', ...
    'backgroundcolor', background_color, ...    
        'Fontsize', 12, ...
          'Position',[0.05  0.77 0.44 0.18]);     

global n N
global param_handler_n param_handler_N

N = 30; % default
n = 10; % default

global max_N max_N_for_draw_ring
max_N = 10000;
max_N_for_draw_ring = 50;

uicontrol(panel_parameters_handler, 'Style','text', 'Fontsize', 10, ...
    'backgroundcolor', background_color, ...     
    'HorizontalAlignment','left', 'Units','normalized', ...
          'Position',[0.05 0.65 0.2 0.15],'string','Lattice sites (N)');
param_handler_N = uicontrol(panel_parameters_handler, 'Style','edit','Fontsize', 10,'HorizontalAlignment','left', 'Units','normalized', ...
          'Position',[0.25 0.6 0.1 0.25],...
          'string',num2str(N),'tag','N','Callback',@change_parameters);       
      
uicontrol(panel_parameters_handler, 'Style','text', 'Fontsize', 10, ...
    'backgroundcolor', background_color, ...     
    'HorizontalAlignment','left', 'Units','normalized', ...
          'Position',[0.05 0.3 0.2 0.15],'string','Markers (n, n<N)');
param_handler_n = uicontrol(panel_parameters_handler, 'Style','edit','Fontsize', 10,'HorizontalAlignment','left', 'Units','normalized', ...
          'Position',[0.25 0.25 0.1 0.25],...
          'string',num2str(n),'Callback',@change_parameters);       

uicontrol(panel_parameters_handler, 'Style','pushbutton', 'Fontsize', 10, 'Units','normalized', ...
          'Position',[0.4  0.25 0.15 0.25],...
          'String','Set','Callback',@change_parameters);     
            
global fraction_black 
global text_handler_fraction_black param_handler_fraction_black

fraction_black = 100; % default

uicontrol(panel_parameters_handler, 'Style','text', 'Fontsize', 10, ...
    'backgroundcolor', background_color, ...     
    'HorizontalAlignment','left', 'Units','normalized', ...
          'Position',[0.4 0.65 0.5 0.15],'string','Initial state (% black balls)');   
text_handler_fraction_black = uicontrol(panel_parameters_handler, 'Style','text', 'Fontsize', 10, ...
    'backgroundcolor', background_color, ...     
    'HorizontalAlignment','left', 'Units','normalized', ...
          'Position',[0.92 0.65 0.5 0.15],'string',[num2str(fraction_black, '%d'),'%']);       
param_handler_fraction_black = uicontrol(panel_parameters_handler, 'Style','slider', 'BackgroundColor', 'w', 'Units','normalized', ...
          'Position',[0.7  0.6 0.2 0.25],...
          'min',0,'max',100,...
          'value',fraction_black, 'callback',@change_parameters);

      
      
      
panel_simulation_handler = uipanel('Title','Simulation', 'Units','normalized', ...
    'backgroundcolor', background_color, ...    
        'Fontsize', 12, ...
          'Position',[0.05  0.05 0.44 0.70]);       
 
global param_handler_speed speed
speed = 1; % default

uicontrol(panel_simulation_handler, 'Style','text', 'Fontsize', 10, ...
    'backgroundcolor', background_color, ...     
    'HorizontalAlignment','center', 'Units','normalized', ...
          'Position',[0.7 0.08 0.2 0.05],'string','Ring rotation speed'); 
uicontrol(panel_simulation_handler, 'Style','text', 'Fontsize', 8, ...
    'backgroundcolor', background_color, ...     
    'HorizontalAlignment','right', 'Units','normalized', ...
          'Position',[0.5 0.03 0.2 0.04],'string','Slow'); 
uicontrol(panel_simulation_handler, 'Style','text', 'Fontsize', 8, ...
    'backgroundcolor', background_color, ...     
    'HorizontalAlignment','left', 'Units','normalized', ...
          'Position',[0.9 0.03 0.2 0.04],'string','Fast');       
param_handler_speed = uicontrol(panel_simulation_handler, 'Style','slider', 'BackgroundColor', 'w', 'Units','normalized', ...
          'Position',[0.7 0.03 0.2 0.05],...
          'min',1,'max',25,...
          'value',speed,'callback','global param_handler_speed speed; speed = get(param_handler_speed, ''value'');');      
     
button_handler_shuffle_markers = uicontrol(panel_simulation_handler, 'Style','pushbutton', 'Fontsize', 10, 'Units','normalized', ...
          'Position',[0.7  0.85 0.2 0.055],...
          'visible','off',...
          'String','Shuffle markers','Callback',@shuffle_markers); 
      
button_handler_shuffle_balls = uicontrol(panel_simulation_handler, 'Style','pushbutton', 'Fontsize', 10, 'Units','normalized', ...
          'Position',[0.7  0.91 0.2 0.055],...
          'visible','off',...
          'String','Shuffle balls','Callback',@shuffle_balls); 
      
          
global axis_handler_ring

axis_handler_ring = subplot(1, 1, 1, 'Parent', panel_simulation_handler, 'Color', 'none', 'XColor', 'none', 'YColor', 'none');
axis(1.1.*[-1 1 -1 1]);
axis square;
pos = get(axis_handler_ring, 'Position');
set(axis_handler_ring, 'Position', [0.25*pos(1), pos(2), pos(3), pos(4)]);    


% --------------------------------------------------------

global local_time_origin simulation_time local_simulation_time

            local_time_origin = 0;
            simulation_time = local_time_origin;
            local_simulation_time = local_time_origin;

global balls markers
global delta delta0 N_black N_black_ahead_a_marker N_white N_white_ahead_a_marker


while (quit_flag == 0)
    pause(0.01); % note: minimum value of pause in Matlab is 0.01 (we need this!)
    switch state
        case 0
            pause(0.1);
        case 1
            set(panel_parameters_handler, 'visible', 'off');
            set(button_handler_shuffle_markers, 'visible', 'on');
            set(button_handler_shuffle_balls, 'visible', 'on');
            %
            x_1a = get(trace_1a, 'xdata');
            y_1a = get(trace_1a, 'ydata');
            set(trace_1a, 'xdata', [x_1a, simulation_time], 'ydata', [y_1a, delta]); % 
            %
            x_1b = get(trace_1b, 'xdata');
            y_1b = get(trace_1b, 'ydata');            
            set(trace_1b, 'xdata', [x_1b, simulation_time], 'ydata', [y_1b, mean([y_1a((local_time_origin+1):end), delta])]); % 
            %
            x_1c = get(trace_1c, 'xdata');
            y_1c = get(trace_1c, 'ydata');            
            set(trace_1c, 'xdata', [x_1c, simulation_time], 'ydata', [y_1c, delta0*(1-2*n/N)^local_simulation_time]); % 
            %            
            x_2a = get(trace_2a, 'xdata');
            y_2a = get(trace_2a, 'ydata');
            set(trace_2a, 'xdata', [x_2a, simulation_time], 'ydata', [y_2a, n/N]); %            
            %     
            x_2b = get(trace_2b, 'xdata');
            y_2b = get(trace_2b, 'ydata');
            b_B = N_black_ahead_a_marker/N_black; % b/B
            if isnan(b_B)
                b_B = 1;
            end
            set(trace_2b, 'xdata', [x_2b, simulation_time], 'ydata', [y_2b, b_B]); %            
            %      
            x_2c = get(trace_2c, 'xdata');
            y_2c = get(trace_2c, 'ydata');
            w_W = N_white_ahead_a_marker/N_white; % w/W
            if isnan(w_W)
                w_W = 1;
            end            
            set(trace_2c, 'xdata', [x_2c, simulation_time], 'ydata', [y_2c, w_W]); %            
            %              
            move_balls();
            N_black = sum(balls);
            N_white = N-N_black;
            fraction_black = N_black./N*100;
            delta = 2*N_black-N; % B(t)-W(t)
            N_black_ahead_a_marker = sum(balls(markers)); % b
            aux = my_abs(balls-1);
            N_white_ahead_a_marker = sum(aux(markers)); % w
            simulation_time = simulation_time+1;
            local_simulation_time = local_simulation_time+1;
            x_limit = simulation_time*1;
            if (x_limit>2*N)
                set(axis_handler_1, 'xlim', [0, x_limit]);
                set(axis_handler_2, 'xlim', [0, x_limit]);
                set(axis_handler_time, 'xlim', [0, x_limit]);
            end
            drawnow;
        case -1
            if (simulation_time>0)
                saverequest([x_1a; y_1a; y_1b; y_1c; y_2a; y_2b; y_2c]');
            end
            set(panel_parameters_handler, 'visible', 'on');
            set(button_handler_shuffle_markers, 'visible', 'off');
            set(button_handler_shuffle_balls, 'visible', 'off');
            cla(axis_handler_1);
            cla(axis_handler_2);
            trace_1a = line(axis_handler_1, 'color', 'k', 'LineStyle', '-', 'xdata', [], 'ydata', [], 'zdata', []);
            trace_1b = line(axis_handler_1, 'color', 'k', 'LineStyle', ':', 'xdata', [], 'ydata', [], 'zdata', []);
            trace_1c = line(axis_handler_1, 'color', 'r', 'LineStyle', '-', 'xdata', [], 'ydata', [], 'zdata', []);            
            trace_2a = line(axis_handler_2, 'color', 'r', 'LineStyle', '-', 'xdata', [], 'ydata', [], 'zdata', []);
            trace_2b = line(axis_handler_2, 'color', 'k', 'LineStyle', '-', 'xdata', [], 'ydata', [], 'zdata', []);
            trace_2c = line(axis_handler_2, 'color', [0,0.5,0], 'LineStyle', '-', 'xdata', [], 'ydata', [], 'zdata', []);
            set(axis_handler_1, 'xlim', [0, 2*N]); set(axis_handler_1, 'ylim', [-N, N]);
            set(axis_handler_2, 'xlim', [0, 2*N]); set(axis_handler_2, 'ylim', [0, 1]);
            set(axis_handler_time, 'xlim', [0, 2*N]); set(axis_handler_time, 'ylim', [0, 1]);  % ONLY X-AXIS
            legend(axis_handler_1, {'B(t)-W(t)', '<B(t)-W(t)>', '\Delta(0)(1-2\mu)^t'}, 'orientation', 'vertical');% 'horizontal');
            legend(axis_handler_2, {'n/N', 'b/B', 'w/W'}, 'orientation', 'vertical');% 'horizontal');
            local_time_origin = 0;
            simulation_time = local_time_origin;
            local_simulation_time = local_time_origin;
            change_parameters();            
            state = 0;
    end
end

delete(figure_handler);

return
end

%%

function change_parameters(~, ~) % handler, event
global fraction_black n N N_black N_white 
global max_N 
global param_handler_n param_handler_N
global text_handler_fraction_black param_handler_fraction_black
fraction_black = get(param_handler_fraction_black, 'value');
set(text_handler_fraction_black, 'string', sprintf('%d%%', round(fraction_black)));
N = str2double(get(param_handler_N, 'string'));
n = str2double(get(param_handler_n, 'string'));
if (n>=N)
    n = N-1;
    set(param_handler_n, 'string', num2str(N-1));
end
if (n<0)
    n = 0;
    set(param_handler_n, 'string', num2str(0));
end
if (N<1)
    N = 1;
    set(param_handler_N, 'string', num2str(1));
end
if (N>max_N)
    N = max_N;
    set(param_handler_N, 'string', num2str(max_N));
end
N_black = round(N*fraction_black/100);
N_white = N-N_black;
global delta delta0
delta = 2*N_black-N;
delta0 = delta;
global balls markers
balls = zeros(1, N);
balls(randperm(N, N_black)) = 1;
markers = randperm(N, n);
global N_black_ahead_a_marker N_white_ahead_a_marker
N_black_ahead_a_marker = sum(balls(markers));
aux = my_abs(balls-1);
N_white_ahead_a_marker = sum(aux(markers));
% reset axes properties where needed
global axis_handler_1 axis_handler_2 axis_handler_time
set(axis_handler_1, 'ylim', [-N, N]);
set(axis_handler_1, 'xlim', [0, 2*N]); 
set(axis_handler_2, 'xlim', [0, 2*N]);
set(axis_handler_time, 'xlim', [0, 2*N]);
% draw balls and markers
global axis_handler_ring
cla(axis_handler_ring);
global ring_group
ring_group = hgtransform('Parent', axis_handler_ring);
draw_markers();
draw_ring();
return
end

function draw_markers()
global N max_N max_N_for_draw_ring warning_issued markers axis_handler_ring
if (N>max_N_for_draw_ring)
    if not(warning_issued)
        message = ['Graphical representation is limited to ', num2str(max_N_for_draw_ring), ' lattice sites.', 10, ...
            'However, you can still run the simulation with N up to ', num2str(max_N), '.'];
        warndlg(message, 'Warning', 'modal');
        %text(h, -1, 0, message, 'fontsize', 12);   
        warning_issued = true;
    end
else
    warning_issued = false;
    r1 = 0.85;
    r2 = 0.90;
    delta_angle = 2*pi/240;
    delete(findobj(axis_handler_ring, 'tag', 'marker')); % delete all markers
    for i=markers
        angle = (2*pi/N)*i;
        patch(axis_handler_ring, ...
            [r1*cos(angle+delta_angle), r1*cos(angle-delta_angle), r2*cos(angle)], ...
            [r1*sin(angle+delta_angle), r1*sin(angle-delta_angle), r2*sin(angle)], 'black', 'tag', 'marker');
    end
end
return
end

%%

function draw_circle(h, p, x, y, r)
angle = 0:0.01:2.1*pi; 
xp = r*cos(angle);
yp = r*sin(angle);
line(h, x+xp, y+yp, 'color', 'k', 'LineStyle', '-', 'Parent', p);
return
end

function draw_black_ball(h, p, x, y, r)
angle = 0:0.25:2.1*pi; 
xp = r*cos(angle);
yp = r*sin(angle);
patch(h, x+xp, y+yp, 'black', 'Parent', p);
return
end

function draw_white_ball(h, p, x, y, r)
angle = 0:0.25:2.1*pi; 
xp = r*cos(angle);
yp = r*sin(angle);
patch(h, x+xp, y+yp, 'white', 'Parent', p);
return
end

function draw_ring(offset)
global axis_handler_ring ring_group N balls
if (nargin<1)
    offset = 0;
end
delete(get(ring_group, 'Child'));
global max_N_for_draw_ring
if (N<=max_N_for_draw_ring)
    radius = 1; % circle radius
    draw_circle(axis_handler_ring, ring_group, 0, 0, radius);
    a = 0.05*(2-N/50); % ball radius
    for i=1:N
        angle = (pi./N)*(2*i-1)+offset;
        x = radius*cos(angle);
        y = radius*sin(angle);
        if (balls(i)==1)
            draw_black_ball(axis_handler_ring, ring_group, x, y, a);
        else
            draw_white_ball(axis_handler_ring, ring_group, x, y, a);
        end
    end
end
return
end

function move_balls()
global ring_group N balls markers
global speed
% animation sequence:
% draw balls - rotate half - redraw balls (marker position) - rotate half
start_angle = 0;
redraw_angle = pi/N;
stop_angle = 2*pi/N;
step_size = stop_angle/100*speed;
global max_N_for_draw_ring
if (N<=max_N_for_draw_ring)
    draw_ring(0);
    for alpha=start_angle:step_size:redraw_angle
        Rz = makehgtform('zrotate', -alpha);
        set(ring_group, 'Matrix', Rz);
        drawnow;
    end
end
balls = circshift(balls, -1);
balls(markers) = my_abs(balls(markers)-1); % negate
if (N<=max_N_for_draw_ring)
    draw_ring(2*redraw_angle);
    for alpha=redraw_angle:step_size:stop_angle
        Rz = makehgtform('zrotate', -alpha);
        set(ring_group, 'Matrix', Rz);
        drawnow;
    end
end
return
end

function closerequest(~, ~) % src, callbackdata
global quit_flag
answer = questdlg('Do you really want to quit?', 'Confirmation', 'Yes', 'No', 'Yes');
if strcmp(answer, 'Yes')
    quit_flag = 1;
end
return
end

function saverequest(data) 
answer = questdlg('Do you want to save simulation CSV table?', 'Confirmation', 'Yes', 'No', 'Yes');
if strcmp(answer, 'Yes')
    [filename, pathname] = uiputfile('*.csv', 'Save to file...');
    if not(isequal(filename, 0))
        file = fullfile(pathname, filename);
        csvwrite(file, data);
    end
end
return
end

function x = my_abs(x) % to avoid any dependence when packaging the app
x(x<0) = (-1).*x(x<0);
return
end

function shuffle_markers(~, ~)
global N n markers
markers = randperm(N, n); 
draw_markers();
global axis_handler_1 axis_handler_2
global simulation_time
yl_1 = get(axis_handler_1, 'YLim');
yl_2 = get(axis_handler_2, 'YLim');
line(axis_handler_1, 'xdata', [simulation_time, simulation_time], 'ydata', yl_1, 'zdata', [0, 0], 'color',[0.5,0.5,0.5], 'linestyle', '--');
line(axis_handler_2, 'xdata', [simulation_time, simulation_time], 'ydata', yl_2, 'zdata', [0, 0], 'color',[0.5,0.5,0.5], 'linestyle', '--');
text(axis_handler_1, simulation_time, yl_1(1), 'Markers shuffled', 'fontsize', 8, 'rotation', 90, 'color',[0.5,0.5,0.5], 'fontweight', 'bold');
global local_simulation_time delta delta0
local_simulation_time = 0;
delta0 = delta;
return
end

function shuffle_balls(~, ~)
global N balls
N_black_now = sum(balls);
balls = zeros(1, N);
balls(randperm(N, N_black_now)) = 1;
draw_ring(0);
global axis_handler_1 axis_handler_2
global simulation_time
yl_1 = get(axis_handler_1, 'YLim');
yl_2 = get(axis_handler_2, 'YLim');
line(axis_handler_1, 'xdata', [simulation_time, simulation_time], 'ydata', yl_1, 'zdata', [0, 0], 'color',[0.5,0.5,0.5], 'linestyle', '--');
line(axis_handler_2, 'xdata', [simulation_time, simulation_time], 'ydata', yl_2, 'zdata', [0, 0], 'color',[0.5,0.5,0.5], 'linestyle', '--');
text(axis_handler_1, simulation_time, yl_1(1), 'Balls shuffled', 'fontsize', 8, 'rotation', 90, 'color',[0.5,0.5,0.5], 'fontweight', 'bold');
global local_time_origin local_simulation_time delta delta0
local_time_origin = simulation_time;
local_simulation_time = 0;
delta0 = delta;
return
end




