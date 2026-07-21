
// Themed, animated chart helpers for the Scilab Interactive Dashboard.

function theme_pause(us)
    // Safe wrapper: some Scilab installs no longer ship 'xpause'
    // (deprecated/removed). Fall back to 'sleep', which takes
    // milliseconds instead of microseconds.
    try
        xpause(us);
    catch
        sleep(round(us/1000));
    end
endfunction

function theme_style_axes(a)
    if a == [] then
        return;
    end
    a.background = [0.10 0.10 0.14];
    a.foreground = [0.45 0.45 0.55];
    a.font_foreground = [0.85 0.85 0.92];
    a.font_size = 3;
    a.grid = [1 1];
    a.grid_style = [6 6];
    a.tight_limits = "on";
    a.box = "on";
    a.margins = [0.12 0.06 0.06 0.06];
endfunction

function c = chart_color(name)
    select name
    case "cyan" then
        c = [0.00 0.95 0.95];
    case "pink" then
        c = [1.00 0.10 0.60];
    case "green" then
        c = [0.20 1.00 0.40];
    case "purple" then
        c = [0.60 0.20 1.00];
    case "yellow" then
        c = [1.00 0.92 0.20];
    case "magenta" then
        c = [1.00 0.20 0.80];
    case "orange" then
        c = [1.00 0.55 0.10];
    else
        c = [0.00 0.95 0.95];
    end
endfunction

function chart_style_line(col, thick)
    if argn(2) < 2 then
        thick = 2;
    end
    e = gce();
    // Defensive: only style entities that actually expose foreground/thickness
    // (i.e. an actual Polyline). plot2d doesn't always hand back a Polyline -
    // e.g. plotting a single data point (as happens on the first frame of an
    // animation, or any degenerate 1-point series) can return a handle that
    // has no 'foreground'/'thickness' property, which used to crash here.
    if typeof(e) == "Polyline" then
        e.foreground = chart_color(col);
        e.thickness = thick;
    end
endfunction

function chart_plot_line(a, x, y, col, title_str, xlbl, ylbl)
    if argn(2) < 4 then
        col = "cyan";
    end
    if argn(2) < 5 then
        title_str = "";
    end
    if argn(2) < 6 then
        xlbl = "";
    end
    if argn(2) < 7 then
        ylbl = "";
    end

    sca(a);
    cla();
    theme_style_axes(a);
    plot2d(x, y, style = -1);
    chart_style_line(col, 2.5);
    xtitle(title_str, xlbl, ylbl);
endfunction

function chart_plot_scatter(a, x, y, col, title_str, xlbl, ylbl)
    if argn(2) < 4 then
        col = "pink";
    end
    if argn(2) < 5 then
        title_str = "";
    end
    if argn(2) < 6 then
        xlbl = "";
    end
    if argn(2) < 7 then
        ylbl = "";
    end

    sca(a);
    cla();
    theme_style_axes(a);
    plot2d(x, y, style = -9);
    chart_style_line(col, 1.5);
    xtitle(title_str, xlbl, ylbl);
endfunction

function chart_plot_multi(a, xs, ys, cols, title_str, xlbl, ylbl)
    sca(a);
    cla();
    theme_style_axes(a);
    n = length(xs);
    for i = 1:n
        if i == 1 then
            plot2d(xs(i), ys(i), style = -1);
        else
            plot2d(xs(i), ys(i), style = -1, strf = "000");
        end
        chart_style_line(cols(i), 2.5);
    end
    xtitle(title_str, xlbl, ylbl);
endfunction

function chart_plot_hist(a, data, nbins, col, title_str, xlbl, ylbl)
    if argn(2) < 4 then
        col = "purple";
    end
    if argn(2) < 5 then
        title_str = "";
    end
    if argn(2) < 6 then
        xlbl = "";
    end
    if argn(2) < 7 then
        ylbl = "";
    end

    sca(a);
    cla();
    theme_style_axes(a);
    histplot(nbins, data);
    chart_style_line(col, 2);
    xtitle(title_str, xlbl, ylbl);
endfunction

function chart_plot_bar(a, values, col, title_str, xlbl, ylbl)
    if argn(2) < 3 then
        col = "green";
    end
    if argn(2) < 4 then
        title_str = "";
    end
    if argn(2) < 5 then
        xlbl = "";
    end
    if argn(2) < 6 then
        ylbl = "";
    end

    sca(a);
    cla();
    theme_style_axes(a);
    bar(values);
    chart_style_line(col, 2);
    xtitle(title_str, xlbl, ylbl);
endfunction

function chart_animate_line(a, x, y, col, title_str, xlbl, ylbl, nframes, pause_us)
    if argn(2) < 4 then
        col = "cyan";
    end
    if argn(2) < 8 then
        nframes = 60;
    end
    if argn(2) < 9 then
        pause_us = 18000;
    end

    n = min([nframes, length(x)]);
    idx = round(linspace(1, length(x), n));

    sca(a);
    for i = 1:n
        k = idx(i);
        cla();
        theme_style_axes(a);
        // A "line" needs at least 2 points - on the first frame (k could be
        // 1), skip the trail plot entirely rather than handing plot2d a
        // single point, which doesn't return a real Polyline.
        if k >= 2 then
            plot2d(x(1:k), y(1:k), style = -1);
            chart_style_line(col, 2.5);
        end
        plot2d(x(k), y(k), style = -9, strf = "000");
        e = gce();
        if typeof(e) == "Polyline" then
            e.foreground = chart_color("yellow");
            e.thickness = 2;
        end
        xtitle(title_str + "  [" + string(round(100*i/n)) + "%]", xlbl, ylbl);
        drawnow();
        theme_pause(pause_us);
    end
endfunction

function chart_animate_marker(a, x, y, col, title_str, xlbl, ylbl, nframes, pause_us)
    if argn(2) < 4 then
        col = "cyan";
    end
    if argn(2) < 8 then
        nframes = 60;
    end
    if argn(2) < 9 then
        pause_us = 20000;
    end

    n = min([nframes, length(x)]);
    idx = round(linspace(1, length(x), n));

    sca(a);
    for i = 1:n
        k = idx(i);
        cla();
        theme_style_axes(a);
        // Same fix as chart_animate_line: don't plot2d a degenerate 1-point
        // "line" - it doesn't create a Polyline and crashes chart_style_line.
        if k >= 2 then
            plot2d(x(1:k), y(1:k), style = -1);
            chart_style_line(col, 2);
        end
        plot2d(x(k), y(k), style = -9, strf = "000");
        e = gce();
        if typeof(e) == "Polyline" then
            e.foreground = chart_color("yellow");
            e.thickness = 2;
        end
        xtitle(title_str, xlbl, ylbl);
        drawnow();
        theme_pause(pause_us);
    end
endfunction

// Raise any UI controls so plots never hide them

function theme_raise_ui(handles)

    if handles == [] then
        return;
    end

    for i = 1:length(handles)

        h = handles(i);

        try
            // Re-assigning the position forces Scilab
            // to redraw this control above graphics axes.
            p = h.position;
            h.position = p;
        catch
        end

    end

endfunction

// Navigation button

function h = theme_nav_button(parent, txt, pos, cb)

    h = theme_button(parent, txt, pos, cb, theme_neon_pink(), 13);

    h.tag = "nav_back";

    tippy_register_nav(parent, h);

endfunction

// Finalize figure

function theme_finalize_figure(fig)

    // Raise tooltip controls first
    try
        tippy_raise(fig);
    catch
    end

    // Raise Back/Home button
    try

        kids = fig.children;

        nav = list();

        for i = 1:length(kids)

            try
                if typeof(kids(i)) == "UIControl" then

                    if kids(i).tag == "nav_back" then
                        nav($+1) = kids(i);
                    end

                end
            catch
            end

        end

        theme_raise_ui(nav);

    catch
    end

endfunction
