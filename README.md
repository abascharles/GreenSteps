# GreenSteps Flutter App

## Running the App

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed
- Device/emulator/simulator or browser for your target platform

### Android

```
flutter run -d android
```

### iOS (on macOS)

```
flutter run -d ios
```

### Web

```
flutter run -d chrome
```

### All Devices (list available devices)

```
flutter devices
flutter run -d <device_id>
```

## Notes

- Make sure to set up your Supabase credentials in `main.dart` before running the app.
- For web, you may need to enable web support: `flutter config --enable-web`

## Supabase RLS Policies for actions Table

Enable RLS for the actions table, then run these SQL policies in the Supabase SQL editor:

```sql
-- Allow users to insert their own actions
CREATE POLICY "Allow insert for authenticated users"
ON public.actions
FOR INSERT
USING (auth.uid() = user_id);

-- Allow users to select their own actions
CREATE POLICY "Allow select for authenticated users"
ON public.actions
FOR SELECT
USING (auth.uid() = user_id);
```
