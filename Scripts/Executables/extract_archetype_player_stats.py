import json
from collections import defaultdict
from typing import Dict, List, Tuple
import csv
from pathlib import Path

# Configuration
INPUT_FILE = "Data/Tournament/Modern_data.json"
OUTPUT_FILE = "Data/zoo.csv"
TARGET_ARCHETYPE = "Domain Zoo"  # Change this to the archetype you want to analyze

def calculate_match_results(matchups: List[Dict]) -> Tuple[int, int]:
    """Calculate total match wins and losses from matchups data"""
    match_wins = sum(1 for m in matchups if m.get('Wins') == 2)
    match_losses = sum(1 for m in matchups if m.get('Losses') == 2)
    return match_wins, match_losses

def main():
    # Read the JSON data
    with open(INPUT_FILE, 'r') as f:
        raw_data = json.load(f)['Data']

    # Initialize results dictionary with defaultdict
    player_stats = defaultdict(lambda: {'wins': 0, 'losses': 0})

    # Process each tournament entry
    for entry in raw_data:
        # Check if entry matches target archetype and date
        archetype = entry.get('Archetype', {}).get('Archetype')
        date = entry.get('Date', '').split('T')[0]  # Extract date part from ISO format
        if (archetype == TARGET_ARCHETYPE and 
            entry.get('Matchups') and 
            date >= '2024-12-16'):
            player = entry['Player']
            wins, losses = calculate_match_results(entry['Matchups'])
            
            # Update player stats
            player_stats[player]['wins'] += wins
            player_stats[player]['losses'] += losses

    # Convert to list of dictionaries for sorting and output
    results = [
        {'player_name': player, 'wins': stats['wins'], 'losses': stats['losses']}
        for player, stats in player_stats.items()
    ]
    
    # Sort by wins (descending), then losses (ascending)
    results.sort(key=lambda x: (-x['wins'], x['losses']))

    # Write to CSV
    if results:  # Only write if we have results
        with open(OUTPUT_FILE, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=['player_name', 'wins', 'losses'])
            writer.writeheader()
            writer.writerows(results)
        
        print(f"Stats for {TARGET_ARCHETYPE} have been written to {OUTPUT_FILE}")
    else:
        print(f"No results found for {TARGET_ARCHETYPE}")

if __name__ == "__main__":
    main()
