#!/usr/bin/env bash
# The Moomins (1977–1982)

SEASON_MAX=2
EP_MAX=50

for i in $(seq -f "%02g" 1 $SEASON_MAX); do
	for j in $(seq -f "%02g" 1 $EP_MAX); do
		youtube-dl https://www.fuzzyfeltmoomins.co.uk/s${i}e${j}.html
	done
done

