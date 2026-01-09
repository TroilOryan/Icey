@REM flutter build apk --release --split-per-abi
@echo off
powershell -File "build.ps1"
flutter build apk --release --obfuscate --split-debug-info=/debug/files --split-per-abi
