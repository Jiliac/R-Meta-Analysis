# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an R-based Magic: The Gathering tournament meta-analysis tool that analyzes MTG tournament results across different formats (Standard, Pioneer, Modern, Legacy, Pauper, Vintage). The project processes tournament data from JSON files and generates comprehensive metagame analysis including win rates, presence statistics, tier lists, and matchup matrices.

## Key Architecture

### Core Structure
- **Scripts/Imports/Parameters/Parameters.R**: Main configuration file controlling analysis parameters
- **Scripts/Executables/_main.R**: Primary entry point that orchestrates the entire analysis pipeline
- **Scripts/Imports/Functions/**: Modular functions organized by purpose:
  - `01-Tournament_Data_Import.R`: Data import and parsing
  - `02-Simple_Getters.R`: Basic data retrieval functions
  - `03-Metagame_Data_Treatment.R`: Core metagame calculations
  - `04-Metagame_Graph_Generation.R`: Visualization generation
  - `05-Decklist_Analysis.R`: Deck analysis utilities
  - `06-Player_Data_Treatment.R`: Player statistics
  - `07-Card_Data_Treatment.R`: Card usage analysis
  - `99-Output_Export.R`: Results export functionality

### Data Flow
1. JSON tournament data is imported from `Data/Tournament/`
2. Data is filtered by format, date range, and event type
3. Archetype metrics are calculated (presence, win rate, confidence intervals)
4. Tier lists are generated based on normalized performance scores
5. Visualizations and reports are exported to `Results/`

### Output Structure
Results are organized by format and date range in `Results/`:
- **Picture files/**: Generated charts and graphs (JPG format)
- **Table files/**: CSV/XLSX exports of analysis data
- **Text files/**: Summary reports and deck lists

## Common Development Tasks

### Running Analysis
```r
# Open RStudio and run the main analysis
source("Scripts/Executables/_main.R")
```

### Key Configuration Parameters
Edit `Scripts/Imports/Parameters/Parameters.R` to modify:
- `MtgFormat`: Choose format (1-8, where 3=Pioneer, 4=Modern, etc.)
- `Beginning`/`End`: Set date range for analysis
- `EventType`: Filter by event type (22 = "All events")
- `ChartShare`: Minimum presence threshold for charts (default: 2%)
- `Presence`: Metric for presence calculation ("Matches", "Players", or "Copies")

### Data Sources
- Tournament data: JSON files in `Data/Tournament/` (downloaded via `download.sh`)
- Data source: Uses MTGOArchetypeParser by Phelps-san (https://github.com/Badaro/MTGOArchetypeParser)

### Python Components
- `Scripts/Executables/extract_archetype_player_stats.py`: Python script for extracting player statistics by archetype

### Project Configuration
- R project file: `R Meta Analysis.Rproj`
- Uses standard R project structure with RStudio integration
- Encoding: UTF-8, uses 2 spaces for indentation

## Important Notes

- The analysis pipeline is designed to be run entirely through `_main.R`
- All functions are sourced from the `Scripts/Imports/Functions/` directory
- Results are automatically organized by format, date range, and event type
- The tool generates 8 standard visualizations for each analysis run
- Time weighting can be enabled to give more importance to recent results