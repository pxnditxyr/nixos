#!/usr/bin/env bash
# Rofi Smart Search Script - Like Raycast

# Get search query from rofi
query=$(rofi -dmenu -p " " -theme-str 'window {width: 50%;}')

# Exit if no query was entered
if [ -z "$query" ]; then
    exit 0
fi

# Check if it's a URL (contains .com, .org, .net, etc or starts with http)
if [[ "$query" =~ ^https?:// ]] || [[ "$query" =~ \.[a-zA-Z]{2,}(/|$) ]]; then
    # It's a URL - add https:// if not present
    if [[ ! "$query" =~ ^https?:// ]]; then
        query="https://$query"
    fi
    xdg-open "$query"
else
    # It's a search query - URL encode and search
    encoded_query=$(echo "$query" | sed 's/ /+/g' | sed 's/&/%26/g')
    xdg-open "https://www.google.com/search?q=$encoded_query"
fi
