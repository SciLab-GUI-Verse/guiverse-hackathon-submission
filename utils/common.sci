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
