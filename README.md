KidzShorts Child Profile UI update

1. Replace your project's lib/main.dart with this main.dart.
2. Copy assets/images/child_girl.png into your project's assets/images/ folder.
3. Add this under flutter: in pubspec.yaml (keep your existing assets too):

  assets:
    - assets/images/child_girl.png

4. Run:
   flutter pub get
   flutter clean
   flutter run

Only ChildProfileScreen was replaced in main.dart. Existing photo picker, camera/gallery flow,
DOB picker, 0–12 age validation, and Navigator.pop result map are preserved.
