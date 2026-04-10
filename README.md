# CoCoNet Counterfactual Model — Docker

Containerised headless runner for the CoCoNet V3.0 coral reef model, built on NetLogo 6.4.0.

## Prerequisites

- Docker & Docker Compose
- The [CoCoNet model repository](https://github.com/gbrrestoration/CoCoNet-model) checked out at the desired version inside `CoCoNet-model/`

## Model Version

The Docker image copies the contents of `CoCoNet-model/` into the container at build time. This means the model code, reef data, and coastline data are baked into the image. You must have the correct version of the CoCoNet model repository in place **before** building.

To use a specific version:

```bash
# Clone or update the model repo at the desired tag/branch
git clone https://github.com/gbrrestoration/CoCoNet-model.git CoCoNet-model
cd CoCoNet-model
git checkout <tag-or-branch>
cd ..

# Then build the image
docker compose build
```

If the model code or data files change, you must rebuild the image for the changes to take effect.

## Quick Start

```bash
# Build and run with default parameters
docker compose up --build
```

The model output CSV will be written to `./outputs/output.csv`.

## Configuration

All model parameters have baseline defaults sourced from `parameters_baseline.csv`. You only need to specify environment variables in `docker-compose.yaml` for values that differ from the baseline. Any parameter not explicitly set will use the baseline value.

At container startup, `generate_experiment.sh` merges the environment variable overrides with the baseline defaults and generates the parameter CSV and BehaviorSpace experiment XML that NetLogo expects. There is no need to manually edit XML or CSV files.

### Baseline Defaults

The baseline defaults are defined in `generate_experiment.sh` and match the values in `CoCoNet-model/parameters_baseline.csv`. Key baseline values include:

| Variable | Baseline | Description |
|---|---|---|
| `SSP` | `2.6` | Shared Socioeconomic Pathway climate scenario |
| `ENSEMBLE_RUNS` | `30` | Number of ensemble runs |
| `START_YEAR` | `1956` | First year of each run |
| `END_YEAR` | `2075` | Last year of each run |
| `SAVE_YEAR` | `2001` | First year saved to output |
| `PROJECTION_YEAR` | `2024` | First year of future projection |
| `START_COTS_CONTROL` | `9999` | First year of CoTS control (9999 = disabled) |

See `.env.template` for the complete list of available parameters covering CoTS control, zoning, fishing, coral seeding, shading, and other interventions.

### Changing Parameters

Only add the parameters you want to override in `docker-compose.yaml`:

```yaml
environment:
  SSP: 4.5
  END_YEAR: 2150
  START_COTS_CONTROL: 2019
```

All other parameters will use their baseline defaults. Then rebuild and run:

```bash
docker compose up --build
```

## Output

Model output is written to `outputs/output.csv` inside the container, which is mounted to `./outputs/` on the host.

## Project Structure

```
├── docker-compose.yaml        # Service definition and model parameters
├── Dockerfile                 # Container image build
├── entrypoint.sh              # Container entrypoint — generates config and launches NetLogo
├── generate_experiment.sh     # Converts env vars to parameter CSV + experiment XML
├── .env.template              # Reference template for all environment variables
├── CoCoNet-model/             # Model code and data files
│   ├── CoCoNet V3.0.nlogo     # NetLogo model
│   ├── reefs2024.csv          # Reef network data
│   ├── coastline.csv          # Coastline data
│   └── parameters/            # Parameter CSVs and experiment XMLs
└── outputs/                   # Model output (host-mounted volume)
```

## Documentation

- `CoCoNet-model/Docs/CoCoNet-user-guide-and-technical-summary-v3.4-1.pdf` — User Guide & Technical Summary
- [Original model repository](https://github.com/gbrrestoration/CoCoNet-model)

