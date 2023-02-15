# Resource-7: Creat Security Group for Web Server
resource "aws_security_group" "fully-automated-cicd-SG" {
  name        = "fully-automated-cicd-SG"
  description = "Allow All traffic"
  vpc_id      = aws_vpc.fully-automated-cicd-VPC.id

  ingress    {
      description      = "All traffic"
      from_port         = 22
      to_port           = 22
      protocol          = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

  ingress    {
      description      = "All traffic"
      from_port         = 8080
      to_port           = 8080
      protocol          = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

  ingress    {
      description      = "All traffic"
      from_port         = 9100
      to_port           = 9100
      protocol          = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

  egress     {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

  tags = {
    Name = "fully-automated-cicd-SG"
  }
}

resource "aws_instance" "Jenkins-Server" {
  ami           = "ami-0a606d8395a538502"
  instance_type = var.instance_type
  key_name      = var.key_name
  iam_instance_profile = "${aws_iam_instance_profile.Jenkins-Server-profile.name}"
  subnet_id     = aws_subnet.fully-automated-cicd-VPC-Pub-sbn.id
  vpc_security_group_ids = [aws_security_group.fully-automated-cicd-SG.id]
  user_data = <<-EOF
            #!/bin/bash
            # Hardware requirements: AWS Linux 2 with mimum t2.medium type instance & port 8080(jenkins), 9100 (node-exporter) should be allowed on the security groups
            # Installing Jenkins
            sudo yum update –y
            sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
            sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
            sudo yum upgrade
            sudo amazon-linux-extras install java-openjdk11 -y
            sudo yum install jenkins -y
            sudo echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
            sudo systemctl enable jenkins
            sudo systemctl start jenkins

            # Installing Git
            sudo yum install git -y

            # Installing maven - commented out as usage of tools explanation is required.
            # sudo wget https://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
            # sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
            # sudo yum install -y apache-maven

            # Java installation
            # sudo yum install java-1.8.0-openjdk -y
            # sudo amazon-linux-extras install java-openjdk11 -y

            # Installing Ansible
            sudo amazon-linux-extras install ansible2 -y
            sudo yum install python-pip -y
            sudo pip install boto3
            sudo useradd ansadmin
            sudo echo ansadmin:ansadmin | chpasswd
            sudo sed -i "s/.*#host_key_checking = False/host_key_checking = False/g" /etc/ansible/ansible.cfg
            sudo sed -i "s/.*#enable_plugins = host_list, virtualbox, yaml, constructed/enable_plugins = aws_ec2/g" /etc/ansible/ansible.cfg
            sudo ansible-galaxy collection install amazon.aws

            # node-exporter installations
            sudo useradd --no-create-home node_exporter

            wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
            tar xzf node_exporter-1.0.1.linux-amd64.tar.gz
            sudo cp node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin/node_exporter
            rm -rf node_exporter-1.0.1.linux-amd64.tar.gz node_exporter-1.0.1.linux-amd64

            # setup the node-exporter dependencies
            sudo yum install git -y
            sudo git clone -b installations https://github.com/cvamsikrishna11/devops-fully-automated.git /tmp/devops-fully-automated
            sudo cp /tmp/devops-fully-automated/prometheus-setup-dependencies/node-exporter.service /etc/systemd/system/node-exporter.service

            sudo systemctl daemon-reload
            sudo systemctl enable node-exporter
            sudo systemctl start node-exporter
            sudo systemctl status node-exporter

            # Setup terraform
            sudo yum install -y yum-utils
            sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
            sudo yum -y install terraform
    EOF

  tags = {
    Name = "Jenkins-Server"
  }

# Copies the file as the root user using SSH (https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec)

provisioner "local-exec" {
    command = "echo ${self.public_ip} >> public_ips.txt"
  }
}

output "public_ip" {
  value = aws_instance.Jenkins-Server.*.public_ip
}

# Indexing
 #    0               1               2
# [instancetype-1, intancetype-2, instancetype-3]