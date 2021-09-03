package main

import (
	"context"
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/aws/aws-sdk-go-v2/service/ec2/types"
	"github.com/pkg/errors"
)

func HandleRequest(ctx context.Context) (string, error) {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return "", errors.Wrap(err, "Failed to load credentials")
	}
	client := ec2.NewFromConfig(cfg)

	// Get EC2 instances with matching Tag
	result, err := client.DescribeInstances(ctx, &ec2.DescribeInstancesInput{
		Filters: []types.Filter{
			types.Filter{
				Name: aws.String("tag:App"),
				Values: []string{
					*aws.String("FoundryVTT"),
				},
			},
		},
	})
	if err != nil {
		return "", errors.Wrap(err, "Failed to fetch EC2 instances")
	}

	instances := make([]string, 2)
	for _, reservation := range result.Reservations {
		for _, instance := range reservation.Instances {
			instances = append(instances, *instance.InstanceId)
			fmt.Printf("Instance to stop: %s", *instance.InstanceId)
		}
	}

	// Stop found instances
	_, err = client.StopInstances(ctx, &ec2.StopInstancesInput{
		InstanceIds: instances,
		DryRun:      aws.Bool(true),
	})
	if err != nil {
		return "", errors.Wrapf(err, "Failed to stop instances: %+v", instances)
	}

	return fmt.Sprintf("Done"), nil
}

func main() {
	lambda.Start(HandleRequest)
}
