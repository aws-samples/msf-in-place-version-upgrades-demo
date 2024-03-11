# Managed Service for Apache Flink In-Place Version Upgrades

This project is meant to be used in conjunction with Managed Service for Apache Flink in-place version upgrades to illustrate and demonstrate the feature. In this project you will find 3 Apache Flink applications with 3 corresponding Apache Flink versions: [v1.8](1_8), [v1.15](1_15), and [v1.18](1_18). In each folder, you will find instructions on how to compile the code under src/main/resources. 

But two fully illustrative demos are available in the root of the project, simulating a successful upgrade, and a rollback to the upgrade. These scripts are not meant to be executed standalone, but many of the requests can be made synchronously--one after the other.

## Getting started

1. Compile the code for the application you wish to upgrade (instructions in respective repo of project)
2. Upload the application artifact to Amazon S3
3. Update the code in [upgrades.sh](upgrades.sh) to match the location of your application artifact(s).
4. Run the commands sequentially.

