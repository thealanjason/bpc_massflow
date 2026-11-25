# Bayesian Inverse Parameter Calibration for Mass Flow Models

This computational study was developed using the
[SHOWME.how](https://mbd-rwth.github.io/showmehow/) approach.

In this computational study, we calibrate the parameters of a Mass Point Model
(MPM) for mass flows against observed data using Markov chain Monte Carlo (MCMC).
Since the MPM is expensive to evaluate, a Gaussian-process surrogate is trained on
a set of model runs and used in place of the model during calibration.

## Components of the study

### Computational units

- **`lhs`** draws Latin hypercube samples of the model parameters (Julia).
- **`forward_model`** runs the MPM for each sample on a synthetic topography
  (Python, [`psimpy`](https://psimpy.readthedocs.io/)).
- **`surrogate`** trains a Gaussian-process emulator of the MPM
  ([`RobustGaSP`](https://cran.r-project.org/package=RobustGaSP), R) and serves it
  over [UM-Bridge](https://um-bridge-benchmarks.readthedocs.io/).
- **`mcmc`** calibrates the parameters with the ensemble sampler
  [`emcee`](https://emcee.readthedocs.io/), querying the surrogate through UM-Bridge.

## Prerequisites

- **[Conda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html) / [Mamba](https://github.com/conda-forge/miniforge#install) / [Micromamba](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html#automatic-install)**: a package manager for the unit environments and for installing Nextflow.
- **A container runtime**:
  [Docker](https://docs.docker.com/get-docker/) locally, or
  [Apptainer](https://apptainer.org/docs/admin/latest/installation.html#installing-apptainer)
  on HPC.

> **Note for Windows users:** Nextflow runs on Windows [only through WSL2](https://docs.seqera.io/nextflow/install). Install the Linux version of your package manager inside [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install) (e.g. Ubuntu). See how to [use Docker with WSL 2](https://docs.docker.com/desktop/features/wsl/).

> **Note for macOS users:** with Docker Desktop, turn on host networking
> (Settings → Resources → Network → *Enable host networking*). The units talk to each
> other over `localhost`, and `--containerized` runs rely on it.

## Installation

Create and activate the project environment:
```
conda env create -f environment.yml
conda activate showmehow
```

## Usage

1. **Run the workflow:**
   ```
   nextflow run main.nf -params-file params.yml
   ```
   `params.yml` sets the parameter bounds and the number of samples.

2. **Execution profiles** select the container engine with `-profile`:
   - `-profile local` (**default** if omitted): Docker, for a local workstation.
   - `-profile cluster`: Apptainer, for a shared cluster node.

   ```
   nextflow run main.nf -params-file params.yml -profile cluster
   ```

3. **Reproducible environments.** Each unit declares its environment in `main.nf`;
   how it is resolved is set in `nextflow.config`. Each run picks one mode:

   | Mode | Flag | What a unit uses |
   | --- | --- | --- |
   | Locked (default) | — | committed `<unit>/lockfile/conda-<platform>.lock` |
   | Unlocked | `--useLockFiles false` | solve `<unit>/environment.yml` at runtime |
   | Containerized | `--containerized` | the unit's image from GHCR, no conda |

   ```
   nextflow run main.nf -params-file params.yml                 # locked
   nextflow run main.nf -params-file params.yml --containerized # images from GHCR
   ```
   - `--lockPlatform` is **auto-detected** from the host
     (`linux-64` | `linux-aarch64` | `osx-64` | `osx-arm64` | `win-64`); override if needed.
   - A unit with no lock (e.g. `mcmc`, which has pip dependencies) falls back to its
     `environment.yml`.
   - `--condaEngine` is `micromamba` (default), `conda`, or `mamba`.
   - `lhs` always runs from its image.

   The lock files and images are kept up to date by GitHub Actions
   (`.github/workflows/lock-and-build.yml`). When a unit's `environment.yml` (or
   `Project.toml`) changes on `main`, it re-locks, commits the result, and
   pushes each unit's image to GHCR (`:latest` and `:<sha>`).

## Repository structure

| Path | Contents |
| --- | --- |
| `main.nf` | The Nextflow workflow |
| `nextflow.config` | Environment resolution and execution profiles |
| `params.yml` | Parameter bounds and sample count |
| `lhs/`, `forward_model/`, `surrogate/`, `mcmc/` | The computational units |
| `.github/` | CI that locks the environments and builds the images |

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

See [LICENSE](LICENSE).
