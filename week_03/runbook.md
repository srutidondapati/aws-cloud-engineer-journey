## 1. Launch EC2 Instance:
   
   An instance for EC2 was launched using the Amazon Linux AMI and configured with a new key pair which was ensured to be secured in an ssh. After downloading the key, it was copied into the Ubuntu shell and the permissions where restricted using the commands: "chmod 400 ~/.ssh/training-key.pem". The chmod 400 command ensures that no outside users have access to the key except for my user.
   
## 2. Configure security group:
   
   I configured the security group as specified: SSH (port 22, source: “My IP”) and custom TCP port 8080 (source: Anywhere). These configurations ensure that the port is set for PropertyLite specifically and not just any default one.

## 3. Adding Bootstrap:
   
   EC2 user data was modified to include the bootstrap script which automatically installs Python, pip, Flask 3.0.3, and writes the application and sample CSV files. It starts the server which listens on the 8080 port and allows connections through the network interface.
      - Issues:
           - The application did not start because the actual Python code for app.py from Week 0 was not included, for which I had to copy over the working app.py and csv files from my local project to the instance via scp. Once the transfer of the files was confirmed, I was able to start the application and get it working correctly.
       
## 4. Instance Connection

   EC2 was connected from my Ubuntu terminal using the command: "ssh -i ~/.ssh/training-key.pem ec2-user@<public-ip>" which was replaced with the actual public IPv4 address of the instance. I tested the API from my Ubuntu terminal using the commands:

curl http://<public-ip>:8080/health
curl http://<public-ip>:8080/properties/R100234

## 5. EBS Snapshot



