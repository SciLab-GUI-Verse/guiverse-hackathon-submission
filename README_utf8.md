# guiverse-hackathon-submission

# Scilab Interactive Dashboard 🚀
### A single dashboard, five domains — STEM · Data · Finance · Simulation · Utility

A modular, dark-neon themed **Scilab GUI** application built for the hackathon. Instead of five
separate toy apps, this project combines all five suggested categories into **one unified
multi-page dashboard**, connected by a recurring on-screen guide character, **Tippy**, who gives
contextual help on every page.

---

## ✨ What's inside

| # | Module | What it does |
|---|--------|---------------|
| 1 | **Interactive STEM Explorer** | Three switchable physics/electronics demos: Projectile Motion (with planet-gravity presets + trajectory animation), Simple Pendulum (period calculation + live swing animation), and RC Circuit Charging (time-constant + charging-curve plot). |
| 2 | **Data Visualization Dashboard** | Load any CSV, pick X/Y columns, choose Line / Scatter / Histogram / Bar-of-means, and see live statistics: mean, median, std-dev, min, max, correlation. |
| 3 | **Finance & Business Calculators** | Loan EMI calculator with amortization balance chart, and a Scheme A vs Scheme B monthly-investment growth comparator. |
| 4 | **Science & Engineering Simulator** | Spring-mass-damper system solved numerically (`ode()`), with live natural-frequency/damping-ratio readouts and a real-time animated response curve. |
| 5 | **Utility & Productivity Tools** | Unit converter (length / weight / temperature), a general `A x = b` matrix equation solver, and a stopwatch timer. |

Every module shares the same **dark background + neon cyan / pink / green / purple** visual
language, and every module has its own **Tippy (?) help buttons** that explain what to do next.

---

## 🗂️ Project structure (modular by design)

```
scilab_dashboard/
├── main_dashboard.sce            # Entry point — loads libraries, shows Home screen
├── utils/
│   ├── theme.sci                 # Neon dark theme colors + widget factory functions
│   └── common.sci                # Shared helpers (safe_evstr, clamp, fmt)
├── tippy/
│   └── tippy.sci                 # Tippy character: face, speech bubble, (?) buttons
├── modules/
│   ├── module_stem.sce           # 1. Interactive STEM Education
│   ├── module_dataviz.sce        # 2. Data Visualization Dashboard
│   ├── module_finance.sce        # 3. Finance & Business Calculators
│   ├── module_simulator.sce      # 4. Science & Engineering Simulator
│   └── module_utility.sce        # 5. Utility & Productivity Tools
├── sample_data/
│   └── sample.csv                # Sample dataset for the Data Viz module
├── screenshots/                  # Add your GUI screenshots here for submission
├── PROBLEM_STATEMENT.md
└── README.md
```

Each module is a **self-contained `.sce` file with its own functions**, `exec()`-loaded on demand
by `main_dashboard.sce` only when the user opens that module — keeping startup fast and the
codebase easy to navigate/extend.

---

## ▶️ How to run

1. Open **Scilab** (tested against Scilab 6.x).
2. Set the current directory to the `scilab_dashboard` folder, OR just open `main_dashboard.sce`
   in the Scilab editor (SciNotes) — it auto-detects its own folder using
   `get_absolute_file_path()`, so it works regardless of where you place the project.
3. Run the file (`Execute` ▶ or `exec('main_dashboard.sce')` in the console).
4. The **Home Screen** appears — click any of the 5 module buttons to launch it.
5. Click **"Back to Home"** inside any module to return, or **"Exit Dashboard"** to close everything.

> 💡 For the Data Visualization module, use **Load CSV File** and pick `sample_data/sample.csv`
> to see it working immediately.

---

## 🧠 How Tippy works

`tippy_init(fig)` draws a small face + speech-bubble label in the bottom-left corner of every
window. Any module can drop a help button anywhere with:

```scilab
tippy_help_button(fig, [x y w h], 'Some helpful tip text goes here.');
```

Each button stores its own tip text in the widget's `userdata` property (not a shared global), so
many `(?)` buttons can coexist on one screen without overwriting each other's message. Clicking a
button calls `tippy_on_help()`, which reads `gcbo().userdata` and makes Tippy "speak" via
`tippy_say()`. There's also `tippy_wave()` for a short idle animation.

---

## 🎨 Design choices

- **Modular architecture** — theme, Tippy, and each domain module are fully decoupled `.sci`/`.sce`
  files, loaded via `exec()`. Anyone can add a 6th module by writing one new file and one button.
- **Consistent neon-dark theme** — all widgets are built through `theme_button`, `theme_label`,
  `theme_edit`, `theme_new_figure` in `utils/theme.sci`, so the whole app looks and feels like one
  product instead of five unrelated demos.
- **Real interactivity, not static plots** — sliders, popup menus, list boxes, file dialogs, and
  frame-by-frame animation loops (`drawnow()` + `xpause()`) are used throughout instead of one-shot
  `plot()` calls, directly answering the "avoid basic plotting examples" guideline.
- **Numeric correctness** — physics uses the real closed-form projectile/pendulum equations and a
  numerically-integrated ODE (`ode()`) for the spring-mass-damper system; finance uses standard
  EMI/amortization and compound-growth formulas.

---

## ⚠️ Known limitations / notes for judges

- GUI positions are tuned for a `1020×700` (or similar) display; on very small screens some panels
  may need resizing.
- The Stopwatch tool uses a `tic()/xpause()/drawnow()` polling loop (a common Scilab pattern for
  GUI timers, since Scilab lacks a native repeating-timer callback) — click **Stop** to break out
  of the loop.
- Animations (`stem_projectile_animate`, `stem_pendulum_animate`, `sim_animate`) block interaction
  with *that* window until finished; other windows remain responsive.
- Built and reviewed for **Scilab 6.x** GUI API (`uicontrol`, `newaxes`, `ode`, `csvRead`,
  `correl`, `histplot`). If your Scilab version behaves slightly differently, check the console for
  the first error and adjust — the file/function it points to will be obvious from the modular
  structure above.

---

## 📋 Deliverables checklist (per hackathon requirements)

- [x] Source code (modular, this repository)
- [x] README / documentation (this file)
- [x] Problem statement (`PROBLEM_STATEMENT.md`)
- [ ] GUI screenshots — add to `screenshots/` before submission
- [ ] Short demo video (<2 min) — record a walkthrough of all 5 modules + Tippy
- [ ] Sample outputs — the `sample_data/sample.csv` results, EMI/investment charts, etc.
