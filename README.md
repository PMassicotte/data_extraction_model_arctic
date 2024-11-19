[![DOI](https://zenodo.org/badge/891102138.svg)](https://doi.org/10.5281/zenodo.14187756) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

This project is designed to extract and process data from the Arctic Analysis Forecast BGC dataset. The pipeline includes data extraction, transformation, and loading (ETL) processes to prepare the data for analysis.

## Prerequisites

- R (version >= 4.0)

- `copernicusmarine` command-line tool installed and in the path

  - Installation instructions can be found [here](https://pypi.org/project/copernicusmarine/)

- Ensure you have the necessary environment variables set:
  - `COPERNICUS_USER`
  - `COPERNICUS_PWD`

## Installation

This repository contains tools and scripts to extract data from the Arctic Ocean Biogeochemistry Analysis and Forecast provided by the Copernicus Marine Service.

To set up the project environment, run the following commands:

```bash
# Clone the repository
git clone git@github.com:PMassicotte/data_extraction_model_arctic.git

# Navigate to the project directory
cd data_extraction_model_arctic

# Install dependencies using renv
R -e 'renv::restore()'
```

## Usage

You can run the analysis by running the following command:

```bash
R -e 'targets::tar_make()'
```

This will generate the necessary plots and analysis outputs.

## Acknowledgements

- [Copernicus Marine Environment Monitoring Service](https://marine.copernicus.eu/) for providing the data.
