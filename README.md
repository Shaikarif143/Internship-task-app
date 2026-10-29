# Containerized App Deployment on AWS

A static web page served by Apache inside a Docker container. It runs on AWS EC2 and is reachable at `http://<server-ip>:8081`.

## Project files

- `Dockerfile`: builds the image and makes Apache listen on port 8081
- `index.html`: the web page

## Step 1: Launch the EC2 server

- AMI: Amazon Linux 2 (x86_64)
- Instance type: <t2.micro or t3.micro> (<1 GB RAM>, <1-2 vCPU>, <8 GB disk>)
- Why this size: a static page needs very little CPU and memory, and it stays in the free tier.
- Security group rules:
  - SSH, port 22, source: my IP only
  - Custom TCP, port 8081, source: 0.0.0.0/0 (so anyone can open the app)

## Step 2: Install Docker

```bash
sudo yum update -y
sudo yum install -y docker git
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user
```

Log out and log in again, then verify:

```bash
docker run hello-world
```

## Step 3: Get the code

```bash
git clone https://github.com/Shaikarif143/Internship-task-app.git
cd Internship-task-app
```

## Step 4: Build the image

```bash
docker build -t arif:v1 .
```

## Step 5: Run the container

```bash
docker run -d --name task --restart unless-stopped -p 8081:8081 arif:v1
```

- `-d` runs it in the background.
- `--restart unless-stopped` starts it again after a reboot or crash.
- `-p 8081:8081` maps server port 8081 to container port 8081.

## Step 6: Test

On the server:

```bash
curl localhost:8081
```

In a browser, from any device:

```
http://<server-ip>:8081
```

## Step 7: Deploy on ECS (Fargate)

1. Create an ECR repository and push the image:
   ```bash
   aws ecr create-repository --repository-name task-app --region <region>
   aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com
   docker tag arif:v1 <account-id>.dkr.ecr.<region>.amazonaws.com/task-app:latest
   docker push <account-id>.dkr.ecr.<region>.amazonaws.com/task-app:latest
   ```
2. Create an ECS cluster using AWS Fargate.
3. Create a task definition: 0.25 vCPU, 0.5 GB memory, container port 8081, image from ECR.
4. Create a service with 1 desired task, a public subnet, and public IP turned on.
5. Use a security group that allows TCP 8081 from anywhere.
6. Open `http://<task-public-ip>:8081` to confirm.

## Problems faced and fixes

- Browser showed "connection reset". Apache listened on port 80 inside the container, but I mapped port 8081. Fixed by changing `Listen 80` to `Listen 8081` in the Dockerfile.
- `docker` gave "permission denied". Fixed by adding my user to the docker group and logging in again.

## Cleanup

Delete the ECS service and cluster, delete the ECR repository, and terminate the EC2 instance to avoid charges.
