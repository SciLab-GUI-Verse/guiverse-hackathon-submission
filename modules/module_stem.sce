// =========================================================================
// module_stem.sce
// MODULE 1: Interactive STEM Education
// Three switchable interactive demos, all sharing one plotting axes:
//   1. Projectile Motion   (mechanics)
//   2. Simple Pendulum     (mechanics / oscillation)
//   3. RC Circuit Charging (electronics)
// =========================================================================

global STEM_FIG STEM_AXES
global STEM_CONTROLS         // list of widget-groups, one per demo

function stem_open()
    global STEM_FIG STEM_AXES STEM_CONTROLS
    f = theme_new_figure('STEM Explorer - Physics & Electronics', [120 40 1020 760]);
    STEM_FIG = f;

    theme_label(f, 'INTERACTIVE STEM EXPLORER', [280 640 500 35], theme_neon_cyan());

    // Plot axes first (background layer).
    a = newaxes();
    a.axes_bounds = [0.30 0.18 0.66 0.58];
    a.parent = f;
    a.background = 1;
    STEM_AXES = a;

    STEM_CONTROLS = list();

    lb = theme_list(f, ['Projectile Motion'; 'Simple Pendulum'; 'RC Circuit Charging'], [30 520 220 90]);
    lb.callback = 'stem_switch_demo()';

    stem_build_projectile(f);
    stem_build_pendulum(f);
    stem_build_rc(f);

    stem_show_only(1);

// Create ALL UI first
theme_nav_button(f, 'Back to Home', [30 20 150 35], 'launch_home()');

tippy_init(f);

tippy_help_button(f, [960 640 30 30], ...
    'Pick a demo from the list on the left. Drag sliders to change parameters, then click Simulate/Animate to see the physics come alive!');

// Finalize UI
theme_finalize_figure(f);

// NOW draw the first graph
// Wrapped in try/catch so that a bad computation here can never blow up
// stem_open()s call stack and take the whole function down with it -
// which is what was wiping out every callback function on error before.
try
    stem_projectile_update();
catch
    disp('stem_open: initial projectile plot failed - ' + lasterror());
end
endfunction

function stem_switch_demo()
    lb = gcbo();
    idx = lb.value;
    stem_show_only(idx);
    select idx
    case 1 then
        stem_projectile_update();
    case 2 then
        stem_pendulum_update();
    case 3 then
        stem_rc_update();
    end
    theme_finalize_figure(STEM_FIG);
endfunction

function stem_show_only(idx)
    global STEM_CONTROLS
    for i = 1:length(STEM_CONTROLS)
        grp = STEM_CONTROLS(i);
        for j = 1:length(grp)
            if i == idx then
                grp(j).visible = 'on';
            else
                grp(j).visible = 'off';
            end
        end
    end
endfunction

// ------------------------------------------------------------------
// Demo 1: Projectile Motion
// ------------------------------------------------------------------
global STEM_PROJ_V STEM_PROJ_A STEM_PROJ_H STEM_PROJ_G STEM_PROJ_RES STEM_PROJ_VVAL STEM_PROJ_AVAL STEM_PROJ_HVAL

function stem_build_projectile(f)
    global STEM_CONTROLS STEM_PROJ_V STEM_PROJ_A STEM_PROJ_H STEM_PROJ_G STEM_PROJ_RES
    global STEM_PROJ_VVAL STEM_PROJ_AVAL STEM_PROJ_HVAL

    lbl1 = theme_label(f, 'Launch Velocity (m/s):', [30 480 190 20]);
    v_slider = uicontrol(f, 'style', 'slider', 'min', 5, 'max', 100, 'value', 30, ...
        'position', [30 460 200 20], 'callback', 'stem_projectile_update()');
    v_val = theme_label(f, '30', [235 460 60 20], theme_neon_green());

    lbl2 = theme_label(f, 'Launch Angle (deg):', [30 425 190 20]);
    a_slider = uicontrol(f, 'style', 'slider', 'min', 5, 'max', 85, 'value', 45, ...
        'position', [30 405 200 20], 'callback', 'stem_projectile_update()');
    a_val = theme_label(f, '45', [235 405 60 20], theme_neon_green());

    lblh = theme_label(f, 'Launch Height (m):', [30 370 190 20]);
    h_slider = uicontrol(f, 'style', 'slider', 'min', 0, 'max', 50, 'value', 0, ...
        'position', [30 350 200 20], 'callback', 'stem_projectile_update()');
    h_val = theme_label(f, '0', [235 350 60 20], theme_neon_green());

    lbl3 = theme_label(f, 'Gravity (Planet):', [30 315 190 20]);
      // FIX: added value = 1 so the dropdown starts on Earth (9.8) instead
    // of defaulting to an empty selection. Without this, STEM_PROJ_G.value
    // was [], so gvals(STEM_PROJ_G.value) evaluated to [] and every
    // downstream calculation (t_flight, linspace, etc.) collapsed to an
    // empty matrix - this was the root cause of the crash.
    g_menu = uicontrol(f, 'style', 'popupmenu', ...
        'string', ['Earth (9.8)'; 'Moon (1.62)'; 'Mars (3.71)'; 'Jupiter (24.8)'], ...
        'value', 1, ...
        'position', [30 295 200 25], 'callback', 'stem_projectile_update()');

    animate_btn = theme_button(f, 'Animate Trajectory', [30 245 200 35], 'stem_projectile_animate()', theme_neon_cyan());
    result_lbl = theme_label(f, 'Range: --   Max Height: --   Time: --', [30 155 230 80], theme_neon_purple());

    STEM_PROJ_V = v_slider; STEM_PROJ_A = a_slider; STEM_PROJ_H = h_slider; STEM_PROJ_G = g_menu; STEM_PROJ_RES = result_lbl;
    STEM_PROJ_VVAL = v_val; STEM_PROJ_AVAL = a_val; STEM_PROJ_HVAL = h_val;

    STEM_CONTROLS($+1) = list(lbl1, v_slider, v_val, lbl2, a_slider, a_val, lblh, h_slider, h_val, lbl3, g_menu, animate_btn, result_lbl);
endfunction

function stem_projectile_update()
    global STEM_PROJ_V STEM_PROJ_A STEM_PROJ_H STEM_PROJ_G STEM_PROJ_RES STEM_AXES STEM_FIG
    global STEM_PROJ_VVAL STEM_PROJ_AVAL STEM_PROJ_HVAL

    v0 = STEM_PROJ_V.value;
    ang = STEM_PROJ_A.value;
    y0 = STEM_PROJ_H.value;
    STEM_PROJ_VVAL.string = string(round(v0));
    STEM_PROJ_AVAL.string = string(round(ang));
    STEM_PROJ_HVAL.string = string(round(y0));

    gvals = [9.8 1.62 3.71 24.8];
    // Safety net: if the popup ever reports an empty/invalid value again,
    // fall back to Earth gravity instead of silently propagating [].
    gidx = STEM_PROJ_G.value;
    if isempty(gidx) | gidx < 1 | gidx > length(gvals) then
        gidx = 1;
        STEM_PROJ_G.value = 1;
    end
    g = gvals(gidx);

    th = ang * %pi / 180;
    // Calculate flight time using quadratic formula for y(t) = 0
    t_flight = (v0 * sin(th) + sqrt((v0 * sin(th))^2 + 2 * g * y0)) / g;
    t = linspace(0, t_flight, 200);
    x = v0 * cos(th) * t;
    y = y0 + v0 * sin(th) * t - 0.5 * g * t.^2;
    rng = v0 * cos(th) * t_flight;
    hmax = y0 + (v0 * sin(th))^2 / (2*g);

    chart_plot_line(STEM_AXES, x, y, 'cyan', 'Projectile Trajectory', 'Distance (m)', 'Height (m)');

    // NOTE: msprintf with an embedded newline puts a literal newline inside
    // ONE string, which this Scilab installs uicontrol rejects with a
    // Wrong size for String property error. Multi-line uicontrol text
    // needs a proper multi-row string matrix instead - one row per line.
    STEM_PROJ_RES.string = msprintf('Range: %.2f m', rng) + ascii(10) + ...
                       msprintf('Max Height: %.2f m', hmax) + ascii(10) + ...
                       msprintf('Flight Time: %.2f s', t_flight);
    theme_finalize_figure(STEM_FIG);
endfunction

function stem_projectile_animate()
    global STEM_PROJ_V STEM_PROJ_A STEM_PROJ_H STEM_PROJ_G STEM_AXES STEM_FIG

    v0 = STEM_PROJ_V.value;
    ang = STEM_PROJ_A.value;
    y0 = STEM_PROJ_H.value;
    gvals = [9.8 1.62 3.71 24.8];
    gidx = STEM_PROJ_G.value;
    if isempty(gidx) | gidx < 1 | gidx > length(gvals) then
        gidx = 1;
        STEM_PROJ_G.value = 1;
    end
    g = gvals(gidx);
    th = ang * %pi / 180;
    t_flight = (v0 * sin(th) + sqrt((v0 * sin(th))^2 + 2 * g * y0)) / g;

    t = linspace(0, t_flight, 80);
    x = v0 * cos(th) * t;
    y = y0 + v0 * sin(th) * t - 0.5 * g * t.^2;

    chart_animate_marker(STEM_AXES, x, y, 'cyan', 'Projectile Trajectory (Animating)', 'Distance (m)', 'Height (m)', 80, 20000);
    theme_finalize_figure(STEM_FIG);
endfunction

// ------------------------------------------------------------------
// Demo 2: Simple Pendulum
// ------------------------------------------------------------------
global STEM_PEND_L STEM_PEND_A STEM_PEND_T

function stem_build_pendulum(f)
    global STEM_CONTROLS STEM_PEND_L STEM_PEND_A STEM_PEND_T

    lbl1 = theme_label(f, 'String Length (m):', [30 460 190 20]);
    l_slider = uicontrol(f, 'style', 'slider', 'min', 0.2, 'max', 3, 'value', 1, ...
        'position', [30 440 200 20], 'callback', 'stem_pendulum_update()');
    lbl2 = theme_label(f, 'Initial Angle (deg):', [30 400 190 20]);
    a_slider = uicontrol(f, 'style', 'slider', 'min', 5, 'max', 60, 'value', 20, ...
        'position', [30 380 200 20], 'callback', 'stem_pendulum_update()');
    animate_btn = theme_button(f, 'Animate Swing', [30 330 200 35], 'stem_pendulum_animate()', theme_neon_pink());
    period_lbl = theme_label(f, 'Period T: --', [30 240 230 75], theme_neon_purple());

    STEM_PEND_L = l_slider; STEM_PEND_A = a_slider; STEM_PEND_T = period_lbl;

    grp = list(lbl1, l_slider, lbl2, a_slider, animate_btn, period_lbl);
    for i = 1:length(grp)
        grp(i).visible = 'off';
    end
    global STEM_CONTROLS
    STEM_CONTROLS($+1) = grp;
endfunction

function stem_pendulum_update()
    global STEM_PEND_L STEM_PEND_A STEM_PEND_T STEM_AXES STEM_FIG

    L = STEM_PEND_L.value;
    th0 = STEM_PEND_A.value * %pi / 180;
    g = 9.8;
    T = 2 * %pi * sqrt(L/g);
    f_hz = 1 / T;
    omega = 2 * %pi * f_hz;
    t = linspace(0, 3*T, 300);
    theta = th0 * cos(2*%pi/T * t);

    chart_plot_line(STEM_AXES, t, theta * 180/%pi, 'magenta', 'Pendulum Angle vs Time', 'Time (s)', 'Angle (deg)');

    STEM_PEND_T.string = [msprintf('Period T: %.3f s', T); ...
                           msprintf('Frequency: %.3f Hz', f_hz); ...
                           msprintf('Angular Freq: %.3f rad/s', omega)];
    theme_finalize_figure(STEM_FIG);
endfunction

function stem_pendulum_animate()
    global STEM_PEND_L STEM_PEND_A STEM_AXES STEM_FIG

    L = STEM_PEND_L.value;
    th0 = STEM_PEND_A.value * %pi / 180;
    g = 9.8;
    T = 2 * %pi * sqrt(L/g);

    n = 80;
    t = linspace(0, 2*T, n);
    theta = th0 * cos(2*%pi/T * t);

    sca(STEM_AXES);
    for i = 1:n
        cla();
        theme_style_axes(STEM_AXES);
        x = [0, L*sin(theta(i))];
        y = [0, -L*cos(theta(i))];
        plot2d(x, y, style = -1);
        chart_style_line('yellow', 3);
        plot2d(x(2), y(2), style = -9, strf = '000');
        e = gce();
        e.foreground = chart_color('pink');
        e.thickness = 2;
        xtitle('Pendulum Swing (Animating)', 'X (m)', 'Y (m)');
        ax = gca();
        ax.data_bounds = [-L-0.2, L+0.2; -L-0.2, 0.2]';
        drawnow();
        theme_pause(25000);
    end
    theme_finalize_figure(STEM_FIG);
endfunction

// ------------------------------------------------------------------
// Demo 3: RC Circuit Charging (electronics)
// ------------------------------------------------------------------
global STEM_RC_R STEM_RC_C STEM_RC_V STEM_RC_TAU

function stem_build_rc(f)
    global STEM_CONTROLS STEM_RC_R STEM_RC_C STEM_RC_V STEM_RC_TAU

    lbl1 = theme_label(f, 'Resistance R (ohm):', [30 460 190 20]);
    r_slider = uicontrol(f, 'style', 'slider', 'min', 100, 'max', 10000, 'value', 1000, ...
        'position', [30 440 200 20], 'callback', 'stem_rc_update()');
    lbl2 = theme_label(f, 'Capacitance C (uF):', [30 400 190 20]);
    c_slider = uicontrol(f, 'style', 'slider', 'min', 1, 'max', 1000, 'value', 100, ...
        'position', [30 380 200 20], 'callback', 'stem_rc_update()');
    lbl3 = theme_label(f, 'Supply Voltage (V):', [30 340 190 20]);
    v_slider = uicontrol(f, 'style', 'slider', 'min', 1, 'max', 24, 'value', 5, ...
        'position', [30 320 200 20], 'callback', 'stem_rc_update()');
    tau_lbl = theme_label(f, 'Time constant tau: --', [30 250 230 60], theme_neon_purple());

    STEM_RC_R = r_slider; STEM_RC_C = c_slider; STEM_RC_V = v_slider; STEM_RC_TAU = tau_lbl;

    grp = list(lbl1, r_slider, lbl2, c_slider, lbl3, v_slider, tau_lbl);
    for i = 1:length(grp)
        grp(i).visible = 'off';
    end
    global STEM_CONTROLS
    STEM_CONTROLS($+1) = grp;
endfunction

function stem_rc_update()
    global STEM_RC_R STEM_RC_C STEM_RC_V STEM_RC_TAU STEM_AXES STEM_FIG

    R = STEM_RC_R.value;
    C_uF = STEM_RC_C.value;
    C = C_uF * 1e-6;
    V = STEM_RC_V.value;
    tau = R * C;
    E_uJ = 0.5 * C_uF * V^2;
    t = linspace(0, 5*tau, 300);
    vc = V * (1 - exp(-t/tau));

    chart_plot_line(STEM_AXES, t, vc, 'green', 'RC Charging Curve', 'Time (s)', 'Capacitor Voltage (V)');

    STEM_RC_TAU.string = [msprintf('Time constant tau: %.4f s', tau); ...
                           msprintf('Stored Energy: %.2f uJ', E_uJ)];
    theme_finalize_figure(STEM_FIG);
endfunction
