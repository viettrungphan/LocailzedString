PROJECT_DIR=$1

cd $PROJECT_DIR/scripts
touch tempLocalize.swift
cat LocalizableSouceCodeWriter.swift File.swift > tempLocalize.swift
/usr/bin/env xcrun --sdk macosx swift $PROJECT_DIR/scripts/tempLocalize.swift -o $PROJECT_DIR/LocalizedStringScript/Localizable.strings
rm -f tempLocalize.swift
