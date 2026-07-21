
// MODULE 3: Finance & Business Calculators
//   Tool A: Loan EMI Calculator (with amortization balance chart)
//   Tool B: Investment Growth Comparator (SIP-style, Scheme A vs Scheme B)

global FIN_FIG FIN_AXES FIN_MODE
global FIN_P FIN_R FIN_N FIN_EMIRES
global FIN_INV FIN_YRS FIN_RA FIN_RB FIN_INVRES
global FIN_EMI_GROUP FIN_INV_GROUP

function finance_open()
    global FIN_FIG FIN_AXES FIN_MODE FIN_P FIN_R FIN_N FIN_EMIRES FIN_INV FIN_YRS FIN_RA FIN_RB FIN_INVRES FIN_EMI_GROUP FIN_INV_GROUP
    f = theme_new_figure('Finance & Business Calculator', [120 40 1020 700]);
    FIN_FIG = f;

    theme_label(f, 'FINANCE & BUSINESS CALCULATORS', [250 640 550 35], theme_neon_green());

    a = newaxes();
    a.axes_bounds = [0.30 0.18 0.66 0.58];
    a.parent = f;
    a.background = 1;
    FIN_AXES = a;

    theme_label(f, 'Select Tool:', [30 590 150 20]);
    mode = uicontrol(f, 'style', 'popupmenu', ...
        'string', ['Loan EMI Calculator'; 'Investment Growth Comparator'], ...
        'position', [30 570 260 25], 'callback', 'finance_switch()');

    // ---- EMI Calculator panel ----
    p_lbl = theme_label(f, 'Principal Amount:', [30 510 160 20]);
    p_edit = theme_edit(f, '100000', [200 510 150 25]);
    r_lbl = theme_label(f, 'Annual Interest Rate (%):', [30 470 200 20]);
    r_edit = theme_edit(f, '8.5', [230 470 120 25]);
    n_lbl = theme_label(f, 'Tenure (years):', [30 430 160 20]);
    n_edit = theme_edit(f, '5', [200 430 150 25]);
    calc_btn = theme_button(f, 'Calculate EMI', [30 380 220 35], 'finance_calc_emi()', theme_neon_cyan());
    emi_result = theme_label(f, 'EMI: --   Total Payment: --   Total Interest: --', [30 300 300 70], theme_neon_purple());

    // ---- Investment Comparator panel ----
    inv_lbl = theme_label(f, 'Monthly Investment:', [30 510 160 20]);
    inv_edit = theme_edit(f, '5000', [200 510 150 25]);
    yrs_lbl = theme_label(f, 'Duration (years):', [30 470 160 20]);
    yrs_edit = theme_edit(f, '10', [200 470 150 25]);
    ra_lbl = theme_label(f, 'Scheme A Annual Return (%):', [30 430 230 20]);
    ra_edit = theme_edit(f, '6', [260 430 100 25]);
    rb_lbl = theme_label(f, 'Scheme B Annual Return (%):', [30 390 230 20]);
    rb_edit = theme_edit(f, '12', [260 390 100 25]);
    inv_btn = theme_button(f, 'Compare Growth', [30 340 220 35], 'finance_calc_invest()', theme_neon_pink());
    inv_result = theme_label(f, 'Scheme A Value: --\nScheme B Value: --', [30 260 300 70], theme_neon_purple());

    FIN_MODE = mode;
    FIN_P = p_edit; FIN_R = r_edit; FIN_N = n_edit; FIN_EMIRES = emi_result;
    FIN_INV = inv_edit; FIN_YRS = yrs_edit; FIN_RA = ra_edit; FIN_RB = rb_edit; FIN_INVRES = inv_result;

    FIN_EMI_GROUP = list(p_lbl, p_edit, r_lbl, r_edit, n_lbl, n_edit, calc_btn, emi_result);
    FIN_INV_GROUP = list(inv_lbl, inv_edit, yrs_lbl, yrs_edit, ra_lbl, ra_edit, rb_lbl, rb_edit, inv_btn, inv_result);

    for i = 1:length(FIN_INV_GROUP)
        FIN_INV_GROUP(i).visible = 'off';
    end

    theme_nav_button(f, 'Back to Home', [30 20 150 35], 'launch_home()');
    tippy_init(f);
    tippy_help_button(f, [960 640 30 30], ...
        'Choose ''Loan EMI Calculator'' or ''Investment Growth Comparator'' from the dropdown, fill in the fields, then click Calculate/Compare.');

    finance_calc_emi();
    theme_finalize_figure(f);
endfunction

function finance_switch()
    global FIN_MODE FIN_EMI_GROUP FIN_INV_GROUP FIN_FIG
    m = FIN_MODE.value;
    for i = 1:length(FIN_EMI_GROUP)
        FIN_EMI_GROUP(i).visible = fin_bool2s(m == 1);
    end
    for i = 1:length(FIN_INV_GROUP)
        FIN_INV_GROUP(i).visible = fin_bool2s(m == 2);
    end
    if m == 1 then
        finance_calc_emi();
    else
        finance_calc_invest();
    end
    theme_finalize_figure(FIN_FIG);
endfunction

function s = fin_bool2s(b)
    if b then
        s = 'on';
    else
        s = 'off';
    end
endfunction

function finance_calc_emi()
    global FIN_P FIN_R FIN_N FIN_EMIRES FIN_AXES FIN_FIG

    P = safe_evstr(FIN_P.string, 100000);
    annual_r = safe_evstr(FIN_R.string, 8.5);
    years = safe_evstr(FIN_N.string, 5);

    r = annual_r / 12 / 100;
    n = years * 12;
    if r == 0 then
        emi = P / n;
    else
        emi = P * r * (1+r)^n / ((1+r)^n - 1);
    end
    total = emi * n;
    interest = total - P;

    bal = P;
    balances = [];
    for i = 1:n
        intr = bal * r;
        princ = emi - intr;
        bal = bal - princ;
        balances($+1) = max(bal, 0);
    end

    months = 1:n;
    chart_plot_line(FIN_AXES, months, balances, 'green', 'Outstanding Loan Balance Over Time', 'Month', 'Balance');

    FIN_EMIRES.string = [msprintf('EMI: %.2f', emi); ..
                      msprintf('Total Payment: %.2f', total); ..
                      msprintf('Total Interest: %.2f', interest)];
    theme_finalize_figure(FIN_FIG);
endfunction

function finance_calc_invest()
    global FIN_INV FIN_YRS FIN_RA FIN_RB FIN_INVRES FIN_AXES FIN_FIG

    monthly = safe_evstr(FIN_INV.string, 5000);
    years = safe_evstr(FIN_YRS.string, 10);
    ra = safe_evstr(FIN_RA.string, 6) / 100 / 12;
    rb = safe_evstr(FIN_RB.string, 12) / 100 / 12;
    n = years * 12;

    valA = zeros(1, n); valB = zeros(1, n);
    for i = 1:n
        if i == 1 then
            valA(i) = monthly;
            valB(i) = monthly;
        else
            valA(i) = valA(i-1) * (1+ra) + monthly;
            valB(i) = valB(i-1) * (1+rb) + monthly;
        end
    end

    months = 1:n;
    chart_plot_multi(FIN_AXES, list(months, months), list(valA, valB), list('cyan', 'magenta'), ...
        'Investment Growth: Scheme A (cyan) vs Scheme B (magenta)', 'Month', 'Value');

    total_invested = monthly * n;
    finalA = valA(n);
    finalB = valB(n);
    FIN_INVRES.string = [msprintf('Total Invested: %.2f', total_invested); ..
                      msprintf('Scheme A Final: %.2f', finalA); ..
                      msprintf('Scheme B Final: %.2f', finalB)];

    theme_finalize_figure(FIN_FIG);
endfunction
