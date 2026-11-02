Week 06: Load Test Report (ELB & Auto Scaling)
Setup
ALB: property-api-alb (HTTP 80) forwarding to target group property-api-tg (port 8080, health check /health)
ASG: property-api-asg, min 1 / desired 2 / max 4, launch template property-api-template (v2)
Scaling policy: target tracking, average CPU 50%
Instances: t3.micro, Amazon Linux 2023, default VPC (public subnets, no NAT gateway)

The ALB serving both endpoints:

ALB serving /health and /properties

Self-healing test

Manually terminated i-0ec204f2e1131b0d8 in the EC2 console. The ASG detected it at 20:45:28 and launched replacement i-0e388985628db2c75 at 20:45:30 (detection-to-launch: ~2 seconds).

Self-healing activity

Scale-out test
Stress started (stress-ng --cpu 2 --timeout 600s): ~20:18:30 on one instance (estimated from the instance's package-install log)
CPU crossed 50%: 20:20 datapoint (~100%)
AlarmHigh #1: 20:24:55, desired 1 → 2, instance launched 20:25:02
AlarmHigh #2: 20:30:55, desired 2 → 4 (max reached), instances launched 20:31:01
Gap between CPU spike and first scale-out: ~5 minutes (CloudWatch data is 5-minute granularity, so this is approximate)

CPU utilization

Scale-out activity

The group began the test at 1 instance rather than 2 because the AlarmLow policy had scaled in the idle group at 20:13. At 20:39 I manually lowered desired capacity from 4 to 2 to end the test.

Observations
Why the delay: target tracking only fires after several consecutive datapoints above the target, so scale-out lags the CPU spike by a few minutes.
502 debugging (Lab 6.3): targets were unhealthy and the ALB returned 502. The security group rule and health check were correct. The instance system log showed cloud-init ignoring my user data ("Unhandled non-multipart userdata") because it began with raw Python instead of a shebang, so Flask never started. Fix: a #!/bin/bash script that installs pip and Flask, writes app.py and the CSV, and runs the app as a systemd service.
Side effect: with ELB health checks enabled, the ASG kept terminating and replacing the broken instances until the user data was fixed.
Scale-in: target tracking also removes instances when CPU is low (seen at 19:49 and 20:13).
What I'd tune: a longer health check grace period, a lower max or a cooldown to avoid jumping 2 → 4, private subnets with a NAT gateway, and 1-minute group metrics for tighter timing.
Cleanup

Deleted in order: ASG, ALB, target group, launch template.
