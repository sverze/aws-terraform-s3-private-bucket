package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// An example of how to test the Terraform module in examples/terraform-aws-s3-example using Terratest.
func TestS3Complete(t *testing.T) {
	t.Parallel()

	// arrange
	awsRegion := "eu-west-1"
	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../../../main/terraform/examples/s3-complete",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"region": awsRegion,
		},
	}

	// Apply
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
	bucketId := terraform.Output(t, terraformOptions, "this_s3_bucket_id")


	// Assert
	assert.NotNil(t, bucketId)
	assert.Equal(t, "Enabled", aws.GetS3BucketVersioning(t, awsRegion, bucketId))
	aws.AssertS3BucketPolicyExists(t, awsRegion, bucketId)
	aws.AssertS3BucketVersioningExists(t, awsRegion, bucketId)
}
