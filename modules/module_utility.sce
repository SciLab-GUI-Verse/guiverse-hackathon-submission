// =========================================================================
// module_utility.sce
// MODULE 5: Utility & Productivity Tools
//   Tool A: Unit Converter (length / weight / temperature)
//   Tool B: Matrix Equation Solver  (A x = b)
//   Tool C: Stopwatch Timer
// =========================================================================

global UTIL_GROUPS
global UTIL_CAT UTIL_IN UTIL_FROM UTIL_TO UTIL_RES
global UTIL_MAT_A UTIL_MAT_B UTIL_MAT_RES
global UTIL_SW_LABEL UTIL_SW_RUNNING

function utility_open()
    f = theme_new_figure('Utility & Productivity Tools', [120 40 1020 700]);
    theme_label(f, 'UTILITY & PRODUCTIVITY TOOLS', [270 640 550 35], theme_neon_cyan());

    uicontrol(f, 'style', 'listbox', ...
        'string', ['Unit Converter'; 'Matrix Equation Solver'; 'Stopwatch Timer'], ...
        'position', [30 520 220 90], ...
        'backgroundcolor', [0.12 0.12 0.18], ...
        'foregroundcolor', theme_neon_green(), ...
        'fontsize', 3, ...
        'callback', 'util_switch()');

    UTIL_GROUPS = list();

    util_build_converter(f);
    util_build_matrix(f);
    util_build_stopwatch(f);

    util_show_only(1);

    theme_button(f, 'Back to Home', [30 20 150 35], 'launch_home()', theme_neon_pink());
    tippy_init(f);
    tippy_help_button(f, [960 640 30 30], ...
        'Pick a tool from the list: convert units, solve A x = b matrix equations, or use the stopwatch for timing tasks.');
endfunction

function util_switch()
    lb = gcbo();
    util_show_only(lb.value);
endfunction

function util_show_only(idx)
    global UTIL_GROUPS
    for i = 1:length(UTIL_GROUPS)
        grp = UTIL_GROUPS(i);
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
// Tool A: Unit Converter
// ------------------------------------------------------------------
function util_build_converter(f)
    global UTIL_GROUPS UTIL_CAT UTIL_IN UTIL_FROM UTIL_TO UTIL_RES

    cat_lbl = theme_label(f, 'Category:', [300 580 150 20]);
    cat = uicontrol(f, 'style', 'popupmenu', 'string', ['Length'; 'Weight'; 'Temperature'], ...
        'position', [300 560 220 25], 'callback', 'util_conv_cat_change()');
    in_lbl = theme_label(f, 'Input Value:', [300 510 150 20]);
    in_edit = theme_edit(f, '1', [450 510 150 25]);
    from_lbl = theme_label(f, 'From Unit:', [300 470 150 20]);
    from_menu = uicontrol(f, 'style', 'popupmenu', 'string', ['m'; 'km'; 'cm'; 'ft'; 'mile'], ...
        'position', [300 450 150 25], 'callback', 'util_conv_calc()');
    to_lbl = theme_label(f, 'To Unit:', [470 470 150 20]);
    to_menu = uicontrol(f, 'style', 'popupmenu', 'string', ['m'; 'km'; 'cm'; 'ft'; 'mile'], ...
        'position', [470 450 150 25], 'callback', 'util_conv_calc()');
    calc_btn = theme_button(f, 'Convert', [300 400 220 35], 'util_conv_calc()', theme_neon_green());
    res_lbl = theme_label(f, 'Result: --', [300 350 380 30], theme_neon_purple());

    UTIL_CAT = cat; UTIL_IN = in_edit; UTIL_FROM = from_menu; UTIL_TO = to_menu; UTIL_RES = res_lbl;

    UTIL_GROUPS($+1) = list(cat_lbl, cat, in_lbl, in_edit, from_lbl, from_menu, to_lbl, to_menu, calc_btn, res_lbl);
endfunction

function util_conv_cat_change()
    global UTIL_CAT UTIL_FROM UTIL_TO
    catv = UTIL_CAT.value;
    if catv == 1 then
        u = ['m'; 'km'; 'cm'; 'ft'; 'mile'];
    elseif catv == 2 then
        u = ['kg'; 'g'; 'lb'; 'oz'];
    else
        u = ['Celsius'; 'Fahrenheit'; 'Kelvin'];
    end
    UTIL_FROM.string = u; UTIL_FROM.value = 1;
    UTIL_TO.string = u; UTIL_TO.value = 1;
    util_conv_calc();
endfunction

function util_conv_calc()
    global UTIL_CAT UTIL_IN UTIL_FROM UTIL_TO UTIL_RES

    cval = safe_evstr(UTIL_IN.string, 1);
    catv = UTIL_CAT.value;
    fi = UTIL_FROM.value; ti = UTIL_TO.value;

    if catv == 1 then
        units = ['m', 'km', 'cm', 'ft', 'mile'];
        factors = [1, 1000, 0.01, 0.3048, 1609.34];
        base = cval * factors(fi);
        out = base / factors(ti);
        UTIL_RES.string = msprintf('Result: %.4f %s', out, units(ti));
    elseif catv == 2 then
        units = ['kg', 'g', 'lb', 'oz'];
        factors = [1, 0.001, 0.453592, 0.0283495];
        base = cval * factors(fi);
        out = base / factors(ti);
        UTIL_RES.string = msprintf('Result: %.4f %s', out, units(ti));
    else
        // Temperature: normalize to Celsius, then to target
        if fi == 1 then
            c = cval;
        elseif fi == 2 then
            c = (cval - 32) * 5/9;
        else
            c = cval - 273.15;
        end
        if ti == 1 then
            out = c;
        elseif ti == 2 then
            out = c*9/5 + 32;
        else
            out = c + 273.15;
        end
        units = ['Celsius', 'Fahrenheit', 'Kelvin'];
        UTIL_RES.string = msprintf('Result: %.4f %s', out, units(ti));
    end
endfunction

// ------------------------------------------------------------------
// Tool B: Matrix Equation Solver (A x = b)
// ------------------------------------------------------------------
function util_build_matrix(f)
    global UTIL_GROUPS UTIL_MAT_A UTIL_MAT_B UTIL_MAT_RES

    lbl = theme_label(f, 'Matrix A (Scilab syntax, e.g. [2 1;1 3]):', [300 580 450 20]);
    a_edit = theme_edit(f, '[2 1;1 3]', [300 550 400 25]);
    lbl2 = theme_label(f, 'Vector b (e.g. [5;10]):', [300 500 400 20]);
    b_edit = theme_edit(f, '[5;10]', [300 470 400 25]);
    solve_btn = theme_button(f, 'Solve A x = b', [300 420 220 35], 'util_matrix_solve()', theme_neon_cyan());
    res_lbl = theme_label(f, 'Solution x: --', [300 360 450 60], theme_neon_purple());

    UTIL_MAT_A = a_edit; UTIL_MAT_B = b_edit; UTIL_MAT_RES = res_lbl;

    grp = list(lbl, a_edit, lbl2, b_edit, solve_btn, res_lbl);
    for i = 1:length(grp)
        grp(i).visible = 'off';
    end
    UTIL_GROUPS($+1) = grp;
endfunction

function util_matrix_solve()
    global UTIL_MAT_A UTIL_MAT_B UTIL_MAT_RES

    A = evstr(UTIL_MAT_A.string);
    b = evstr(UTIL_MAT_B.string);

    if size(A, 1) <> size(A, 2) then
        UTIL_MAT_RES.string = 'Error: A must be a square matrix.';
        return;
    end
    if det(A) == 0 then
        UTIL_MAT_RES.string = 'Error: Matrix A is singular (no unique solution).';
        return;
    end

    x = A \ b;
    UTIL_MAT_RES.string = 'Solution x = ' + strcat(string(x'), '   ');
endfunction

// ------------------------------------------------------------------
// Tool C: Stopwatch Timer
// ------------------------------------------------------------------
function util_build_stopwatch(f)
    global UTIL_GROUPS UTIL_SW_LABEL UTIL_SW_RUNNING

    lbl = theme_label(f, 'Stopwatch - click Start, then Stop:', [300 580 400 25]);
    time_lbl = theme_label(f, '0.0 s', [300 500 250 50], theme_neon_green());
    time_lbl.fontsize = 5;
    start_btn = theme_button(f, 'Start', [300 440 100 35], 'util_sw_start()', theme_neon_cyan());
    stop_btn = theme_button(f, 'Stop', [410 440 100 35], 'util_sw_stop()', theme_neon_pink());
    reset_btn = theme_button(f, 'Reset', [520 440 100 35], 'util_sw_reset()', theme_neon_purple());

    UTIL_SW_LABEL = time_lbl; UTIL_SW_RUNNING = %f;

    grp = list(lbl, time_lbl, start_btn, stop_btn, reset_btn);
    for i = 1:length(grp)
        grp(i).visible = 'off';
    end
    UTIL_GROUPS($+1) = grp;
endfunction

function util_sw_start()
    // NOTE: this uses a poll loop (xpause + drawnow) so the "Stop" button
    // callback can still fire while the stopwatch is running - a common
    // pattern for simple GUI timers in Scilab (no native timer callback).
    global UTIL_SW_RUNNING UTIL_SW_LABEL

    tic();
    UTIL_SW_RUNNING = %t;
    while UTIL_SW_RUNNING
        elapsed = toc();
        UTIL_SW_LABEL.string = msprintf('%.1f s', elapsed);
        drawnow();
        xpause(100000);
    end
endfunction

function util_sw_stop()
    global UTIL_SW_RUNNING
    UTIL_SW_RUNNING = %f;
endfunction

function util_sw_reset()
    global UTIL_SW_RUNNING UTIL_SW_LABEL
    UTIL_SW_RUNNING = %f;
    UTIL_SW_LABEL.string = '0.0 s';
endfunction
