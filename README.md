# 🔬 FDTD Simulation of TDTE Ultrasound Imaging

**Time Domain Topological Energy (TDTE)** applied to Non-Destructive Testing (NDT) of composite materials — MATLAB simulation based on [Dominguez & Gibiat, *Ultrasonics* 50 (2010) 367–372](https://doi.org/10.1016/j.ultras.2009.08.014).

> Implemented by **Shahariar Ryehan** and **Marti** as part of a study on advanced ultrasonic imaging methods.

---

## 🧠 What is TDTE?

Finding defects inside carbon-fibre composites or biological tissue is hard — echoes scatter, overlap, and blur in complex materials. Classic methods like SAFT (Synthetic Aperture Focalization Technique) struggle with noise and anisotropy.

**TDTE solves this by combining two computed fields:**

| Field | Role |
|---|---|
| **Forward field** `u₀` | Ultrasonic response of a defect-free reference medium |
| **Adjoint field** `v₀` | Numerical time-reversal of the residue `(u_measured − u₀)` |

The **topological energy** is:

$$g_0(\mathbf{x}) = \int_0^T \|u_0(\mathbf{x},t)\|^2 \|v_0(\mathbf{x},t)\|^2 \, dt$$

Where energy concentrates → defect location. No iterations. No physical time-reversal hardware needed. **One shot.**

---

## 📐 Simulation Overview

This repo contains an FDTD (Finite Difference Time Domain) simulation of wave propagation through a 2D medium containing **16 side-drilled holes**, replicating the experimental setup from the paper.

**Domain:** 90 × 25 mm  
**Grid spacing (dh):** 0.2 mm  
**Speed of sound:** 3.0 mm/μs  
**Source:** Linear array at the bottom, 1 MHz Gaussian-modulated pulse  
**Defects:** 16 holes at varying depths (4.5–15 mm) and diameters (0.6–1.2 mm)

Hole positions follow Table 2 of Dominguez & Gibiat (2010):

| Hole # | Diameter (mm) | Depth (mm) |
|--------|--------------|------------|
| 1 | 0.7 | 15.0 |
| 2 | 0.7 | 13.0 |
| 3 | 0.7 | 10.5 |
| ... | ... | ... |
| 16 | 1.2 | 5.0 |

---

## 🚀 How to Run

**Requirements:** MATLAB R2020a or later (no additional toolboxes needed).

```matlab
% Clone and run
run('wave_holes_simulation.m')
```

The script will:
1. Set up the 2D FDTD grid
2. Emit a pulse from the source array
3. Simulate hard-boundary reflections at each hole
4. Save a video `wave_holes_simulation.mp4`
5. Display a summary figure with hole locations and final pressure field

---

## 📊 Why TDTE beats SAFT

| | SAFT | TDTE |
|---|---|---|
| Approach | Time-align & sum echoes | Forward × adjoint field correlation |
| Noise robustness | Moderate | **High** |
| SNR in composites | Lower | **Higher** |
| Close defect separation | Blurry | **Sharp** |
| Computation | Near-instant | Minutes (improvable) |
| Handles anisotropy | ❌ (standard SAFT) | ✅ |

---

## 📁 Repository Structure

```
├── wave_holes_simulation.m   # Main FDTD simulation script
├── README.md
└── results/
    ├── wave_holes_simulation.mp4   # Output animation
    └── summary_figure.png          # Hole locations + final pressure field
```

---

## 📚 Reference

> N. Dominguez, V. Gibiat, *Non-destructive imaging using the time domain topological energy method*, **Ultrasonics** 50 (2010) 367–372. https://doi.org/10.1016/j.ultras.2009.08.014

---

## 📄 License

MIT License — free to use, modify, and share with attribution.
