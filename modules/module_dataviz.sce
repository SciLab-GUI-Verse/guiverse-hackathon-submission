
// MODULE 2: Data Visualization Dashboard
// Load a CSV file, choose X/Y columns, pick a plot type, and view live
// summary statistics (mean, median, std-dev, min, max, correlation).
// A dedicated "Visualize / Animate" button plays an animated version of
// whichever plot type is currently selected.

global DV_FIG DV_AXES DV_STATUS DV_COLX DV_COLY DV_PTYPE DV_STATS DV_DATA DV_HEADERS

function dataviz_open()
    global DV_FIG DV_AXES DV_STATUS DV_COLX DV_COLY DV_PTYPE DV_STATS DV_DATA DV_HEADERS
    f = theme_new_figure('Data Visualization Dashboard', [120 40 1020 700]);
    DV_FIG = f;

    theme_label(f, 'DATA VISUALIZATION DASHBOARD', [250 640 550 35], theme_neon_pink());

    a = newaxes();
    a.axes_bounds = [0.30 0.18 0.66 0.58];
    a.parent = f;
    a.background = 1;
    DV_AXES = a;

    theme_button(f, 'Load CSV File', [30 580 220 35], 'dataviz_load()', theme_neon_cyan());
    status_lbl = theme_label(f, 'No file loaded. Try sample_data/sample.csv', [30 540 260 40], theme_neon_green());

    col_x_lbl = theme_label(f, 'X Column:', [30 490 150 20]);
    col_x = uicontrol(f, 'style', 'popupmenu', 'string', ['--'], 'position', [30 470 220 25], 'callback', 'dataviz_replot()');
    col_y_lbl = theme_label(f, 'Y Column:', [30 430 150 20]);
    col_y = uicontrol(f, 'style', 'popupmenu', 'string', ['--'], 'position', [30 410 220 25], 'callback', 'dataviz_replot()');

    plot_type_lbl = theme_label(f, 'Plot Type:', [30 370 150 20]);
    plot_type = uicontrol(f, 'style', 'popupmenu', ...
        'string', ['Line'; 'Scatter'; 'Histogram (X)'; 'Bar (mean per col)'], ...
        'position', [30 350 220 25], 'callback', 'dataviz_replot()');

    // Dedicated, always-visible button that plays an animated version of
    // whatever plot type is currently selected.
    theme_button(f, '(R) Visualize / Animate', [30 310 220 32], 'dataviz_animate()', theme_neon_pink());

    stats_lbl = theme_label(f, 'Statistics: --', [30 50 250 250], theme_neon_purple(), 12);

    DV_STATUS = status_lbl; DV_COLX = col_x; DV_COLY = col_y;
    DV_PTYPE = plot_type; DV_STATS = stats_lbl; DV_DATA = []; DV_HEADERS = [];

    theme_nav_button(f, 'Back to Home', [30 20 150 35], 'launch_home()');
    tippy_init(f);
    tippy_help_button(f, [960 640 30 30], ...
        'Click ''Load CSV File'' to import numeric data, pick X/Y columns and a plot type, then hit ''Visualize / Animate'' to play it!');
    theme_finalize_figure(f);

    dataviz_try_sample();
endfunction

function dataviz_try_sample()
    global DASH_BASE_PATH DV_STATUS
    try
        sample = DASH_BASE_PATH + 'sample_data/sample.csv';
        if isfile(sample) then
            dataviz_load_file(sample);
        end
    catch
        if DV_STATUS <> [] then
            DV_STATUS.string = 'Could not load sample data.';
        end
    end
endfunction

function dataviz_load()
    fname = uigetfile('*.csv', pwd(), 'Select a CSV file');
    if fname == '' then
        return;
    end
    dataviz_load_file(fname);
endfunction

function dataviz_load_file(fname)
    global DV_DATA DV_HEADERS DV_STATUS DV_COLX DV_COLY DV_FIG

    try
        M = csvRead(fname, ',', [], 'double', [], [], [], 1);
        hdr = csvRead(fname, ',', [], 'string', [], [], [], 0);
        headers = hdr(1, :);

        DV_DATA = M;
        DV_HEADERS = headers;
        DV_STATUS.string = 'Loaded: ' + fname + ' (' + string(size(M,1)) + ' rows)';
        DV_COLX.string = headers;
        DV_COLY.string = headers;
        DV_COLX.value = 1;
        DV_COLY.value = min(2, size(headers, '*'));
        dataviz_replot();
        theme_finalize_figure(DV_FIG);
    catch
        DV_STATUS.string = 'Error loading file: ' + lasterror();
    end
endfunction

// ---------------------------------------------------------------
// Builds the current X/Y column data + updates the statistics panel.
// Shared by both the static replot and the animated visualize path.
// ---------------------------------------------------------------
function dataviz_update_stats(xi, yi, xcol, ycol)
    global DV_HEADERS DV_STATS

    try
        m = mean(xcol); md = median(xcol); sd = stdev(xcol);
        mn = min(xcol); mx = max(xcol);
    catch
        m = 0; md = 0; sd = 0; mn = 0; mx = 0;
    end

    try
        corrv = safe_correl(xcol, ycol);
    catch
        corrv = 0;
    end

    // Guard against a header cell that (for whatever reason) isn't a
    // plain string - convert it defensively so msprintf never chokes.
    colname = DV_HEADERS(xi);
    if type(colname) <> 10 then
        colname = string(colname);
    end

    // Built as ONE msprintf call (no '+' concatenation) so a stray
    // non-scalar/non-string value can't produce a malformed 'string'
    // property and crash the UI control assignment.
    DV_STATS.string = msprintf(['Column: %s'; ...
        'Mean:   %.4f'; ...
        'Median: %.4f'; ...
        'StdDev: %.4f'; ...
        'Min:    %.4f'; ...
        'Max:    %.4f'; ...
        'Correlation(X,Y): %.4f'], colname, m, md, sd, mn, mx, corrv);
endfunction

function dataviz_replot()
    global DV_DATA DV_HEADERS DV_AXES DV_COLX DV_COLY DV_PTYPE DV_STATS DV_FIG DV_STATUS

    if DV_DATA == [] then
        return;
    end

    try
        xi = DV_COLX.value; yi = DV_COLY.value;
        xcol = DV_DATA(:, xi); ycol = DV_DATA(:, yi);

        ptype = DV_PTYPE.value;
        select ptype
        case 1 then
            chart_plot_line(DV_AXES, xcol, ycol, 'cyan', 'Line Plot', DV_HEADERS(xi), DV_HEADERS(yi));
        case 2 then
            chart_plot_scatter(DV_AXES, xcol, ycol, 'pink', 'Scatter Plot', DV_HEADERS(xi), DV_HEADERS(yi));
        case 3 then
            chart_plot_hist(DV_AXES, xcol, 12, 'purple', 'Histogram', DV_HEADERS(xi), 'Frequency');
        case 4 then
            means = mean(DV_DATA, 'r');
            chart_plot_bar(DV_AXES, means, 'green', 'Mean per Column', 'Column Index', 'Mean Value');
        end

        dataviz_update_stats(xi, yi, xcol, ycol);
        theme_finalize_figure(DV_FIG);
    catch
        DV_STATUS.string = 'Plot error: ' + lasterror();
    end
endfunction

// ---------------------------------------------------------------
// Plays an animated version of whichever plot type is selected.
// Triggered by the "Visualize / Animate" button.
// ---------------------------------------------------------------
function dataviz_animate()
    global DV_DATA DV_HEADERS DV_AXES DV_COLX DV_COLY DV_PTYPE DV_STATS DV_FIG DV_STATUS

    if DV_DATA == [] then
        DV_STATUS.string = 'Load a CSV file first.';
        return;
    end

    try
        xi = DV_COLX.value; yi = DV_COLY.value;
        xcol = DV_DATA(:, xi); ycol = DV_DATA(:, yi);

        ptype = DV_PTYPE.value;
        select ptype
        case 1 then
            chart_animate_line(DV_AXES, xcol, ycol, 'cyan', 'Line Plot', DV_HEADERS(xi), DV_HEADERS(yi));
        case 2 then
            chart_animate_marker(DV_AXES, xcol, ycol, 'pink', 'Scatter Plot', DV_HEADERS(xi), DV_HEADERS(yi));
        case 3 then
            chart_animate_hist(DV_AXES, xcol, 12, 'purple', 'Histogram', DV_HEADERS(xi), 'Frequency');
        case 4 then
            means = mean(DV_DATA, 'r');
            chart_animate_bar(DV_AXES, means, 'green', 'Mean per Column', 'Column Index', 'Mean Value');
        end

        dataviz_update_stats(xi, yi, xcol, ycol);
        theme_finalize_figure(DV_FIG);
    catch
        DV_STATUS.string = 'Animation error: ' + lasterror();
    end
endfunction
