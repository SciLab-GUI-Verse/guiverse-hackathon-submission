// =========================================================================
// tippy.sci
// TIPPY - the friendly on-screen guide that appears on every page of the
// dashboard. Tippy has a small animated "face" (text glyph) plus a
// speech-bubble label, and every module drops "?" help buttons that make
// Tippy speak a context-specific tip when clicked.
// =========================================================================

global TIPPY_FACE
global TIPPY_TXT

function tippy_init(parent_fig)
    // Draws Tippy (face + speech bubble) in the bottom-left corner of a figure.
    global TIPPY_FACE TIPPY_TXT
    TIPPY_FACE = uicontrol(parent_fig, 'style', 'text', ...
        'string', '(^_^)', ...
        'position', [10 10 60 30], ...
        'backgroundcolor', [0.07 0.07 0.10], ...
        'foregroundcolor', [0 1 1], ...
        'fontsize', 16, 'fontweight', 'bold');

    TIPPY_TXT = uicontrol(parent_fig, 'style', 'text', ...
        'string', 'Hi, I''m Tippy! Click any (?) button for a tip.', ...
        'position', [75 10 420 30], ...
        'backgroundcolor', [0.07 0.07 0.10], ...
        'foregroundcolor', [1 0.10 0.60], ...
        'fontsize', 13, 'horizontalalignment', 'left');
endfunction

function tippy_say(msg)
    // Makes Tippy "speak" a message and animates the face briefly.
    global TIPPY_FACE TIPPY_TXT
    if TIPPY_TXT == [] then
        return;
    end
    TIPPY_FACE.string = '(^o^)';
    TIPPY_TXT.string = msg;
endfunction

function tippy_help_button(parent, pos, msg)
    // Creates a round "?" button that makes Tippy say `msg` when clicked.
    // Uses uicontrol userdata (NOT a shared global) so each button keeps
    // its own independent tip text.
    h = uicontrol(parent, 'style', 'pushbutton', 'string', '?', ...
        'position', pos, 'callback', 'tippy_on_help()', ...
        'backgroundcolor', [0.60 0.20 1], 'foregroundcolor', [1 1 1], ...
        'fontweight', 'bold', 'fontsize', 14);
    h.userdata = msg;
endfunction

function tippy_on_help()
    // Callback bound to every "?" button - reads the message from the
    // button that was actually clicked (gcbo = "get callback object").
    h = gcbo();
    tippy_say(h.userdata);
endfunction

function tippy_wave()
    // A short, fun idle animation - call from an "Animate Tippy" button.
    global TIPPY_FACE
    faces = ['(^_^)'; '(^o^)'; '(^_-)'; ('(*o*)'); '(^_^)'];
    for i = 1:size(faces, 'r')
        TIPPY_FACE.string = faces(i);
        drawnow();
        xpause(150000);
    end
endfunction
