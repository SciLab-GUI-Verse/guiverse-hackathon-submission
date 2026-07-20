# Problem Statement

## Title
**Scilab Interactive Dashboard — A Unified Multi-Domain GUI Learning & Productivity Platform**

## Background
Existing introductory Scilab GUI examples (as covered in the Spoken Tutorials) typically
demonstrate isolated, single-purpose ideas: a basic calculator, a simple plot, or one static
widget layout. In practice, learners and everyday users rarely need just *one* isolated tool — a
student exploring physics also wants to visualize data, a small-business owner needs both
financial calculators and quick utilities, and an engineering hobbyist wants to simulate systems
without switching between five different unrelated scripts.

There is no lightweight, **unified, visually engaging Scilab application** that brings STEM
education, data visualization, financial calculation, engineering simulation, and everyday
utilities together under a single, consistent, beginner-friendly interface.

## Problem
> Build a single Scilab GUI application that goes beyond isolated tutorial-style examples by
> combining **Interactive STEM Education, Data Visualization, Finance & Business Calculators,
> Science & Engineering Simulation, and Utility/Productivity tools** into one cohesive,
> multi-page, highly interactive dashboard — with an original visual identity and a guided user
> experience.

## Objectives
1. **Unify, don't isolate** — one entry point (Home screen) from which every domain module is
   reachable, all sharing a consistent visual language rather than five disconnected scripts.
2. **Maximize interactivity** — sliders, dropdowns, list boxes, file loaders, and real-time
   animated plots in every module, not static one-shot graphs.
3. **Stay scientifically/mathematically correct** — real physics equations (projectile motion,
   pendulum period, RC charging), a numerically-solved ODE (spring-mass-damper), correct EMI /
   compound-growth finance formulas, and general linear-algebra solving (`A x = b`).
4. **Be approachable** — a friendly recurring guide character (**Tippy**) offers contextual tips
   on every screen so first-time users are never lost.
5. **Be original and extensible** — a clean modular file structure (theme layer, helper layer,
   Tippy layer, and independent per-domain modules) so the project clearly extends beyond
   copy-pasted tutorial calculators/plots, and so new modules can be added by any teammate without
   touching existing code.

## Target Users
- Students learning physics, electronics, or engineering concepts visually.
- Anyone with a CSV dataset who wants a quick, no-code way to explore and summarize it.
- Individuals comparing loan repayment plans or long-term investment strategies.
- Engineering hobbyists/students wanting to see how mass/stiffness/damping affect a real system.
- Anyone who just needs a quick unit conversion, equation solve, or stopwatch — without opening
  five separate apps.

## Why Scilab GUI
Scilab's built-in `uicontrol`/figure GUI toolkit, together with its native numerical routines
(`ode`, `csvRead`, `correl`, matrix operators, `plot2d`/`histplot`/`bar`), makes it possible to
build genuinely interactive, scientifically grounded tools without any external GUI framework —
directly showcasing Scilab's own capabilities as both a numerical engine and a GUI platform,
which is the spirit of this hackathon track.

## Scope
**In scope:** the 5 modules described above, a shared neon-dark theme layer, the Tippy guide
character, sample CSV data for demoing the Data Visualization module, and full source +
documentation.

**Out of scope (possible future work):** multi-user data persistence, exporting reports to
PDF/Excel, 3D simulations, and networked/real-time sensor data feeds.

## Innovation Highlights
- A **single dashboard** replacing five separate hackathon-track apps, connected by shared theme
  and navigation, rather than five standalone submissions.
- **Tippy**, a lightweight, reusable "helper character" pattern (widget `userdata` + one callback)
  that any module can plug into with one line of code — turning a otherwise plain educational tool
  into a guided experience.
- Frame-by-frame **physics/engineering animations** (trajectory, pendulum swing, oscillation
  response) built with `drawnow()`/`xpause()` loops, going beyond the static plots typically shown
  in introductory tutorials.
- A fully **modular codebase** (`utils/`, `tippy/`, `modules/`) that mirrors good software
  engineering practice rather than one long monolithic script.
