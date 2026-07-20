// =========================================================================
// module_stem.sce
// MODULE 1: Interactive STEM Education
// Three switchable interactive demos, all sharing one plotting axes:
//   1. Projectile Motion   (mechanics)
//   2. Simple Pendulum     (mechanics / oscillation)
//   3. RC Circuit Charging (electronics)
// =========================================================================

global STEM_AXES
global STEM_CONTROLS         // list of widget-groups, one per demo

function stem_open()
    f = theme_new_figure('STEM Explorer - Physics & Electronics', [120 40 1020 700]);

    theme_label(f, 'INTERACTIVE STEM EXPLORER', [280 640 500 35], theme_neon_cyan());

    uicontrol(f, 'style', 'listbox', ...
        'string', ['Projectile Motion'; 'Simple Pendulum'; 'RC Circuit Charging'], ...
        'position', [30 520 220 90], ...
        'backgroundcolor', [0.12 0.12 0.18], ...
        'foregroundcolor', theme_neon_green(), ...
        'fontsize', 3, ...
        'callback', 'stem_switch_demo()');

    a = newaxes();
    a.axes_bounds = [0.30 0.10 0.66 0.62];
    a.parent = f;
    a.background = 1;
    STEM_AXES = a;

    STEM_CONTROLS = list();

    stem_build_projectile(f);
    stem_build_pendulum(f);
    stem_build_rc(f);

    stem_show_only(1);

    theme_button(f, 'Back to Home', [30 20 150 35], 'launch_home()', theme_neon_pink());
    tippy_init(f);
    tippy_help_button(f, [960 640 30 30], ...
        'Pick a demo from the list on the left. Drag sliders to change parameters, then click Simulate/Animate to see the physics come alive!');
endfunction

function stem_switch_demo()
    lb = gcbo();
    stem_show_only(lb.value);
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
global STEM_PROJ_V STEM_PROJ_A STEM_PROJ_G STEM_PROJ_RES STEM_PROJ_VVAL STEM_PROJ_AVAL

function stem_build_projectile(f)
    global STEM_CONTROLS STEM_PROJ_V STEM_PROJ_A STEM_PROJ_G STEM_PROJ_RES
    global STEM_PROJ_VVAL STEM_PROJ_AVAL

    lbl1 = theme_label(f, 'Launch Velocity (m/s):', [30 460 190 20]);
    v_slider = uicontrol(f, 'style', 'slider', 'min', 5, 'max', 100, 'value', 30, ...
        'position', [30 440 200 20], 'callback', 'stem_projectile_update()');
    v_val = theme_label(f, '30', [235 440 60 20], theme_neon_green());

    lbl2 = theme_label(f, 'Launch Angle (deg):', [30 400 190 20]);
    a_slider = uicontrol(f, 'style', 'slider', 'min', 5, 'max', 85, 'value', 45, ...
        'position', [30 380 200 20], 'callback', 'stem_projectile_update()');
    a_val = theme_label(f, '45', [235 380 60 20], theme_neon_green());

    lbl3 = theme_label(f, 'Gravity (Planet):', [30 340 190 20]);
    g_menu = uicontrol(f, 'style', 'popupmenu', ...
        'string', ['Earth (9.8)'; 'Moon (1.62)'; 'Mars (3.71)'; 'Jupiter (24.8)'], ...
        'position', [30 320 200 25], 'callback', 'stem_projectile_update()');

    animate_btn = theme_button(f, 'Animate Trajectory', [30 270 200 35], 'stem_projectile_animate()', theme_neon_cyan());
    result_lbl = theme_label(f, 'Range: --   Max Height: --   Time: --', [30 220 230 70], theme_neon_purple());

    STEM_PROJ_V = v_slider; STEM_PROJ_A = a_slider; STEM_PROJ_G = g_menu; STEM_PROJ_RES = result_lbl;
    STEM_PROJ_VVAL = v_val; STEM_PROJ_AVAL = a_val;

    STEM_CONTROLS($+1) = list(lbl1, v_slider, v_val, lbl2, a_slider, a_val, lbl3, g_menu, animate_btn, result_lbl);
    stem_projectile_update();
endfunction

function stem_projectile_update()
    global STEM_PROJ_V STEM_PROJ_A STEM_PROJ_G STEM_PROJ_RES STEM_AXES
    global STEM_PROJ_VVAL STEM_PROJ_AVAL

    v0 = STEM_PROJ_V.value;
    ang = STEM_PROJ_A.value;
    STEM_PROJ_VVAL.string = string(round(v0));
    STEM_PROJ_AVAL.string = string(round(ang));

    gvals = [9.8 1.62 3.71 24.8];
    g = gvals(STEM_PROJ_G.value);

    th = ang * %pi / 180;
    t_flight = 2 * v0 * sin(th) / g;
    t = linspace(0, t_flight, 200);
    x = v0 * cos(th) * t;
    y = v0 * sin(th) * t - 0.5 * g * t.^2;
    rng = v0^2 * sin(2*th) / g;
    hmax = (v0 * sin(th))^2 / (2*g);

    sca(STEM_AXES);
    cla();
    plot2d(x, y, style = color("cyan"));
    xtitle('Projectile Trajectory', 'Distance (m)', 'Height (m)');

    STEM_PROJ_RES.string = msprintf('Range: %.2f m\nMax Height: %.2f m\nFlight Time: %.2f s', rng, hmax, t_flight);
endfunction

function stem_projectile_animate()
    global STEM_PROJ_V STEM_PROJ_A STEM_PROJ_G STEM_AXES

    v0 = STEM_PROJ_V.value;
    ang = STEM_PROJ_A.value;
    gvals = [9.8 1.62 3.71 24.8];
    g = gvals(STEM_PROJ_G.value);
    th = ang * %pi / 180;
    t_flight = 2 * v0 * sin(th) / g;

    n = 60;
    t = linspace(0, t_flight, n);
    x = v0 * cos(th) * t;
    y = v0 * sin(th) * t - 0.5 * g * t.^2;

    sca(STEM_AXES);
    for i = 1:n
        cla();
        plot2d(x(1:i), y(1:i), style = color("cyan"));
        plot2d(x(i), y(i), style = -9);   // marker = the "ball"
        xtitle('Projectile Trajectory (Animating)', 'Distance (m)', 'Height (m)');
        drawnow();
        xpause(20000);
    end
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
    period_lbl = theme_label(f, 'Period T: --', [30 290 230 30], theme_neon_purple());

    STEM_PEND_L = l_slider; STEM_PEND_A = a_slider; STEM_PEND_T = period_lbl;

    grp = list(lbl1, l_slider, lbl2, a_slider, animate_btn, period_lbl);
    for i = 1:length(grp)
        grp(i).visible = 'off';
    end
    global STEM_CONTROLS
    STEM_CONTROLS($+1) = grp;
endfunction

function stem_pendulum_update()
    global STEM_PEND_L STEM_PEND_A STEM_PEND_T STEM_AXES

    L = STEM_PEND_L.value;
    th0 = STEM_PEND_A.value * %pi / 180;
    g = 9.8;
    T = 2 * %pi * sqrt(L/g);
    t = linspace(0, 3*T, 300);
    theta = th0 * cos(2*%pi/T * t);   // small-angle approximation

    sca(STEM_AXES);
    cla();
    plot2d(t, theta * 180/%pi, style = color("magenta"));
    xtitle('Pendulum Angle vs Time', 'Time (s)', 'Angle (deg)');

    STEM_PEND_T.string = msprintf('Period T: %.3f s', T);
endfunction

function stem_pendulum_animate()
    global STEM_PEND_L STEM_PEND_A STEM_AXES

    L = STEM_PEND_L.value;
    th0 = STEM_PEND_A.value * %pi / 180;
    g = 9.8;
    T = 2 * %pi * sqrt(L/g);

    n = 60;
    t = linspace(0, 2*T, n);
    theta = th0 * cos(2*%pi/T * t);

    sca(STEM_AXES);
    for i = 1:n
        cla();
        x = [0, L*sin(theta(i))];
        y = [0, -L*cos(theta(i))];
        plot2d(x, y, style = color("yellow"));
        plot2d(x(2), y(2), style = -9);   // bob
        xtitle('Pendulum Swing (Animating)', 'X (m)', 'Y (m)');
        ax = gca();
        ax.data_bounds = [-L-0.2, L+0.2; -L-0.2, 0.2]';
        drawnow();
        xpause(30000);
    end
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
    tau_lbl = theme_label(f, 'Time constant tau: --', [30 280 230 30], theme_neon_purple());

    STEM_RC_R = r_slider; STEM_RC_C = c_slider; STEM_RC_V = v_slider; STEM_RC_TAU = tau_lbl;

    grp = list(lbl1, r_slider, lbl2, c_slider, lbl3, v_slider, tau_lbl);
    for i = 1:length(grp)
        grp(i).visible = 'off';
    end
    global STEM_CONTROLS
    STEM_CONTROLS($+1) = grp;
endfunction

function stem_rc_update()
    global STEM_RC_R STEM_RC_C STEM_RC_V STEM_RC_TAU STEM_AXES

    R = STEM_RC_R.value;
    C = STEM_RC_C.value * 1e-6;
    V = STEM_RC_V.value;
    tau = R * C;
    t = linspace(0, 5*tau, 300);
    vc = V * (1 - exp(-t/tau));

    sca(STEM_AXES);
    cla();
    plot2d(t, vc, style = color("lightgreen"));
    xtitle('RC Charging Curve', 'Time (s)', 'Capacitor Voltage (V)');

    STEM_RC_TAU.string = msprintf('Time constant tau: %.4f s', tau);
endfunction
