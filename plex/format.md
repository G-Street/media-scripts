# Formatting your Plex Database

## High Level Media Types
At a high level, you have the media directories you require:
```
Media
├── Audiobooks
├── Films
└── Series
```

## High Level Media Format

Within each category, you have the respective films and series (depicted below).  Films directories are written as `<film name> (<year>)`, and series directories are written as `<series name>`, and optionally with a year (if it is ambiguous).  Within each series, there should be subdirectories for seasons, with the format `Season <season number>`.  Generally the `<season number>` is left-padded with zeros, to 2 digits.  If your series has more than 99 seasons, this should be increased appropriated.
```
Media
├── Films
│  ├── Turning Red (2022)
│  └── Young Frankenstein (1974)
└── Series
   ├── American Gods
   │  └── Season 01
   └── Avatar - The Last Airbender
      ├── Season 01
      ├── Season 02
      └── Season 03
```

## Individual Media Format

### Films

#### Naming Convention
The naming convention of the film files are very similar to the naming convention of their containing directory, except with an extension: `<film name> (<year>).<file extension>`.
```
Media
└── Films
   ├── Amélie (2001)
   │  └── Amélie (2001).mkv
   └── Young Frankenstein (1974)
      └── Young Frankenstein (1974).mp4
```

#### Categories of Films
Plex will always look at lower level directories, and it pretty intelligent.  As such, you can categorise films if you prefer:
```
Movies
└── Mel Brooks
   ├── Blazing Saddles (1974)
   └── Young Frankenstein (1974)
```

If you want Plex to categorise these into a collection, *before you upload them to Plex*, you can run [`recategoriseMetadata`](../bash/recategoriseMetadata).

### Series

#### Naming Convention
Each episode should have the format `<series title> - S<season number>E<episode number>.<file extension>`, or optionally including episode titles: `<series title> - S<season number>E<episode number> - <episode title>.<file extension>`.  Generally, `<season number>` and `<episode number>` are left-passed with zeros, to 2 digits.  If your series contains more than 99 seasons, or the season contains more than 99 episodes, this should be modified accordingly.
```
Series
└── American Gods
   └── Season 01
      ├── American Gods - S01E01 - The Bone Orchard.mkv
      ├── American Gods - S01E02 - The Secret of Spoons.mkv
      ├── American Gods - S01E03 - Head Full of Snow.mkv
      ├── American Gods - S01E04 - Git Gone.mkv
      ├── American Gods - S01E05 - Lemon Scented You.mkv
      ├── American Gods - S01E06 - A Murder of Gods.mkv
      ├── American Gods - S01E07 - A Prayer for Mad Sweeney.mkv
      └── American Gods - S01E08 - Come to Jesus.mkv
```

### Subtitles
Subtitle files should be named as `<file base name>.<country code>.<subtitle extension>`.  You can use ISO-639-1 or ISO-639-2 for country codes.  You can also specify whether the subtitles are `forced` (i.e., only contain subtitled dialogue for "foreign" bits), or if they are "subtitles for the deaf and hard of hearing" (`sdh`) or Closed Caption (`cc`).  At time of writing, Plex supports subtitle types `srt`, `smi`, `ssa`, `ass`, and `vtt`.
```
Movies
└── Young Frankenstein (1974)
   ├── Young Frankenstein (1974).mp4
   ├── Young Frankenstein (1974).en.srt
   ├── Young Frankenstein (1974).en.forced.ass
   ├── Young Frankenstein (1974).en.sdh.srt
   ├── Young Frankenstein (1974).de.srt
   └── Young Frankenstein (1974).de.sdh.forced.srt
```

For more information, see Plex's post on subtitles [here](https://support.plex.tv/articles/200471133-adding-local-subtitles-to-your-media/).

