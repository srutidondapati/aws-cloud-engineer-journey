# AWS Cloud Engineer Journey

## Week 01: Root vs IAM vs Shared Responsibility Model:
  - The root user account is the master account that is automatically created along with your AWS account, has no limitations to power, but should only be used for billing or MFA tasks. The IAM account is a user account with specific permissions assigned to by the root account. This account is used for everyday work such as operating AWS CLI or operating within the set boundaries/permissions. The shared responsibility model ensures the guidelines between the user and AWS, highlighting that the user is responsible for protecting their work and account while AWS handles the physical components of where the data is stored. AWS stored the data and secures the cloud while the user is entirely responsible for making sure their work is secured with the right passwords and account IDs by efficiently using the root and IAM users.

## Week 02: IAM Policies:
### S3UploaderOnly-sruti

This policy allows the 's3-test-user' to upload and download specific objects in the 'my-training-bucket-sruti' S3 bucket.

The policy allows:
- 's3:PutObject': allows user to upload objects
- 's3:GetObject': allows user to retrieve/download objects

Scope:
- The policy uses the scope of the training bucket, 'arn:aws:s3:::my-training-bucket-sruti/*'.
- The '/*' ensures that the permissions apply to objects inside the bucket since without the '/*' only refers to the bucket itself, not the objects.
- This policy limits the users access to this particular bucket rather than giving the user all access to the S3 resources.
