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

# Resource-8: Creat Jenkins-maven-ansible-Server
resource "aws_instance" "Jenkins-maven-ansible-Server" {
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
    Name = "Jenkins-maven-ansible-Server"
  }

# Copies the file as the root user using SSH (https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec)

provisioner "local-exec" {
    command = "echo ${self.public_ip} >> public_ips.txt"
  }
}

output "public_ip" {
  value = aws_instance.Jenkins-maven-ansible-Server.*.public_ip
}

# Indexing
 #    0               1               2
# [instancetype-1, intancetype-2, instancetype-3]


# Resource-9: Creat Security Group for SonarQube
resource "aws_security_group" "SonarQube-SG" {
  name        = "SonarQube-SG"
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
      from_port         = 9000
      to_port           = 9000
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
    Name = "SonarQube-SG"
  }
}

# Resource-10: Creat Ubuntu 18.04 VM instance and call it "SonarQube"
resource "aws_instance" "SonarQube" {
  ami           = "ami-04fa64c4b38e36384"
  instance_type = var.oserv-instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.fully-automated-cicd-VPC-Pub-sbn.id
  vpc_security_group_ids = [aws_security_group.SonarQube-SG.id]
  user_data = <<-EOF
      #!/bin/bash
      cp /etc/sysctl.conf /root/sysctl.conf_backup
      cat <<EOT> /etc/sysctl.conf
      vm.max_map_count=262144
      fs.file-max=65536
      ulimit -n 65536
      ulimit -u 4096
      EOT
      cp /etc/security/limits.conf /root/sec_limit.conf_backup
      cat <<EOT> /etc/security/limits.conf
      sonarqube   -   nofile   65536
      sonarqube   -   nproc    409
      EOT

      sudo apt-get update -y
      sudo apt-get install openjdk-11-jdk -y
      sudo update-alternatives --config java

      java -version

      sudo apt update
      wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -

      sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
      sudo apt install postgresql postgresql-contrib -y
      #sudo -u postgres psql -c "SELECT version();"
      sudo systemctl enable postgresql.service
      sudo systemctl start  postgresql.service
      sudo echo "postgres:admin123" | chpasswd
      runuser -l postgres -c "createuser sonar"
      sudo -i -u postgres psql -c "ALTER USER sonar WITH ENCRYPTED PASSWORD 'admin123';"
      sudo -i -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
      sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube to sonar;"
      systemctl restart  postgresql
      #systemctl status -l   postgresql
      netstat -tulpena | grep postgres
      sudo mkdir -p /sonarqube/
      cd /sonarqube/
      sudo curl -O https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.3.0.34182.zip
      sudo apt-get install zip -y
      sudo unzip -o sonarqube-8.3.0.34182.zip -d /opt/
      sudo mv /opt/sonarqube-8.3.0.34182/ /opt/sonarqube
      sudo groupadd sonar
      sudo useradd -c "SonarQube - User" -d /opt/sonarqube/ -g sonar sonar
      sudo chown sonar:sonar /opt/sonarqube/ -R
      cp /opt/sonarqube/conf/sonar.properties /root/sonar.properties_backup
      cat <<EOT> /opt/sonarqube/conf/sonar.properties
      sonar.jdbc.username=sonar
      sonar.jdbc.password=admin123
      sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
      sonar.web.host=0.0.0.0
      sonar.web.port=9000
      sonar.web.javaAdditionalOpts=-server
      sonar.search.javaOpts=-Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError
      sonar.log.level=INFO
      sonar.path.logs=logs
      EOT

      cat <<EOT> /etc/systemd/system/sonarqube.service
      [Unit]
      Description=SonarQube service
      After=syslog.target network.target

      [Service]
      Type=forking

      ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
      ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

      User=sonar
      Group=sonar
      Restart=always

      LimitNOFILE=65536
      LimitNPROC=4096


      [Install]
      WantedBy=multi-user.target
      EOT

      systemctl daemon-reload
      systemctl enable sonarqube.service
      #systemctl start sonarqube.service
      #systemctl status -l sonarqube.service
      apt-get install nginx -y
      rm -rf /etc/nginx/sites-enabled/default
      rm -rf /etc/nginx/sites-available/default
      cat <<EOT> /etc/nginx/sites-available/sonarqube
      server{
          listen      80;
          server_name sonarqube.groophy.in;

          access_log  /var/log/nginx/sonar.access.log;
          error_log   /var/log/nginx/sonar.error.log;

          proxy_buffers 16 64k;
          proxy_buffer_size 128k;

          location / {
              proxy_pass  http://127.0.0.1:9000;
              proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
              proxy_redirect off;
                    
              proxy_set_header    Host            \$host;
              proxy_set_header    X-Real-IP       \$remote_addr;
              proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
              proxy_set_header    X-Forwarded-Proto http;
          }
      }
      EOT
      ln -s /etc/nginx/sites-available/sonarqube /etc/nginx/sites-enabled/sonarqube
      systemctl enable nginx.service
      #systemctl restart nginx.service
      sudo ufw allow 80,9000,9001/tcp

      echo "System reboot in 30 sec"
      sleep 30
      reboot
    EOF
  tags = {
    Name = "SonarQube"
  }
}

# Resource-11: Creat Security Group for Nexus
resource "aws_security_group" "Nexus-SG" {
  name        = "Nexus-SG"
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
      from_port         = 8081
      to_port           = 8081
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
    Name = "Nexus-SG"
  }
}

# Resource-12: Create an Amazon Linux 2 VM instance and call it "Nexus"
resource "aws_instance" "Nexus" {
  ami           = "ami-0a606d8395a538502"
  instance_type = var.oserv-instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.fully-automated-cicd-VPC-Pub-sbn.id
  vpc_security_group_ids = [aws_security_group.Nexus-SG.id]
  user_data = <<-EOF
      #!/bin/bash
      yum install java-1.8.0-openjdk.x86_64 wget -y   
      mkdir -p /opt/nexus/   
      mkdir -p /tmp/nexus/                           
      cd /tmp/nexus/
      NEXUSURL="https://download.sonatype.com/nexus/3/latest-unix.tar.gz"
      wget $NEXUSURL -O nexus.tar.gz
      EXTOUT=`tar xzvf nexus.tar.gz`
      NEXUSDIR=`echo $EXTOUT | cut -d '/' -f1`
      rm -rf /tmp/nexus/nexus.tar.gz
      rsync -avzh /tmp/nexus/ /opt/nexus/
      useradd nexus
      chown -R nexus.nexus /opt/nexus 
      cat <<EOT>> /etc/systemd/system/nexus.service
      [Unit]                                                                          
      Description=nexus service                                                       
      After=network.target                                                            
                                                                        
      [Service]                                                                       
      Type=forking                                                                    
      LimitNOFILE=65536                                                               
      ExecStart=/opt/nexus/$NEXUSDIR/bin/nexus start                                  
      ExecStop=/opt/nexus/$NEXUSDIR/bin/nexus stop                                    
      User=nexus                                                                      
      Restart=on-abort                                                                
                                                                        
      [Install]                                                                       
      WantedBy=multi-user.target                                                      

      EOT

      echo 'run_as_user="nexus"' > /opt/nexus/$NEXUSDIR/bin/nexus.rc
      systemctl daemon-reload
      systemctl start nexus
      systemctl enable nexus

      # Installing Git
      sudo yum install git -y
      ###  
    EOF

  tags = {
    Name = "Nexus"
  }
}

# Resource-13: Creat Security Group for Prometheus
resource "aws_security_group" "Promethius-SG" {
  name        = "Promethius-SG"
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
      from_port         = 9090
      to_port           = 9090
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
    Name = "Promethius-SG"
  }
}

# Resource-14: Create an Ubuntu 20.04 VM instance and call it "Prometheus"
resource "aws_instance" "Prometheus" {
  ami           = "ami-0ada6d94f396377f2"
  instance_type = var.oserv-instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.fully-automated-cicd-VPC-Pub-sbn.id
  vpc_security_group_ids = [aws_security_group.Promethius-SG.id]

  tags = {
    Name = "Prometheus"
  }
}

# Resource-15: Creat Security Group for Grafana
resource "aws_security_group" "Grafana-SG" {
  name        = "Grafana-SG"
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
      from_port         = 3000
      to_port           = 3000
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
    Name = "Grafana-SG"
  }
}

# Resource-16: Create an Ubuntu 20.04 VM instance and call it "Grafana"
resource "aws_instance" "Grafana" {
  ami           = "ami-0ada6d94f396377f2"
  instance_type = var.oserv-instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.fully-automated-cicd-VPC-Pub-sbn.id
  vpc_security_group_ids = [aws_security_group.Grafana-SG.id]

  tags = {
    Name = "Grafana"
  }
}
