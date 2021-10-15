# localstack-terraform-example
Example of using terraform with Localstack (https://localstack.cloud)

## Get Started

To get started, open a terminal and bring up the localstack instance with `docker-compose up`.

Then in another terminal you can deploy the terraform component:
```bash
cd deploy/
terraform init
terraform apply
# Watch as your resources are magically created.... locally!
```

## Inspect & Test

To actually look around and try out your resources you can use the AWS cli. The easiest way is to install `awslocal` (a thin wrapper around `aws`): https://github.com/localstack/awscli-local

Otherwise you can manually use `aws` with the `--endpoint-url=http://localhost:4566` flag. They're both the same.

For example:
```
# With awslocal
rikki@1-ITC-009 ~/s/localstack (main)> awslocal s3 ls
2021-10-14 23:00:21 my-bucket

# With aws --endpoint=...
rikki@1-ITC-009 ~/s/localstack (main)> aws --endpoint-url=http://localhost:4566 s3 ls
2021-10-14 23:00:21 my-bucket
```

## Example

This example `main.tf` creates two resources:
- Lambda Function `my-lambda1`
- SQS Queue with a random-pet name

and connects the Lambda to the Queue with a trigger, so that the Lambda will run and print to the log the content of any message sent to the SQS queue.

The Lambda code is very simple, it prints `"Hello from app1!"` as a log line, then prints the JSON event that it recieved as a second log line, and if called synchronously echos back the JSON event:
```python
def lambda_handler(event, context):
    print("Hello from app1!")
    print(event)
    
    return event
```

Example in action:
```
# Show that our function exists
rikki@1-ITC-009 ~/s/localstack (main)> awslocal lambda list-functions
{
    "Functions": [
        {
            "FunctionName": "my-lambda1",
            "FunctionArn": "arn:aws:lambda:us-east-1:000000000000:function:my-lambda1",
            "Runtime": "python3.8",
            "Role": "arn:aws:iam::000000000000:role/my-lambda1",
            "Handler": "index.lambda_handler",
            "CodeSize": 234,
            "Description": "My awesome lambda function",
            "Timeout": 3,
            "MemorySize": 128,
            "LastModified": "2021-10-14T22:00:21.716+0000",
            "CodeSha256": "+WCmsX/ZHr/gWHFLj+/yj29nve/u7SJyk2v4IXqe7F4=",
            "Version": "$LATEST",
            "VpcConfig": {},
            "TracingConfig": {
                "Mode": "PassThrough"
            },
            "RevisionId": "2894fd8d-5f5f-4e11-85c8-ff87d38c2789",
            "State": "Active",
            "LastUpdateStatus": "Successful",
            "PackageType": "Zip"
        }
    ]
}

# Show that our SQS Queue exists (Yours will have a different pet-name):
rikki@1-ITC-009 ~/s/localstack (main)> awslocal sqs list-queues
{
    "QueueUrls": [
        "http://localhost:4566/000000000000/exciting-ladybug",
        "http://localhost:4566/000000000000/exciting-ladybug-failure"
    ]
}

# Send a message to the SQS Queue
rikki@1-ITC-009 ~/s/localstack (main)> awslocal sqs send-message --queue-url http://localhost:4566/000000000000/exciting-ladybug --message-body "Hello, World!"
{
    "MD5OfMessageBody": "65a8e27d8879283831b664bd8b7f0ad4",
    "MessageId": "6580c7fd-7366-13dc-b870-9cb47d749c47"
}

# Check the Lambda logs, and see that it got our message!
rikki@1-ITC-009 ~/s/localstack (main)> awslocal logs tail /aws/lambda/my-lambda1
2021-10-15T16:03:12.888000+00:00 2021/10/15/[LATEST]47033315 START RequestId: 39ab78f9-e681-1428-c8cf-8362168dd9b8 Version: $LATEST
2021-10-15T16:03:12.891000+00:00 2021/10/15/[LATEST]47033315
2021-10-15T16:03:12.894000+00:00 2021/10/15/[LATEST]47033315 Hello from app1!
2021-10-15T16:03:12.897000+00:00 2021/10/15/[LATEST]47033315 {'Records': [{'body': 'Hello, World!', 'receiptHandle': 'ofhvqkknnnmtyzldfktnkqduccwypkcjqutrgeehaiwmbqjnsdiapdkrilmgxbkyxwrafnptyvzqaritpztjzbxrfvjzluicsdidexfeuvrnuujksaoboitdnacauewfcxuolaentfprttxcbzcziovblwluooveikqsmlyyfafcipizlbehdclvu', 'md5OfBody': '65a8e27d8879283831b664bd8b7f0ad4', 'eventSourceARN': 'arn:aws:sqs:us-east-1:000000000000:exciting-ladybug', 'eventSource': 'aws:sqs', 'awsRegion': 'us-east-1', 'messageId': '6580c7fd-7366-13dc-b870-9cb47d749c47', 'attributes': {'SenderId': 'AIDAIT2UOQQY3AUEKVGXU', 'SentTimestamp': '1634313791038', 'ApproximateReceiveCount': '1', 'ApproximateFirstReceiveTimestamp': '1634313791680'}, 'messageAttributes': {}, 'md5OfMessageAttributes': None, 'sqs': True}]}
2021-10-15T16:03:12.903000+00:00 2021/10/15/[LATEST]47033315 END RequestId: 39ab78f9-e681-1428-c8cf-8362168dd9b8
2021-10-15T16:03:12.906000+00:00 2021/10/15/[LATEST]47033315
2021-10-15T16:03:12.912000+00:00 2021/10/15/[LATEST]47033315 REPORT RequestId: 39ab78f9-e681-1428-c8cf-8362168dd9b8     Init Duration: 324.74 ms        Duration: 4.95 ms       Billed Duration: 5 ms   Memory Size:
1536 MB Max Memory Used: 24 MB
2021-10-15T16:03:12.915000+00:00 2021/10/15/[LATEST]47033315
```
