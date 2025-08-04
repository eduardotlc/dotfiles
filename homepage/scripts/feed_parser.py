#!/usr/bin/env python3
"""
Created on 2025-08-01 17:41:39.

@author: eduardotc
@email: eduardotcampos@hotmail.com

Get defined rss feeds entries and save to a local json file.
"""

import json
import random

import feedparser


def get_random_entries_from_feeds(feed_urls: list, num_entries: int) -> dict:
    """
    Parse given RSS feed URLs and return a specific number of random entries.

    Parameters
    ----------
    feed_urls :list
        List of RSS feed URLs to parse.
    num_entries : int
        Number of random entries to return.

    Returns
    -------
    dict
        A dictionary with random entries from the parsed feeds.
    """
    all_entries = []

    for url in feed_urls:
        feed = feedparser.parse(url)
        entries = feed.entries

        try:
            title = feed.feed.title.split(" ")[0].replace(":", "")
        except AttributeError:
            title = "feed"

        for entry in entries:
            if "media_content" not in entry:
                entry["media_content"] = [{"url": f"https://localhost:8001/img/{title}.svg"}]

        all_entries.extend(entries)

    random_entries = random.sample(all_entries, num_entries)

    return random_entries


def update_local_json(json_file: str, data: dict) -> None:
    """
    Update a local JSON file with the given data.

    Parameters
    ----------
    json_file : str
        Path to the local JSON file to update.
    data : dict
        Dictionary with data to update the JSON file with.
    """
    with open(json_file, "w", encoding="utf8") as f:
        json.dump(data, f, indent=4)


def main():
    """Obtain feed main function."""
    feed_urls = [
        "https://g1.globo.com/rss/g1/",
        "https://pubs.acs.org/action/showFeed?type=axatoc&feed=rss&jc=ancac3",
        "https://www.reddit.com/.rss?feed=bd5670afefd521bf5a63683fbab7206e65d631de&user=xpeinmx",
        "https://mshibanami.github.io/GitHubTrendingRSS/daily/all.xml",
        "https://news.ycombinator.com/rss",
    ]

    random_entries = get_random_entries_from_feeds(feed_urls, 6)
    update_local_json(
        "/home/eduardotc/Programming/html_css/homepage/scripts/feed.json",
        random_entries,
    )


if __name__ == "__main__":
    main()
