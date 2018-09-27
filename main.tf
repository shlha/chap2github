provider "aws" {
    # shehry's account work credentials
      # access_key = "AKIAIFNFYYH4MHK5QPUQ"
      # secret_key = "LastPass"
      # region     = "us-east-1"

    # Non Root - shehr.uk.personal Peronsal AWS Account
      access_key = "AKIAID2JE7XMRFO52QJA"
      secret_key = "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"
      region     = "us-east-1"
}

# VARIABLES
variable "server_port"
{
  description = "The port ther Server will use for HTTP requests"
  default = "8080"
}


# INSTANCE - LAUNCH CONFIG FOR ASG
resource "aws_launch_configuration" "example" {
    image_id = "ami-40d28157"
    instance_type = "t2.micro"
    security_groups = ["${aws_security_group.instance.id}"]

    user_data = <<-EOF
            #!/bin/bash
            echo "Hello, The Amazing World" > index.html
            nohup busybox httpd -f -p "${var.server_port}" &
            EOF

    lifecycle {
      create_before_destroy = true
    }
}

# ASG creation
resource "aws_autoscaling_group" "example"
{
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zone = ["${data.aws_availability_zone.all.names}"]
  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "terraform-asg-example"
    propogate_at_launch = true
  }
}

# SECURITY GROUP
resource "aws_security_group" "instance"
{
  name = "terraform-example-instance"

  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle{
    create_before_destroy = true
  }
}

# OUTPUT VARIABLES
output "public_ip"{
  value = "${aws_instance.example.public_ip}"
}
