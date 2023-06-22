Sample objects for Islandora. These are the objects and metadata that populate the Islandora Sandbox. Demo objects in sandbox.islandora.ca are ingested using [Islandora Workbench](https://github.com/mjordan/islandora_workbench), a "command-line tool that allows creation, updating, and deletion of Islandora content from CSV data." This spreadsheet is maintained in [Google Sheets](https://docs.google.com/spreadsheets/d/1DV0Ka0ZafZq3RgCn0x_AetFtlmnMuNFltzck2QL0ApY/edit#gid=2042408311) to make it easier to view and manipulate. Once edits are made, the main sheet is downloaded as .csv and then applied to the nightly build of Sandbox. 

## Usage

Import the demo objects using [Islandora Workbench](https://github.com/mjordan/islandora_workbench) using the included .yml file and .csv files.

## Updates

The [Sandbox](https://github.com/Islandora-Devops/sandbox) makes use of this repository and the create_islandora_objects.csv file (it has its own .yml file). However, the sandbox is locked to a specific commit of this repository and will not get updates until you update the specified commit hash, SHA-256 hash, and cut a release of the Sandbox. Full instructions are in the README of the above-linked Sandbox repo. 




