// =========================================================================
// theme.sci
// Neon Dark Theme utilities for the Scilab Interactive Dashboard
// =========================================================================


// =========================
// Color Palette
// =========================

function c = theme_bg()
    // Main window background
    c = [0.08 0.08 0.10];
endfunction

function c = theme_panel()
    // Panel / Button background
    c = [0.18 0.19 0.25];
endfunction

function c = theme_neon_cyan()
    c = [0.00 0.95 0.95];
endfunction

function c = theme_neon_pink()
    c = [1.00 0.10 0.60];
endfunction

function c = theme_neon_green()
    c = [0.20 1.00 0.40];
endfunction

function c = theme_neon_purple()
    c = [0.60 0.20 1.00];
endfunction

function c = theme_text()
    c = [0.95 0.95 0.98];
endfunction



// =========================
// Figure
// =========================

function fig = theme_new_figure(name, pos)

    fig = figure( ...
        "figure_name", name, ...
        "position", pos, ...
        "background", theme_bg(), ...
        "menubar", "none", ...
        "toolbar", "none", ...
        "infobar_visible", "off", ...
        "resize", "on");

endfunction



// =========================
// Labels
// =========================

function h = theme_label(parent, txt, pos, accent, fontsize)

    if argn(2) < 4 then
        accent = theme_text();
    end

    if argn(2) < 5 then
        fontsize = 14;
    end

    h = uicontrol(parent, ...
        "style", "text", ...
        "string", txt, ...
        "position", pos, ...
        "backgroundcolor", theme_bg(), ...
        "foregroundcolor", accent, ...
        "fontweight", "bold", ...
        "fontsize", fontsize, ...
        "horizontalalignment", "left");

endfunction



// =========================
// Buttons
// =========================

function h = theme_button(parent, txt, pos, cb, accent, fontsize)

    if argn(2) < 5 then
        accent = theme_neon_cyan();
    end

    if argn(2) < 6 then
        fontsize = 14;
    end

    h = uicontrol(parent, ...
        "style", "pushbutton", ...
        "string", txt, ...
        "position", pos, ...
        "callback", cb, ...
        "backgroundcolor", theme_panel(), ...
        "foregroundcolor", accent, ...
        "fontweight", "bold", ...
        "fontsize", fontsize, ...
        "horizontalalignment", "center");

endfunction



// =========================
// Edit Boxes
// =========================

function h = theme_edit(parent, txt, pos, fontsize)

    if argn(2) < 4 then
        fontsize = 13;
    end

    h = uicontrol(parent, ...
        "style", "edit", ...
        "string", txt, ...
        "position", pos, ...
        "backgroundcolor", [0.14 0.14 0.20], ...
        "foregroundcolor", theme_text(), ...
        "fontsize", fontsize);

endfunction



// =========================
// Frames
// =========================

function h = theme_frame(parent, title, pos)

    h = uicontrol(parent, ...
        "style", "frame", ...
        "string", title, ...
        "position", pos, ...
        "backgroundcolor", theme_panel());

endfunction



// =========================
// Popup Menu
// =========================

function h = theme_popup(parent, items, pos)

    h = uicontrol(parent, ...
        "style", "popupmenu", ...
        "string", items, ...
        "position", pos, ...
        "backgroundcolor", [1 1 1], ...
        "foregroundcolor", [0 0 0], ...
        "fontsize", 13);

endfunction



// =========================
// List Box
// =========================

function h = theme_list(parent, items, pos)

    h = uicontrol(parent, ...
        "style", "listbox", ...
        "string", items, ...
        "position", pos, ...
        "backgroundcolor", theme_panel(), ...
        "foregroundcolor", theme_text(), ...
        "fontsize", 13);

endfunction