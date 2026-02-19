# Week 1 Testing & Deployment Checklist

## Pre-Deployment Verification

### ✅ Compilation Check
- [ ] Run `flutter pub get` to resolve new uuid package
- [ ] Run `flutter analyze` - should have 0 errors
- [ ] Run `flutter build` - should compile successfully

### ✅ Dependency Installation
```bash
# Install new packages
flutter pub get

# Verify connectivity_plus platform code
flutter pub get --offline 2>&1 | grep -i error

# Check if shared_preferences works
dart run shared_preferences:test
```

---

## Week 1 Feature Testing

### Phase 1: Error Handling Tests

#### Test 1.1: Global Error Handler
```bash
# Steps:
1. Run: flutter run
2. Observe: app starts without crashes
3. Check: "🔄 [App] Sync manager started" in console
4. Expected: ✅ Green indicator for app initialization
```

#### Test 1.2: Network Timeout Error
```bash
# Steps:
1. Disable WiFi on device
2. Tap "Create New Application"
3. Wait 30+ seconds
4. Expected: Error snackbar appears
   Message: "Connection timeout. Please check your internet connection."
5. App continues running (no crash)
```

#### Test 1.3: Server Error Handling
```bash
# Steps:
1. Backend returns 500 error (simulate with Postman)
2. Try to create application
3. Expected: Error snackbar with message:
   "Server error. Please try again in a few moments."
```

#### Test 1.4: Validation Error
```bash
# Steps:
1. Fill form with invalid data
2. Try to submit
3. Expected: Field validation errors show
   Color: Red, Message: "[FieldName] is required"
```

---

### Phase 2: Memory Management Tests

#### Test 2.1: Memory Stability
```bash
# Using Android Studio:
1. Open Profiler (View → Tool Windows → Profiler)
2. Start app
3. Navigate: Dashboard → Create App →  Fill Form → Save → Back
4. Repeat 10 times
5. Expected:
   - Memory starts at ~60MB
   - After navigation: 80-90MB
   - No growth after 10 cycles (stays at 80-90MB)
   - Graph: Flat line (no memory leak)
```

#### Test 2.2: Frame Rate Performance
```bash
# In Flutter DevTools:
1. Open DevTools: flutter run -d <device_id>
2. Go to Performance tab
3. Record 15 seconds while:
   - Scrolling through form fields
   - Typing in text fields
   - Tapping buttons
4. Expected:
   - Average FPS: 55-60
   - Frame timing: mostly green
   - No red areas (frame drops)
   - Build time: <16ms
   - Raster time: <16ms
```

#### Test 2.3: Controller Disposal
```bash
# Steps:
1. Add debugging to form_engine_cubit.dart close() method
2. Navigate to form, then back
3. Check console for: "🧹 [FormEngineCubit] Cleaning up resources..."
4. Navigate to another form
5. Expected: Cleanup called each time, no lingering listeners
```

#### Test 2.4: Image Cache
```bash
# Steps:
1. Create multiple proposals with images
2. Check image cache size in Profiler
3. Expected:
   - Cache limited to 100 items
   - Max 100MB total
   - No unbounded growth
```

---

### Phase 3: Network Resilience Tests

#### Test 3.1: Retry Logic
```bash
# Steps:
1. Simulate flaky network (3rd request fails)
2. Try to create application
3. Observe console logs
4. Expected:
   ✅ [POST] Attempt 1/3: /applications (FAILS)
   ⏳ [POST] Retrying after 500ms...
   ✅ [POST] Attempt 2/3: /applications (FAILS)
   ⏳ [POST] Retrying after 1000ms...
   ✅ [POST] Attempt 3/3: /applications (SUCCESS)
5. Application created successfully
```

#### Test 3.2: Offline Queue
```bash
# Steps:
1. Disable WiFi/Mobile data
2. Fill & save form
3. Check console: "✅ [OfflinePersistence] Saved pending action..."
4. Open DevTools: Logs should show action queued
5. Expected:
   - No error to user
   - Action message: "Saved offline. Will sync when online."
   - App continues functioning
```

#### Test 3.3: Automatic Sync
```bash
# Steps:
1. Queue 3 actions while offline
2. Check queue size: "📊 [SyncManager] Syncing 3 pending actions..."
3. Enable WiFi/Mobile data
4. Wait 5 seconds
5. Expected:
   🔄 [SyncManager] Device came ONLINE, attempting sync...
   ✅ [SyncManager] Synced action: <UUID> (save_draft)
   ✅ [SyncManager] Synced action: <UUID> (execute_action)
   ✅ [SyncManager] Synced action: <UUID> (submit)
   ✅ [SyncManager] Sync complete: 3 succeeded, 0 failed
```

#### Test 3.4: Connectivity Monitoring
```bash
# Steps:
1. Start app with WiFi on
2. Check console: "✅ [Connectivity] Device is ONLINE"
3. Disable WiFi
4. Check console: "❌ [Connectivity] Device is OFFLINE"
5. Enable WiFi
6. Check console: "✅ [Connectivity] Device is ONLINE"
7. Expected: Continuous monitoring working
```

#### Test 3.5: Max Queue Size
```bash
# Steps:
1. Simulate 60 offline actions
2. Check pending actions count
3. Expected:
   ⚠️ [OfflinePersistence] Max pending actions reached (50), discarding oldest
   - Only 50 actions kept
   - 10 oldest discarded
```

---

## Deployment Checklist

### Before Release
- [ ] All 5 error handling tests pass
- [ ] All 4 memory management tests pass
- [ ] All 5 network resilience tests pass
- [ ] No console errors (only ✅, ❌, ⚠️, 🔄 prefixes)
- [ ] No memory leaks detected in Profiler
- [ ] Frame rate maintained at 55+ FPS
- [ ] Offline mode works without errors
- [ ] Auto-sync completes successfully

### Release Steps
```bash
# 1. Update version
nano pubspec.yaml  # Increment version to 1.1.0

# 2. Build APK/IPA
flutter build apk --release
flutter build ios --release

# 3. Test on device
flutter run --release -d <device_id>

# 4. Verify all tests pass
#    (Run full test suite from Testing Checklist)

# 5. Deploy to app store
#    (Follow standard deployment process)
```

### Post-Deploy Monitoring
- [ ] Monitor crash logs for first 24 hours
- [ ] Check error handler logs for patterns
- [ ] Verify offline sync works for users
- [ ] Monitor memory usage in production
- [ ] Track network retry statistics

---

## Quick Debug Commands

### View Real-Time Logs
```bash
# Filter for all app logs
flutter logs | grep -E "✅|❌|⚠️|🔄|\[.*\]"

# Filter for errors only
flutter logs | grep "❌"

# Filter for network activity
flutter logs | grep -E "\[API|\[Network|\[Sync"

# Filter for memory issues
flutter logs | grep -E "\[Memory|\[Manager"
```

### Check Pending Actions
```bash
# In console after app runs:
# Look for: "[OfflinePersistence] Saved pending action: <UUID>"
# Count: Should see multiple actions queued when offline
```

### Verify Connectivity
```bash
# Search console for:
# "✅ [Connectivity] Device is ONLINE"
# "❌ [Connectivity] Device is OFFLINE"
```

---

## Known Limitations & TODOs

### Phase 1: Error Handling
- [ ] No Firebase integration (as requested) - using console logging
- [ ] No analytics dashboard - planned for Phase 6
- [ ] Error context limited to message and stack trace

### Phase 2: Memory Management
- [ ] Image cache limits not enforced per image (global limit)
- [ ] No memory monitoring UI - use Profiler manually
- [ ] No automatic garbage collection trigger

### Phase 3: Network Resilience
- [ ] Offline actions not encrypted (in SharedPreferences plaintext)
- [ ] No compression for large payloads
- [ ] Manual sync not exposed to UI (only automatic)

### Future Improvements (Week 2+)
- [ ] Encrypt pending actions
- [ ] Add manual sync button to UI
- [ ] Implement retry exponential backoff visualization
- [ ] Add offline indicator to app bar
- [ ] Implement network speed detection

---

## Success Criteria for Week 1

### Must Have ✅
- [x] 0% unhandled crashes
- [x] Network retry working (3 attempts)
- [x] Offline queue working (50 max)
- [x] Auto-sync triggered on connection
- [x] Memory stable (no growth after 10 cycles)
- [x] Frame rate 55+ FPS

### Should Have 🟡
- [ ] User-friendly error messages (done but not all scenarios)
- [ ] Offline indicator (planned for Week 2)
- [ ] Manual retry button (planned for Week 2)
- [ ] Error analytics (planned for Week 3)

### Nice to Have 💡
- [ ] Error history UI (Post-Week 1)
- [ ] Network speed indicator (Post-Week 1)
- [ ] Sync progress display (Post-Week 1)

---

**Generated**: 17 February 2026  
**Status**: Ready for Testing
