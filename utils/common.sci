// =========================================================================
// common.sci
// Small shared helper functions used by more than one module.
// =========================================================================

function v = safe_evstr(s, default_val)
    // Safely evaluate a string as a numeric expression.
    // Returns default_val (default 0) instead of crashing on bad input.
    if argn(2) < 2 then
        default_val = 0;
    end
    v = default_val;
    try
        v = evstr(s);
    catch
        v = default_val;
    end
endfunction

function y = clamp(x, lo, hi)
    // Clamp x to the range [lo, hi]
    y = max(lo, min(hi, x));
endfunction

function s = fmt(val, decimals)
    // Quick numeric -> string formatter
    if argn(2) < 2 then
        decimals = 2;
    end
    fstr = '%.' + string(decimals) + 'f';
    s = msprintf(fstr, val);
endfunction

function r = safe_correl(x, y)
    // Computes the Pearson correlation coefficient between x and y.
    // Returns 0 if standard deviation of either is 0 or if lengths mismatch.
    r = 0;
    n = length(x);
    if n < 2 | length(y) <> n then
        return;
    end
    mx = mean(x); my = mean(y);
    dx = x - mx; dy = y - my;
    sx = sum(dx.^2); sy = sum(dy.^2);
    if sx == 0 | sy == 0 then
        return;
    end
    r = sum(dx .* dy) / sqrt(sx * sy);
endfunction

function cla()
    // Clears the current axes safely in Scilab
    try
        a = gca();
        if a <> [] & isfield(a, "children") then
            delete(a.children);
        end
    catch
    end
endfunction
