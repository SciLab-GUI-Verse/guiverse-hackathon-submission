// =========================================================================
// tippy.sci
// TIPPY - the friendly on-screen guide that appears on every page of the
// dashboard. Each figure stores its own Tippy handles in fig.userdata so
// tips always update the correct window (no stale global handles).
// =========================================================================

function tippy_init(parent_fig)
    face = uicontrol(parent_fig, 'style', 'text', ...
        'string', '(^_^)', ...
        'position', [10 55 60 30], ...
        'backgroundcolor', [0.07 0.07 0.10], ...
        'foregroundcolor', [0 1 1], ...
        'fontsize', 16, 'fontweight', 'bold', ...
        'tag', 'tippy_face');

    txt = uicontrol(parent_fig, 'style', 'text', ...
        'string', 'Hi, I''m Tippy! Click any (?) button for a tip.', ...
        'position', [75 55 520 30], ...
        'backgroundcolor', [0.07 0.07 0.10], ...
        'foregroundcolor', [1 0.10 0.60], ...
        'fontsize', 13, 'horizontalalignment', 'left', ...
        'tag', 'tippy_txt');

    ud = tippy_get_ud(parent_fig);
    ud.face = face;
    ud.txt = txt;
    parent_fig.userdata = ud;
endfunction

function ud = tippy_get_ud(fig)
    if fig.userdata == [] then
        ud = struct('face', [], 'txt', [], 'help_btns', [], 'nav_btns', []);
    else
        ud = fig.userdata;
        if ~isfield(ud, 'face') then
            ud.face = [];
        end
        if ~isfield(ud, 'txt') then
            ud.txt = [];
        end
        if ~isfield(ud, 'help_btns') then
            ud.help_btns = [];
        end
        if ~isfield(ud, 'nav_btns') then
            ud.nav_btns = [];
        end
    end
endfunction

function tippy_register_nav(fig, btn)
    ud = tippy_get_ud(fig);
    ud.nav_btns = [ud.nav_btns, btn];
    fig.userdata = ud;
endfunction

function tippy_say(fig, msg)
    if argn(2) < 1 then
        fig = gcf();
    end
    ud = tippy_get_ud(fig);
    if ud.txt == [] then
        return;
    end
    ud.face.string = '(^o^)';
    ud.txt.string = msg;
    fig.userdata = ud;
    tippy_raise(fig);
endfunction

function tippy_help_button(parent, pos, msg)
    h = uicontrol(parent, 'style', 'pushbutton', 'string', '?', ...
        'position', pos, 'callback', 'tippy_on_help()', ...
        'backgroundcolor', [0.60 0.20 1], 'foregroundcolor', [1 1 1], ...
        'fontweight', 'bold', 'fontsize', 14, ...
        'tag', 'tippy_help');
    h.userdata = msg;

    ud = tippy_get_ud(parent);
    ud.help_btns = [ud.help_btns, h];
    parent.userdata = ud;
endfunction

function tippy_on_help()
    btn = gcbo();
    fig = btn.parent;
    tippy_say(fig, btn.userdata);
endfunction

function tippy_raise(fig)
    ud = tippy_get_ud(fig);
    handles = [];
    if ud.face <> [] then
        handles = [handles, ud.face];
    end
    if ud.txt <> [] then
        handles = [handles, ud.txt];
    end
    if ud.help_btns <> [] then
        handles = [handles, ud.help_btns];
    end
    if ud.nav_btns <> [] then
        handles = [handles, ud.nav_btns];
    end
    theme_raise_ui(handles);
endfunction

function tippy_wave()
    fig = gcf();
    ud = tippy_get_ud(fig);
    if ud.face == [] then
        return;
    end
    faces = ['(^_^)'; '(^o^)'; '(^_-)'; ('(*o*)'); '(^_^)'];
    for i = 1:size(faces, 'r')
        ud.face.string = faces(i);
        fig.userdata = ud;
        drawnow();
        xpause(150000);
    end
endfunction
