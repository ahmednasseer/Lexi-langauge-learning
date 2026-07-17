# Audio Specifications

> Drop files into `assets/audio/`. Load via `AudioPlayer` from `AssetSource('assets/audio/<file>')`.

| File | Duration | Format | Sample rate | Usage | Loudness |
|------|----------|--------|------------|-------|----------|
| sfx_correct.mp3 | 0.4s | MP3 | 44.1kHz | Quiz correct | -14 LUFS |
| sfx_wrong.mp3 | 0.4s | MP3 | 44.1kHz | Quiz wrong | -14 LUFS |
| sfx_levelup.mp3 | 0.8s | MP3 | 44.1kHz | Level up | -12 LUFS |
| sfx_gem.mp3 | 0.3s | MP3 | 44.1kHz | Gem earned | -14 LUFS |
| listening_a1_1.mp3 | varies | MP3 | 44.1kHz | Listening exercise (A1) | -16 LUFS |

Note: `goethe_exam_service.dart:169` currently stores a mock path `audio/listening/{level}_$i.mp3` in `ExamQuestion.audioUrl`. When real audio is added, map `audioUrl` to `assets/audio/...` and load via `AudioPlayer`.
