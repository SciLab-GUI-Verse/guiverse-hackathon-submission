// =========================================================================
// module_dataviz.sce
// MODULE 2: Data Visualization Dashboard
// Load a CSV file, choose X/Y columns, pick a plot type, and view live
// summary statistics (mean, median, std-dev, min, max, correlation).
// =========================================================================

global DV_AXES DV_STATUS DV_COLX DV_COLY DV_PTYPE DV_STATS DV_DATA DV_HEADERS

function dataviz_open()
    f = theme_new_figure('Data Visualization Dashboard', [120 40 1020 700]);
    theme_label(f, 'DATA VISUALIZATION DASHBOARD', [250 640 550 35], theme_neon_pink());

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

    stats_lbl = theme_label(f, 'Statistics: --', [30 60 250 260], theme_neon_purple());
    stats_lbl.fontsize = 2;

    a = newaxes();
    a.axes_bounds = [0.30 0.10 0.66 0.68];
    a.parent = f;
    a.background = 1;

    DV_AXES = a; DV_STATUS = status_lbl; DV_COLX = col_x; DV_COLY = col_y;
    DV_PTYPE = plot_type; DV_STATS = stats_lbl; DV_DATA = []; DV_HEADERS = [];

    theme_button(f, 'Back to Home', [30 20 150 35], 'launch_home()', theme_neon_pink());
    tippy_init(f);
    tippy_help_button(f, [960 640 30 30], ...
        'Click "Load CSV File" to import numeric data. Then pick X/Y columns and a plot type - the statistics panel updates automatically!');
endfunction

function dataviz_load()
    global DV_DATA DV_HEADERS DV_STATUS DV_COLX DV_COLY

    fname = uigetfile('*.csv', pwd(), 'Select a CSV file');
    if fname == '' then
        return;
    end

    M = csvRead(fname, ',', [], 'double', [], [], [], 1);       // numeric rows, skip header
    hdr = csvRead(fname, ',', [], 'string', [], [], [], 0);     // header row as strings
    headers = hdr(1, :);

    DV_DATA = M;
    DV_HEADERS = headers;
    DV_STATUS.string = 'Loaded: ' + fname + ' (' + string(size(M,1)) + ' rows)';
    DV_COLX.string = headers;
    DV_COLY.string = headers;
    DV_COLX.value = 1;
    DV_COLY.value = min(2, size(headers, '*'));
    dataviz_replot();
endfunction

function dataviz_replot()
    global DV_DATA DV_HEADERS DV_AXES DV_COLX DV_COLY DV_PTYPE DV_STATS

    if DV_DATA == [] then
        return;
    end

    xi = DV_COLX.value; yi = DV_COLY.value;
    xcol = DV_DATA(:, xi); ycol = DV_DATA(:, yi);

    sca(DV_AXES);
    cla();
    ptype = DV_PTYPE.value;
    select ptype
    case 1 then
        plot2d(xcol, ycol, style = color("cyan"));
        xtitle('Line Plot', DV_HEADERS(xi), DV_HEADERS(yi));
    case 2 then
        plot2d(xcol, ycol, style = -9);
        xtitle('Scatter Plot', DV_HEADERS(xi), DV_HEADERS(yi));
    case 3 then
        histplot(10, xcol, style = 5);
        xtitle('Histogram', DV_HEADERS(xi), 'Frequency');
    case 4 then
        means = mean(DV_DATA, 'r');
        bar(means);
        xtitle('Mean per Column', 'Column Index', 'Mean Value');
    end

    m = mean(xcol); md = median(xcol); sd = stdev(xcol);
    mn = min(xcol); mx = max(xcol);
    corrv = correl(xcol, ycol);

    DV_STATS.string = 'Column: ' + DV_HEADERS(xi) + ...
        msprintf('\nMean:   %.4f', m) + ...
        msprintf('\nMedian: %.4f', md) + ...
        msprintf('\nStdDev: %.4f', sd) + ...
        msprintf('\nMin:    %.4f', mn) + ...
        msprintf('\nMax:    %.4f', mx) + ...
        msprintf('\nCorrelation(X,Y): %.4f', corrv);
endfunction
