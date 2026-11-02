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
- The '/\*' ensures that the permissions apply to objects inside the bucket since without the '/\*' only refers to the bucket itself, not the objects.
- This policy limits the users access to this particular bucket rather than giving the user all access to the S3 resources.

## Week 03: Compute: EC2:

## Week 04: Storage & Databases:

## Week 05: Networking:

Built a training-vpc with 2 public and 2 private subnets across 2AZs, an Internet Gateway and one Nat Gateway. Then launched a bastion in public subnet and a private instance inside a private subnet.

- VPC (Virtual Private Cloud): own logically isolated network inside AWS, you can control its newtork. -> created a training-vpc
- Subnets: a smaller network inside the VPC in which you can organize resources based on purpose
    - Public: hosts resources that need a route to the internet
    - Private: hosts resources that shouldn't be directly accessed from the internet
- Bastion host: a server that acts as a controlled entry point into a private network

### Traffic Flow:
1. My laptop connects to bastion host in a public subnet through SSH using a security group that restricts access to my IP address.

2. The bastion host connects to the private EC2 instance using its private IP address. Then, the private instance's security group allows SSH only from the bastion host's security group.

3. The Internet Gateway enables internet connectivity for resources in public subnets, while the NAT Gateway allows private instances to initiate outbound internet connections without being directly accessible from the internet.

4. Private subnet route tables must point to the NAT Gateway for outbound internet access.

## Week 06: Elastic Load Balancing & Auto Scaling:

### Self-healing test
Manually terminated i-0ec204f2e1131b0d8 in the EC2 console. The ASG detected it at
20:45:28 and launched replacement i-0e388985628db2c75 at 20:45:30
(detection-to-launch: ~2 seconds).

### Scale-out test
- Stress started (stress-ng --cpu 2): ~[HH:MM] on i-xxxx
- CPU crossed 50%: 20:20 datapoint (~100%) 
- AlarmHigh #1: 20:24:55, desired 1 → 2, instance launched 20:25:02
- AlarmHigh #2: 20:30:55, desired 2 → 4 (max reached), instances launched 20:31:01
- **Gap between CPU spike and first scale-out: ~5 minutes** (CloudWatch data is
  5-minute granularity)

The group started at 1 rather than 2 because the AlarmLow policy had scaled in the idle
group at 20:13. At 20:39 I manually lowered desired capacity from 4 to 2 to end the test.
