// =========================================================================
// module_simulator.sce
// MODULE 4: Science & Engineering Simulator
// Spring-Mass-Damper system: m*x'' + c*x' + k*x = 0
// Users drag mass/stiffness/damping/initial-displacement sliders and
// watch the displacement response solved numerically (ode()) in real time.
// =========================================================================

global SIM_FIG SIM_M SIM_K SIM_C SIM_X0 SIM_AXES SIM_INFO
global SIM_ODE_M SIM_ODE_K SIM_ODE_C

function simulator_open()
    global SIM_FIG SIM_M SIM_K SIM_C SIM_X0 SIM_AXES SIM_INFO
    f = theme_new_figure('Engineering Simulator - Spring Mass Damper', [120 40 1020 700]);
    SIM_FIG = f;

    theme_label(f, 'SPRING-MASS-DAMPER SIMULATOR', [250 640 550 35], theme_neon_purple());

    a = newaxes();
    a.axes_bounds = [0.30 0.18 0.66 0.58];
    a.parent = f;
    a.background = 1;
    SIM_AXES = a;

    m_lbl = theme_label(f, 'Mass m (kg):', [30 580 170 20]);
    m_slider = uicontrol(f, 'style', 'slider', 'min', 0.5, 'max', 10, 'value', 1, ...
        'position', [30 560 220 20], 'callback', 'sim_update()');
    k_lbl = theme_label(f, 'Stiffness k (N/m):', [30 520 170 20]);
    k_slider = uicontrol(f, 'style', 'slider', 'min', 1, 'max', 200, 'value', 40, ...
        'position', [30 500 220 20], 'callback', 'sim_update()');
    c_lbl = theme_label(f, 'Damping c (N.s/m):', [30 460 170 20]);
    c_slider = uicontrol(f, 'style', 'slider', 'min', 0, 'max', 20, 'value', 2, ...
        'position', [30 440 220 20], 'callback', 'sim_update()');
    x0_lbl = theme_label(f, 'Initial Displacement (m):', [30 400 210 20]);
    x0_slider = uicontrol(f, 'style', 'slider', 'min', 0.1, 'max', 2, 'value', 1, ...
        'position', [30 380 220 20], 'callback', 'sim_update()');

    animate_btn = theme_button(f, 'Animate Response', [30 320 220 35], 'sim_animate()', theme_neon_cyan());
    info_lbl = theme_label(f, 'Natural Freq: --   Damping Ratio: --', [30 260 260 60], theme_neon_green());

    SIM_M = m_slider; SIM_K = k_slider; SIM_C = c_slider; SIM_X0 = x0_slider;
    SIM_INFO = info_lbl;

    theme_nav_button(f, 'Back to Home', [30 20 150 35], 'launch_home()');
    tippy_init(f);
    tippy_help_button(f, [960 640 30 30], ...
        'Adjust mass, stiffness and damping sliders, then click Animate to watch the displacement curve draw in real time. Try c=0 for undamped oscillation!');

    sim_update();
    theme_finalize_figure(f);
endfunction

function xd = sim_ode(t, x)
    global SIM_ODE_M SIM_ODE_K SIM_ODE_C
    xd = zeros(2, 1);
    xd(1) = x(2);
    xd(2) = -(SIM_ODE_K/SIM_ODE_M)*x(1) - (SIM_ODE_C/SIM_ODE_M)*x(2);
endfunction

function sim_update()
    global SIM_M SIM_K SIM_C SIM_X0 SIM_AXES SIM_INFO SIM_FIG
    global SIM_ODE_M SIM_ODE_K SIM_ODE_C

    m = SIM_M.value; k = SIM_K.value; c = SIM_C.value; x0 = SIM_X0.value;
    SIM_ODE_M = m; SIM_ODE_K = k; SIM_ODE_C = c;

    wn = sqrt(k/m);
    zeta = c / (2*sqrt(k*m));

    if zeta == 0 then
        dtype = "Undamped";
    elseif zeta < 1 then
        dtype = "Underdamped";
    elseif zeta == 1 then
        dtype = "Critically Damped";
    else
        dtype = "Overdamped";
    end

    t = linspace(0, 10, 500);
    x = ode([x0; 0], 0, t, sim_ode);

    chart_plot_line(SIM_AXES, t, x(1, :), 'cyan', 'Displacement Response', 'Time (s)', 'Displacement (m)');

    SIM_INFO.string = msprintf('Natural Freq wn: %.3f rad/s\nDamping Ratio zeta: %.3f\nSystem: %s', wn, zeta, dtype);
    theme_finalize_figure(SIM_FIG);
endfunction

function sim_animate()
    global SIM_M SIM_K SIM_C SIM_X0 SIM_AXES SIM_FIG
    global SIM_ODE_M SIM_ODE_K SIM_ODE_C

    m = SIM_M.value; k = SIM_K.value; c = SIM_C.value; x0 = SIM_X0.value;
    SIM_ODE_M = m; SIM_ODE_K = k; SIM_ODE_C = c;

    t = linspace(0, 10, 200);
    x = ode([x0; 0], 0, t, sim_ode);

    chart_animate_line(SIM_AXES, t, x(1, :), 'magenta', 'Displacement Response (Animating)', 'Time (s)', 'Displacement (m)', 100, 15000);
    theme_finalize_figure(SIM_FIG);
endfunction
