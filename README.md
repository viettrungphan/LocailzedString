# LocalizableStrings
Support multiple *.strings files in XCode project.

<img width="363" alt="Screenshot 2022-08-20 at 21 26 24" src="https://user-images.githubusercontent.com/35858359/185751242-d48e7b84-d8bd-4302-96bb-f6043331bf5f.png">


Using swift script to merge sub  *.strings file into Localizable.strings.

## How to use:
Create your XCode project
Copy scripts folder to your main project folder or modify script to point to script folder.
Create main Localizable.strings file.
Edit scheme Preaction and add sh command:
<img width="937" alt="Screenshot 2022-08-20 at 21 24 51" src="https://user-images.githubusercontent.com/35858359/185751160-7b632934-526d-4227-8f25-2e9f6699c6b6.png">

```
${PROJECT_DIR}/scripts/generateLocalizableFile.sh ${PROJECT_DIR}

```
Press cmd + B to trigger prebuild.

Switch to "Report Navigator" (cmd + 9) tab and select Top "Build" to see the output.
<img width="1680" alt="Screenshot 2022-08-20 at 21 31 20" src="https://user-images.githubusercontent.com/35858359/185751535-faeea5e5-9d7a-4111-aba4-3d41c1c87ea8.png">
