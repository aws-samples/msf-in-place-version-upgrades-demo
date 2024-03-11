# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

setopt interactivecomments
export appName=my-upgrade-application
export region=us-west-1
export runtimeEnv1_8=FLINK-1_8
export runtimeEnv1_18=FLINK-1_18
export bucketArn=arn:aws:s3:::flink-version-upgrades
export serviceExecutionRole=arn:aws:iam::123456789101:role/MF-stream-rw-role

# create 1.8 application

aws kinesisanalyticsv2 create-application \
     --region $region \
     --application-name $appName \
     --runtime-environment $runtimeEnv1_8 \
     --service-execution-role $serviceExecutionRole \
     --application-configuration '{
       "FlinkApplicationConfiguration": {
          "ParallelismConfiguration": {
             "ConfigurationType": "CUSTOM",
             "Parallelism": 1,
             "ParallelismPerKPU": 1,
             "AutoScalingEnabled": false
          }
       },
       "ApplicationSnapshotConfiguration": {
         "SnapshotsEnabled":true
       },
       "ApplicationCodeConfiguration": {
          "CodeContent": {
             "S3ContentLocation": {
                "BucketARN": "'${bucketArn}'",
                "FileKey": "1_8/amazon-msf-java-stream-app-1.0.jar"
             }
          },
          "CodeContentType": "ZIPFILE"
       },
       "EnvironmentProperties":  {
         "PropertyGroups": [
           {
             "PropertyGroupId": "ProducerConfigProperties",
             "PropertyMap" : {
               "flink.stream.initpos" : "LATEST",
               "aws.region" : "us-west-1",
               "AggregationEnabled" : "false"
             }
           },
           {
             "PropertyGroupId": "ConsumerConfigProperties",
             "PropertyMap" : {
               "aws.region" : "us-west-1"
             }
           }
         ]
       }
  }'


# start application
aws kinesisanalyticsv2 start-application \
    --region ${region} \
    --application-name ${appName}

# see application status
aws kinesisanalyticsv2 describe-application \
    --region ${region} \
    --application-name ${appName} | jq ".ApplicationDetail.ApplicationStatus"

# upgrade to 1.18
aws kinesisanalyticsv2 update-application \
    --region ${region} \
    --application-name ${appName} \
    --current-application-version-id 1 \
    --runtime-environment-update ${runtimeEnv1_18} \
    --application-configuration-update '{
      "ApplicationCodeConfigurationUpdate": {
        "CodeContentTypeUpdate": "ZIPFILE",
        "CodeContentUpdate": {
          "S3ContentLocationUpdate": {
                "BucketARNUpdate": "'${bucketArn}'",
                "FileKeyUpdate": "1_18/amazon-msf-java-stream-app-1.0.jar"
          }
        }
      },
      "EnvironmentPropertyUpdates":  {
        "PropertyGroups": [
          {
            "PropertyGroupId": "FlinkApplicationProperties",
            "PropertyMap": {
              "InputStreamName": "ExampleInputStream",
              "OutputStreamName": "ExampleOutputStream",
              "OutputStreamRegion": "us-west-1",
              "InputStreamRegion": "us-west-1",
              "AggregationEnabled": "false"
            }
          }
        ]
      }
    }'


# get status
aws kinesisanalyticsv2 describe-application \
    --region ${region} \
    --application-name ${appName} | jq ".ApplicationDetail.ApplicationStatus"


# downgrade to 1.8 again
aws kinesisanalyticsv2 update-application \
    --region ${region} \
    --application-name ${appName} \
    --current-application-version-id 4 \
    --runtime-environment-update ${runtimeEnv1_8} \
    --application-configuration-update '{
      "ApplicationCodeConfigurationUpdate": {
        "CodeContentTypeUpdate": "ZIPFILE",
        "CodeContentUpdate": {
          "S3ContentLocationUpdate": {
                "BucketARNUpdate": "'${bucketArn}'",
                "FileKeyUpdate": "1_8/amazon-msf-java-stream-app-1.0.jar"
          }
        }
      },
       "EnvironmentPropertyUpdates":  {
         "PropertyGroups": [
           {
             "PropertyGroupId": "ProducerConfigProperties",
             "PropertyMap" : {
               "flink.stream.initpos" : "LATEST",
               "aws.region" : "us-west-1",
               "AggregationEnabled" : "false"
             }
           },
           {
             "PropertyGroupId": "ConsumerConfigProperties",
             "PropertyMap" : {
               "aws.region" : "us-west-1"
             }
           }
         ]
       }
    }'



# get status
aws kinesisanalyticsv2 describe-application \
    --region ${region} \
    --application-name ${appName} | jq ".ApplicationDetail.ApplicationStatus"


# delete app

# first get create timestamp
CT=$(aws kinesisanalyticsv2 describe-application \
    --region ${region} \
    --application-name ${appName} | jq '.ApplicationDetail.CreateTimestamp')


# call delete app with timestamp
aws kinesisanalyticsv2 delete-application --region ${region} --application-name ${appName} --create-timestamp ${CT}