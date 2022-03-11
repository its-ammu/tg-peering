# Transit gateway peering with Terraform (Inter region)

> 1. Create two Transit Gateway(TGW) in us-east-1 & us-west-1
> 2. Peer both TGWs
> 3. Create VPCs in both regions.
> 4. Use only private subnets
> 5. Provision some resources(ec2) under those VPCs
> 6. Test cross region private connectivity between resources.
> 7. If all work then try to create above infra via IAC(terraform/cloud formation any).
