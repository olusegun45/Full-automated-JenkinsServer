# Create assume Role for EC2 to use EBS
resource "aws_iam_role" "Jenkins-Serveriamrole" {
  name = "Jenkins-Serveriamrole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "Jenkins-Serveriamrole"
  }
}
# Create an EC2 intance profile
resource "aws_iam_instance_profile" "Jenkins-Server-profile" {
  name = "Jenkins-Server-profile"
  role = "${aws_iam_role.Jenkins-Serveriamrole.name}"
}

#Adding IAM policy to give Administrator access
resource "aws_iam_role_policy" "Jenkins-Server-policy" {
  name = "Jenkins-Server-policy"
  role = "${aws_iam_role.Jenkins-Serveriamrole.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
EOF
}

# Attach this Role to the EC2 Instance