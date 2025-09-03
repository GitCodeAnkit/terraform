#!/bin/bash

# ECS Instance User Data Script
# This script configures EC2 instances to join the ECS cluster

# Update system packages
yum update -y

# Configure ECS agent
echo "ECS_CLUSTER=${cluster_name}" >> /etc/ecs/ecs.config
echo "ECS_ENABLE_CONTAINER_METADATA=true" >> /etc/ecs/ecs.config
echo "ECS_ENABLE_TASK_IAM_ROLE=true" >> /etc/ecs/ecs.config
echo "ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true" >> /etc/ecs/ecs.config

# Enable CloudWatch Container Insights
echo "ECS_ENABLE_CONTAINER_METADATA=true" >> /etc/ecs/ecs.config

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Configure CloudWatch agent
cat << EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "metrics": {
        "namespace": "ECS/ContainerInsights",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60,
                "totalcpu": false
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "diskio": {
                "measurement": [
                    "io_time"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            },
            "netstat": {
                "measurement": [
                    "tcp_established",
                    "tcp_time_wait"
                ],
                "metrics_collection_interval": 60
            },
            "swap": {
                "measurement": [
                    "swap_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# Install SSM agent (if not already installed)
yum install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Install Docker (if not already installed)
if ! command -v docker &> /dev/null; then
    yum install -y docker
    systemctl enable docker
    systemctl start docker
fi

# Configure Docker daemon for better logging
cat << EOF > /etc/docker/daemon.json
{
    "log-driver": "awslogs",
    "log-opts": {
        "awslogs-group": "/aws/ecs/cluster/${cluster_name}",
        "awslogs-region": "${region}",
        "awslogs-create-group": "true"
    },
    "storage-driver": "overlay2",
    "storage-opts": [
        "overlay2.override_kernel_check=true"
    ]
}
EOF

# Restart Docker to apply configuration
systemctl restart docker

# Start ECS agent
systemctl enable ecs
systemctl start ecs

# Set up log rotation for ECS agent logs
cat << EOF > /etc/logrotate.d/ecs
/var/log/ecs/ecs-agent.log {
    daily
    rotate 7
    missingok
    notifempty
    compress
    delaycompress
    create 644 root root
    postrotate
        /bin/kill -USR1 $(cat /var/run/ecs-agent.pid 2> /dev/null) 2> /dev/null || true
    endscript
}
EOF

# Configure automatic security updates
yum install -y yum-cron
systemctl enable yum-cron
systemctl start yum-cron

# Signal completion
/opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackName} --resource AutoScalingGroup --region ${region} 2>/dev/null || true

echo "ECS instance configuration completed successfully"
