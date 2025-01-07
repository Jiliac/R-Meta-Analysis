library(jsonlite)

# Configuration
INPUT_FILE <- "Data/Tournament/Modern_data.json"
OUTPUT_FILE <- "Data/zoo.csv"
TARGET_ARCHETYPE <- "Domain Zoo"  # Change this to the archetype you want to analyze

# Read the JSON data
raw_data <- (fromJSON(INPUT_FILE))[[1]]

# Initialize empty dataframe for results
player_results <- data.frame(
  player_name = character(),
  wins = numeric(),
  losses = numeric(),
  stringsAsFactors = FALSE
)

# Process each tournament entry
for (i in seq_along(raw_data)) {                                                                                                                                         
  entry <- raw_data[i, , drop=FALSE]
  # Check if this entry matches our target archetype and date
  if (!is.null(entry$Archetype) && 
      !is.null(entry$Archetype$Archetype) && 
      entry$Archetype$Archetype == TARGET_ARCHETYPE && 
      !is.null(entry$Matchups) &&
      as.Date(entry$Date) >= as.Date("2024-12-16")) {
    
    # Calculate match wins/losses for this tournament
    match_wins <- sum(sapply(entry$Matchups, function(m) m$Wins == 2))
    match_losses <- sum(sapply(entry$Matchups, function(m) m$Losses == 2))
    
    # Update or add player stats
    player_idx <- match(entry$Player, player_results$player_name)
    if (is.na(player_idx)) {
      # New player
      player_results <- rbind(player_results, 
                            data.frame(player_name = entry$Player,
                                     wins = match_wins,
                                     losses = match_losses))
    } else {
      # Existing player - update stats
      player_results$wins[player_idx] <- player_results$wins[player_idx] + match_wins
      player_results$losses[player_idx] <- player_results$losses[player_idx] + match_losses
    }
  }
}

# Sort by wins descending
player_results <- player_results[order(-player_results$wins), ]

# Write to CSV
write.csv(player_results, file = OUTPUT_FILE, row.names = FALSE)

cat(sprintf("Stats for %s have been written to %s\n", TARGET_ARCHETYPE, OUTPUT_FILE))
