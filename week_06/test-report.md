# Week 06: Load Test Report (ELB & Auto Scaling)

## Setup
- **ALB:** property-api-alb (HTTP 80) forwarding to target group property-api-tg (port 8080, health check `/health`)
- **ASG:** property-api-asg, min 1 / desired 2 / max 4, launch template property-api-template (v2)
- **Scaling policy:** target tracking, average CPU 50%
- **Instances:** t3.micro, Amazon Linux 2023, default VPC (public subnets, no NAT gateway)

The ALB serving both endpoints:
![ALB serving /health and /properties](6.1.png)

## Self-healing test
Manually terminated `i-0ec204f2e1131b0d8` in the EC2 console. The ASG detected it at 20:45:28 and launched replacement `i-0e388985628db2c75` at 20:45:30 (detection-to-launch: ~2 seconds).

![Self-healing activity](6.2_self_healing.png)

## Scale-out test
- **Stress started** (`stress-ng --cpu 2 --timeout 600s`): ~20:18:30 on one instance (estimated from the instance's package-install log)
- **CPU crossed 50%:** 20:20 datapoint (~100%)
- **AlarmHigh #1:** 20:24:55, desired 1 → 2,

![Scale-out activity](6.2_scale_out.png)

![CPU utilization](6.2_cloud_watch.png)
