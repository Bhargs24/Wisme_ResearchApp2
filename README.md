# Wisme Research App 2

**A research build used to test whether conversational, audio-first lessons hold attention better than reading.** Four subjects, a set of scripted audio episodes each, and instrumentation on top to record what people actually did with them.

Built August 2025, under the original "Wisme" spelling. Not maintained.

## Why it exists

The question was narrow and worth answering before building anything larger: if a lesson is delivered as a short conversation you listen to, do people finish it, and do they come back. So the app is deliberately thin on features and heavy on measurement.

## What is in it

- **Four learning journeys.** Data structures and algorithms, operating systems, databases, and personal finance.
- **Audio episodes** per journey, scripted and produced rather than generated at runtime, so the content is held constant across participants.
- **Feedback screens** that ask directly after an episode, rather than inferring satisfaction from taps.
- **Research instrumentation** recording progress, completion and drop-off per episode.
- **Admin metrics view** for reading the results back out.

## Layout

| Path | What |
|---|---|
| [`researchapp2/`](researchapp2/) | The Flutter app. Source under `lib/`, split by feature: `journeys`, `progress`, `feedback`, `research`, `gamification`, `admin`. |
| `researchapp2/demo_app_documentation/` | The study design: methodology, the metrics being captured, screen specs, and the episode scripts. |
| `Python csv script generator/` | The script that generated the personal-finance episode content. |

## Stack

Flutter and Dart, Firebase for auth and storage, ElevenLabs for the episode audio.

## Running it

```bash
cd researchapp2
flutter pub get
flutter run
```

It expects a Firebase project of your own. The committed config points at the original research project, whose security rules require authentication, so it will not do anything useful without your own backing project.

## Status

Archived research prototype from August 2025. The documentation in `demo_app_documentation/` is working material from the study rather than finished writing, and some of it still has placeholders where results were meant to go. Read it as notes, not as findings.

What this fed into is [Wivme](https://wivmeai.com), which kept audio-first delivery and added the thing this build did not have: a retention engine that tracks each concept's decay and schedules recall before it is lost.
