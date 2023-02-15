#####       Creating an Infrastructure using CICD Pipeline
  # CI ==== ~>>>> Means:
    Continously building my infrastructure and this comprises 3 stages: Code, Build, and testing. As soon as the code is pusshed to github repository, terraform build, and while building the code checkov perform the testing.
  # CD ==== ~>>>> Means:
    As soon as this is completed a manual approval is required to deploy the code by provisionning the infrastructure, and this is the Continuos deployment

   #### Importing Github Repository
1.  log in to your github account
2.  go to the repository you want to import
3.  at top right hand coner, dropdown nest to the + sign, and click on the import repository
4.  Copy the repository url you want to import, and paste where its ask for old url
5.  Give the repository name, and Begin import
6.  This is a terraform infrastructure provitioning code base, not application deployment code base
    our codebase is in the repository

# =======>  Clone this Repository to your local system <==========

Create an Amazon Linux 2 VM instance and call it "Jenkins"
Instance type: t2.large  {we will install, java, jenkins, maven, ansible, node expoter}
Security Group (Open): 8080, 9100 and 22 to 0.0.0.0/0
Key pair: Select or create a new keypair
Attach Jenkins server with IAM role having "AdministratorAccess"
User data (Copy the following user data): https://github.com/cvamsikrishna11/devops-fully-automated/blob/installations/jenkins-maven-ansible-setup.sh
Launch Instance
After launching this Jenkins server, attach a tag as Key=Application, value=jenkins

#  To check if the user data is running of part of it failed.
1. log in to the ec2 while it still initialising
2. change to root user  "sudo su"
3. cd to var directory, cd to log, do ls and cat cloud-init-output.log
   or just run this comand cat /var/log/cloud-init-output.log
4. if completed you can now go to ur browser with the pub ip of the server:port number to access the application
   e,g pub ip:8080 to view jenkins
5. copy the directory of the password and cat the password, copy the pswd and paste it on the jenkin

#  Customize Jenkins
1.  Install sujested plugins and create the first Admin user, save and finish

#  Set up Jenkins
1. Click on New, Name = app-infra-pipeline and select the pipeline, click ok ~~~>>> this will take u to the configure
2. click on the code and copy the url on ur github repository and go to the jenkins console click on the pipeline and   configure, select the github project under General and paste the url there, then scroll down to Build Triger section select Github hook trigger for GITScm polling
3. Scroll down to the scrpt section, go and copy the Jenkins file and paste it here

####  Create IAM Role
goto IAM, select Role, create role, select aws Sevice, for use cace select EC2
Now attache this role to Jenkins server
Select the running Jenkins server, click on action, click on security and modify IAM role, select the the role created from the dropdown and update.

#  Payload Url:for webkook
    http://18.191.29.20:8080/github-webhook/
Refresh to see a check mark: meaning ur jenkins is reachable

click on the code and copy the url on ur github repository and go to the jenkins console click on the pipeline and configure, select the github project under General and paste the url there, then scroll down to Build T next add permission select Adminstrator Access
Name = Jenkins-cicd-Admin-Role, then create.riger section select Github hook trigger for GITScm polling

#####   To destroy the jenkins server:
log in to ur Jenkins server, cd to /var/lib/jenkins/workspace/app-infra-pipeline, do ls you will see the terraform state files. then Run terraform destroy --auto-approve  from here.

