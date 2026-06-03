# SlivkaEMBOSS

A Docker-based extension of the [slivka-bio-docker](https://github.com/bartongroup/slivka-bio-docker) REST API by the Barton Group, bundling over **200 EMBOSS tools** (and **ANARCI**) with full Slivka YAML service configurations.

## Overview

[Slivka](https://github.com/bartongroup/slivka) is a REST API framework for exposing bioinformatics tools as web services. This project extends the official `slivka-bio` setup with:

- **200+ EMBOSS tools** and **ANARCI** installed inside the Slivka server container
- Slivka YAML service configuration files for each tool (tracked with Git LFS)
- A custom `environment.yml` for the conda environment (`compbio-services`)
- Test sequences in `testdata/` and HTTP request examples in `test.http`

> **Note:** The `settings.yml` and `supervisord.conf` files are taken unmodified from the upstream [slivka-bio-docker](https://github.com/bartongroup/slivka-bio-docker) repository.

The original `slivka-bio` Docker image could not be used directly, as installing additional packages into the existing conda environment was not possible. This project rebuilds the image from a Miniconda base and creates the environment from scratch.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/)
- [Git LFS](https://git-lfs.github.com/) (required to pull the YAML service configuration files)
- (Optional) [VSCode](https://code.visualstudio.com/) with the [REST Client](https://marketplace.visualstudio.com/items?itemName=humao.rest-client) extension, to run requests from `test.http`

## Getting Started

### 1. Clone the repository

Make sure Git LFS is installed before cloning so the service YAML files are downloaded correctly:

```bash
git lfs install
git clone git@github.com:jvanp148/SlivkaEMBOSS.git
cd SlivkaEMBOSS
```

### 2. Build and start the services

```bash
docker compose -f compose.yml up -d --build
```

This will:

- Build the `slivka-emboss:1.0` image from the `Dockerfile`
- Start the Slivka server on port `8000`
- Start a MongoDB instance on port `27017`

On the first run, the image build may take several minutes as conda installs the environment and EMBOSS packages.

NOTE:
If you would like to use the Slivka EMBOSS server together with the [Prefect Server](https://github.com/jvanp148/Prefect_MinIO_Slivka) or [Streamlit applications](https://github.com/jvanp148/Streamlit_Prefect_Slivka) running in docker containers, you will have to add an external network to the docker compose file (now placed in comments). Creating such a network can be done with this command: `docker network create name-custom-network`.

### 3. Access the API

Once running, the API ReDoc is available at:

```text
http://localhost:8000/api
```

## Project Structure

```text
.
├── Dockerfile              # Container definition (Miniconda base + slivka-bio + EMBOSS)
├── compose.yml             # Docker Compose configuration
├── environment.yml         # Conda environment specification (compbio-services)
├── settings.yml            # Slivka settings (upstream, unmodified)
├── supervisord.conf        # Supervisord config (upstream, unmodified)
├── services/               # Slivka YAML service configs for all EMBOSS tools (Git LFS)
├── testdata/               # Example sequences for testing
└── test.http               # HTTP request examples (for VSCode REST Client)
```

## Testing

### Using `testdata/`

The `testdata/` directory contains sample sequences you can use as inputs when submitting jobs to the API. This folder is also mounted as a volume inside the Slivka server container, making it possible to use this data as inputs for tools, when being inside the container.

### Using `test.http`

The `test.http` file contains ready-to-run HTTP requests for the Slivka API.

To use it:

1. Open the file in [VSCode](https://code.visualstudio.com/)
2. Install the [REST Client](https://marketplace.visualstudio.com/items?itemName=humao.rest-client) extension
3. Click **Send Request** above any request block to execute it

## Architecture

| Component | Description |
|-----------|-------------|
| `slivka-emboss` | Main container: Slivka server + EMBOSS tools via conda |
| `mongo` | MongoDB 8.2.9, used by Slivka for job state persistence |
| `services/` volume | Mounted from the host; contains all YAML tool definitions |
| `media` volume | Stores job input/output files |

The `services/` directory is mounted as a volume so tool configurations can be updated without rebuilding the image. `testdata/` is also mounted as a volume so that the data in this folder is accessible inside the container to test out tools.

## Configuration

### Environment (`environment.yml`)

Defines the `compbio-services` conda environment, installing `slivka-bio` from the `bartongroup` channel.

### Dockerfile

Builds from `continuumio/miniconda3` and:

1. Installs `supervisord` and Java (required by some tools)
2. Creates the `compbio-services` conda environment
3. Installs `emboss`, `anarci` and `fasta3` into the environment
4. Copies `settings.yml` and `supervisord.conf` into place
5. Exposes port `8000`

### Docker Compose (`compose.yml`)

Defines two services (`slivka-emboss` and `mongo`) and two named volumes (`media` and `mongo_data`). MongoDB is available inside the compose network at `mongodb://mongo:27017/slivka`.

### Services (`services/`)

The service configuration YAML files can be found inside the `services/` folder. To create these YAMLs, a CLI parser application has been developed to convert SOAPLab XML files to Slivka YAMLs, via a canonical model. This parser application can be found on the [cli2slivka](https://github.com/jvanp148/cli2slivka) GitHub repository.

## Credits

- [Barton Group](https://github.com/bartongroup) - original [slivka-bio-docker](https://github.com/bartongroup/slivka-bio-docker) and Slivka framework
- [EMBOSS](https://emboss.sourceforge.net/) - European Molecular Biology Open Software Suite
- [ANARCI](https://github.com/oxpig/ANARCI) - Antigen receptor Numbering And Receptor ClassificatIon
