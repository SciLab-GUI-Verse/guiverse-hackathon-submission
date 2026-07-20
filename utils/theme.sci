// =========================================================================
// theme.sci
// Neon Dark Theme utilities for the Scilab Interactive Dashboard
// Provides a consistent color palette and factory functions for
// creating styled uicontrol widgets used across every module.
// =========================================================================

function c = theme_bg()
    // Main dashboard background (near-black)
    c = [0.07 0.07 0.10];
endfunction

function c = theme_panel()
    // Slightly lighter panel background for widgets
    c = [0.11 0.11 0.16];
endfunction

function c = theme_neon_cyan()
    c = [0 0.95 0.95];
endfunction

function c = theme_neon_pink()
    c = [1 0.10 0.60];
endfunction

function c = theme_neon_green()
    c = [0.20 1 0.40];
endfunction

function c = theme_neon_purple()
    c = [0.60 0.20 1];
endfunction

function c = theme_text()
    c = [0.90 0.95 1];
endfunction

function h = theme_button(parent, txt, pos, cb, accent)
    // Creates a neon-styled push button.
    // parent : figure handle
    // txt    : button label
    // pos    : [x y w h]
    // cb     : callback string (function call as text)
    // accent : optional foreground/neon accent color (RGB triple)
    if argn(2) < 5 then
        accent = theme_neon_cyan();
    end
    h = uicontrol(parent, 'style', 'pushbutton', ...
        'string', txt, ...
        'position', pos, ...
        'callback', cb, ...
        'backgroundcolor', theme_panel(), ...
        'foregroundcolor', accent, ...
        'fontweight', 'bold', ...
        'fontsize', 3, ...
        'horizontalalignment', 'center');
endfunction

function h = theme_label(parent, txt, pos, accent)
    if argn(2) < 4 then
        accent = theme_text();
    end
    h = uicontrol(parent, 'style', 'text', ...
        'string', txt, ...
        'position', pos, ...
        'backgroundcolor', theme_bg(), ...
        'foregroundcolor', accent, ...
        'fontweight', 'bold', ...
        'fontsize', 3, ...
        'horizontalalignment', 'left');
endfunction

function h = theme_edit(parent, txt, pos)
    h = uicontrol(parent, 'style', 'edit', ...
        'string', txt, ...
        'position', pos, ...
        'backgroundcolor', [0.15 0.15 0.20], ...
        'foregroundcolor', theme_neon_green(), ...
        'fontsize', 3);
endfunction

function fig = theme_new_figure(name, pos)
    // Creates a themed top-level figure window
    fig = figure('figure_name', name, ...
        'background', theme_bg(), ...
        'position', pos, ...
        'menubar', 'none', ...
        'toolbar', 'none', ...
        'infobar_visible', 'off', ...
        'resize', 'on');
endfunction
