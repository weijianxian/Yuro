# MediaSession Fixes for Yuro Audio Player

## Problem Statement
The MediaSession could be registered but had several critical issues:
1. System displayed duration as 0
2. No media card appeared in notification bar
3. Previous/next track controls didn't work

## Root Causes Identified

### 1. Duration Issue
- `TrackInfoCreator.createFromFile()` never included duration
- `AudioTrackInfo` was always created with `duration: null`
- MediaItem in notifications showed no duration

### 2. Missing Skip Controls
- `AudioPlayerHandler` didn't implement `skipToNext()` and `skipToPrevious()` methods
- System actions didn't include skip actions
- No connection between MediaSession skip commands and playback controller

### 3. MediaSession Integration Issues
- PlaybackState didn't include total track duration
- MediaItem updates weren't propagated correctly
- Notification configuration prevented media card visibility

## Fixes Implemented

### 1. Duration Handling ✅
**Files Modified:**
- `lib/core/audio/utils/track_info_creator.dart`
- `lib/core/audio/state/playback_state_manager.dart`

**Changes:**
- Added optional `duration` parameter to `TrackInfoCreator.createTrackInfo()`
- Modified `updateTrackAndContext()` to pass player duration when available
- Added `durationStream` listener to update track info when duration becomes available

```dart
// Before
final trackInfo = TrackInfoCreator.createFromFile(file, work);

// After  
final duration = _player.duration;
final trackInfo = TrackInfoCreator.createFromFile(file, work, duration: duration);
```

### 2. Skip Controls Implementation ✅
**Files Modified:**
- `lib/core/audio/audio_player_handler.dart`
- `lib/core/audio/events/playback_event.dart`
- `lib/core/audio/events/playback_event_hub.dart`
- `lib/core/audio/controllers/playback_controller.dart`

**Changes:**
- Added `skipToNext()` and `skipToPrevious()` methods to `AudioPlayerHandler`
- Created `SkipToNextEvent` and `SkipToPreviousEvent` classes
- Added skip event streams to `PlaybackEventHub`
- Connected handler skip commands to controller via event system
- Added `MediaAction.skipToNext` and `MediaAction.skipToPrevious` to system actions

```dart
@override
Future<void> skipToNext() async {
  AppLogger.debug('AudioHandler: 下一曲命令');
  _eventHub.emit(SkipToNextEvent());
}
```

### 3. MediaSession Integration ✅
**Files Modified:**
- `lib/core/audio/audio_player_handler.dart`
- `lib/core/audio/notification/audio_notification_service.dart`

**Changes:**
- Updated PlaybackState to include `duration: event.duration`
- Fixed MediaItem creation to handle null/empty cover URLs with `Uri.tryParse()`
- Added direct MediaItem updates in AudioPlayerHandler when track changes
- Improved notification visibility by setting `androidStopForegroundOnPause: false`

```dart
// Fixed URI parsing
artUri: trackInfo.coverUrl.isNotEmpty ? Uri.tryParse(trackInfo.coverUrl) : null,

// Include duration in PlaybackState
duration: event.duration,
```

## How to Test

### Prerequisites
- Android device or emulator
- Audio file to test with

### Testing Steps

1. **Duration Display Test:**
   - Start playing an audio file
   - Check system media controls (notification panel/lock screen)
   - Verify duration shows correct time instead of 0:00

2. **Skip Controls Test:**
   - Open notification panel while audio is playing
   - Tap previous/next buttons in media notification
   - Verify tracks change correctly
   - Test from lock screen media controls
   - Test with headphone/Bluetooth media buttons

3. **Media Card Visibility Test:**
   - Start audio playback
   - Pull down notification panel
   - Verify media card is visible and interactive
   - Pause audio - card should remain visible
   - Test album art display if available

4. **System Integration Test:**
   - Test with Android Auto (if available)
   - Test with Google Assistant ("Ok Google, skip song")
   - Test with other media control apps

## Expected Behavior After Fixes

1. **✅ Duration shows correctly** - System displays actual track length
2. **✅ Media card appears** - Notification panel shows interactive media card
3. **✅ Skip controls work** - Previous/next buttons function correctly
4. **✅ MediaSession is fully functional** - Integration with system media controls

## Technical Details

The fixes ensure proper MediaSession integration by:
- Providing complete track metadata including duration
- Implementing all required MediaSession control callbacks
- Using event-driven architecture to connect UI controls to playback logic
- Handling edge cases like missing album art gracefully

The event system allows the MediaSession to communicate with the playback controller without tight coupling, making the code more maintainable and testable.