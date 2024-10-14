library(dplyr)
library(jsonlite)

# Import the parameters, libraries, and functions from other scripts
ScriptDir = "Scripts/"
importableScriptDir = paste0(ScriptDir,"Imports/")

parameterScriptDir = paste0(importableScriptDir,"Parameters/")
source(file.path(paste0(parameterScriptDir,"Parameters.R")))

functionScriptDir = paste0(importableScriptDir,"Functions/")
source(file.path(paste0(functionScriptDir,"01-Tournament_Data_Import.R")))

# Load the tournament data
rawData <- fromJSON(TournamentResultFile)[[1]]

# Generate the dataframe using the existing function
tournamentDf <- generate_df(
  rawData, EventType, MtgFormat, TournamentResultFile, Beginning, End
)

# Filter for unknown archetypes
unknown_archetypes <- tournamentDf %>%
  filter(Archetype$Archetype == "Unknown")

# Calculate the percentage of each Archetype$Color among Unknown archetypes
color_distribution <- unknown_archetypes %>%
  group_by(Archetype$Color) %>%
  summarise(Count = n()) %>%
  mutate(Percentage = (Count / sum(Count)) * 100)

# Sort the color distribution by percentage in descending order
color_distribution <- color_distribution %>%
  arrange(desc(Percentage))

# Filter for colors with percentage above 10%
significant_colors <- color_distribution %>%
  filter(Percentage > 10)

# Find the most recent player for each significant color
most_recent_players <- unknown_archetypes %>%
  filter(Archetype$Color %in% significant_colors$`Archetype$Color`) %>%
  group_by(Archetype$Color) %>%
  summarise(MostRecentPlayer = Player[which.max(Date)])

# Print the most recent players for significant colors
print(most_recent_players)
print(color_distribution)
