
// Entry point. Run this file from Scilab (exec or "Open and run") to
// launch the Home Screen, from which every category module can be opened.
//
// Project structure:
//   main_dashboard.sce         <- you are here
//   utils/theme.sci            <- neon dark theme + widget factories
//   utils/common.sci           <- shared helper functions
//   tippy/tippy.sci            <- Tippy the guide character
//   modules/module_stem.sce        <- 1. Interactive STEM Education
//   modules/module_dataviz.sce     <- 2. Data Visualization Dashboard
//   modules/module_finance.sce     <- 3. Finance & Business Calculators
//   modules/module_simulator.sce   <- 4. Science & Engineering Simulator
//   modules/module_utility.sce     <- 5. Utility & Productivity Tools


BASE_PATH = get_absolute_file_path('main_dashboard.sce');

exec(BASE_PATH + 'utils/theme.sci', -1);
exec(BASE_PATH + 'utils/common.sci', -1);
exec(BASE_PATH + 'utils/charts.sci', -1);
exec(BASE_PATH + 'tippy/tippy.sci', -1);

// Load ALL modules here, at the TOP LEVEL of this script (not inside any
// function). This is important: if exec() is called from inside a
// function body, the functions defined by the executed file only stay in
// scope for the lifetime of that function call and disappear afterwards.
// Loading them here instead means their functions (dataviz_open,
// dataviz_replot, dataviz_animate, etc.) are registered globally, once,
// and remain callable for the whole session - including from UI
// callback strings evaluated at the top level (e.g. popupmenu/button
// callbacks like 'dataviz_replot()').
exec(BASE_PATH + 'modules/module_stem.sce', -1);
exec(BASE_PATH + 'modules/module_dataviz.sce', -1);
exec(BASE_PATH + 'modules/module_finance.sce', -1);
exec(BASE_PATH + 'modules/module_simulator.sce', -1);
exec(BASE_PATH + 'modules/module_utility.sce', -1);

global DASH_BASE_PATH
DASH_BASE_PATH = BASE_PATH;

function launch_home()
    // Closes any open dashboard windows and (re)draws the home screen.
    close(winsid());

    f = theme_new_figure('Scilab Interactive Dashboard - Home', [150 80 1000 680]);

    theme_label(f, ...
    'SCILAB INTERACTIVE DASHBOARD', ...
    [180 610 650 40], ...
    theme_neon_cyan(), ...
    22);
    
    theme_label(f, ...
    'Five domains. One dashboard. Pick a module to begin:', ...
    [220 570 600 30], ...
    theme_neon_purple(), ...
    14);

    theme_button(f, '1.  Interactive STEM Education',     [300 480 400 45], 'launch_stem()',      theme_neon_cyan());
    theme_button(f, '2.  Data Visualization Dashboard',    [300 420 400 45], 'launch_dataviz()',   theme_neon_pink());
    theme_button(f, '3.  Finance & Business Calculators',  [300 360 400 45], 'launch_finance()',   theme_neon_green());
    theme_button(f, '4.  Science & Engineering Simulator', [300 300 400 45], 'launch_simulator()', theme_neon_purple());
    theme_button(f, '5.  Utility & Productivity Tools',    [300 240 400 45], 'launch_utility()',    theme_neon_cyan());

    theme_button(f, 'Exit Dashboard', [420 160 160 35], 'close(winsid())', theme_neon_pink());

    tippy_init(f);
    tippy_help_button(f, [940 610 30 30], ...
        'Welcome to the dashboard! Click any numbered button to open that module. Every module has its own Tippy tips too - just look for the (?) button.');
    theme_finalize_figure(f);
endfunction

function launch_stem()
    close(winsid());
    stem_open();
endfunction

function launch_dataviz()
    close(winsid());
    dataviz_open();
endfunction

function launch_finance()
    close(winsid());
    finance_open();
endfunction

function launch_simulator()
    close(winsid());
    simulator_open();
endfunction

function launch_utility()
    close(winsid());
    utility_open();
endfunction

// ---- boot the app ----
launch_home();