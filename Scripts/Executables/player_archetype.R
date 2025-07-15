ScriptDir = "Scripts/"
importableScriptDir = paste0(ScriptDir,"Imports/")

parameterScriptDir = paste0(importableScriptDir,"Parameters/")
source(file.path(paste0(parameterScriptDir,"Parameters.R")))

functionScriptDir = paste0(importableScriptDir,"Functions/")
source(file.path(paste0(functionScriptDir,"01-Tournament_Data_Import.R")))
source(file.path(paste0(functionScriptDir,"02-Simple_Getters.R")))
source(file.path(paste0(functionScriptDir,"03-Metagame_Data_Treatment.R")))
source(file.path(paste0(functionScriptDir,"04-Metagame_Graph_Generation.R")))
source(file.path(paste0(functionScriptDir,"05-Decklist_Analysis.R")))
source(file.path(paste0(functionScriptDir,"06-Player_Data_Treatment.R")))
source(file.path(paste0(functionScriptDir,"07-Card_Data_Treatment.R")))
source(file.path(paste0(functionScriptDir,"99-Output_Export.R")))

# Create all the directories where results will be written
PathToLastDirs = 
  createResultDirectories(ResultDir, MtgFormat, Beginning, End, EventType,
                          CsvResultDir, PictureResultDir, TextResultDir)

# # Import MTG JSON card data
# mtgJsonData = bind_rows(jsonlite::fromJSON(mtgJsonFile)$data, .id = "cardName")

#Import tournament raw data
RawData = jsonlite::fromJSON(TournamentResultFile)[[1]] 

tournamentDf = generate_df(
  RawData, EventType, MtgFormat, TournamentResultFile, Beginning, End)

# Add a weight to the results depending on the number of weeks 
# The most recent results become more important to determine the share and WR
if(timeWeight){
  tournamentDf = addTimeWeight(tournamentDf)
  MtgFormat = paste(MtgFormat,"weighted by elapsed weeks")
}

generate_archetype_list = function(df){
  archetype_list=data.frame(unique(df$Archetype$Archetype))
  names(archetype_list)[1] = c("Archetype")
  return(archetype_list)
}

################################################################
################################################################

df = tournamentDf
metric_df = generate_archetype_list(df)

# Add the data required to computes win rates
metric_df$Wins = sapply(X = metric_df$Archetype, 
                        FUN = function(archetype, df) {
                          sum(df[df$Archetype$Archetype == 
                                   archetype,]$Wins)
                        }, df)
metric_df$Defeats = sapply(X = metric_df$Archetype, 
                           FUN = function(archetype, df) {
                             sum(df[df$Archetype$Archetype == 
                                      archetype,]$Losses)
                           }, df)
metric_df$Draws = sapply(X = metric_df$Archetype, 
                         FUN = function(archetype, df) {
                           sum(df[df$Archetype$Archetype == 
                                    archetype,]$Draws)
                         }, df)

# Remove archetypes that appear in the JSON but don't have any recorded match
metric_df = metric_df[metric_df$Wins + metric_df$Defeats >0,]

# Add presence metrics
metric_df$Copies = sapply(X = metric_df$Archetype, 
                          FUN = function(archetype, df) {
                            nrow(df[df$Archetype$Archetype == archetype,])
                          }, df)
metric_df$Players = sapply(X = metric_df$Archetype, 
                           FUN = function(archetype, df) {
                             length(unique(df[df$Archetype$Archetype == 
                                                archetype,]$Player))
                           }, df)
metric_df$Matches = metric_df$Wins + metric_df$Draws + metric_df$Defeats

# Compute the presence based on the one expected as parameter
metric_df$Presence = unlist(100 * metric_df[Presence]/sum(metric_df[Presence]))

# Compute the win rate and confidence interval on it
metric_df$Measured.Win.Rate = metric_df$Wins * 100 / 
  (metric_df$Wins + metric_df$Defeats)

# Aggregate wins and losses by player and archetype
player_archetype_aggregates <- df %>%
  group_by(Player, Archetype$Archetype) %>%
  summarise(TotalWins = sum(Wins),
            TotalLosses = sum(Losses),
            TotalMatches = sum(Wins + Losses),
            .groups = 'drop')
# Compute win rates at this aggregated level
player_archetype_aggregates <- player_archetype_aggregates %>%
  filter(TotalMatches > 0) %>%
  mutate(WinRate = TotalWins / TotalMatches)