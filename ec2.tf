provider "aws" {
  region     = "ap-south-1"
  profile    = "tanishaprofile"
}

resource "aws_key_pair" "task1-hybrid-key1" {
  key_name   = "task1-hybrid-key1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAtdwSTtOdDDlkr0m+I+0WiRS9mICS0y2WoevAAdlxNbO/pT5pNkuIEgZVwK+rwRJIaoa/asDB26/6jaybK2KliNLWDvoIVngH/EaYMksiCyI4U5MwHV3GO0XS974I6DAnqjvNH5/5+VAARXFoxR49n+mte0UaF2xcZgq0lPQkKVdJW6SUcKA5sVa1OJBfQ54hC45LpipERgNWCev4OiVBMShYjT1sa3zbBsBQLLcUbxv7YatdXIy7/iUyl4WjuyQKpCnoOyH6khYELv2tEKtbM6FN6Euxg0AWSeZ46LeEMMvFiL6faXvV6xi1uWldNKOoP2O2VPQDtPVq2r3wjI+mEw== rsa-key-20200611"
}

resource "aws_security_group" "task1-sg" {
  name        = "task1-sg"
  description = "Allow TLS inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "task1-sg"
  }
}

resource "aws_ebs_volume" "task1-ebs" {
  availability_zone = "ap-south-1a"
  size              = 1

  tags = {
    Name = "task1-ebs"
  }
}

resource "aws_s3_bucket" "task3bucket" {
  bucket = "tanishabucket30"
  acl = "public-read"
  versioning {
    enabled = true
  }
  tags = {
    Name = "task3bucket"
  }
}
 
resource "aws_cloudfront_distribution" "tanishacf" {
  origin {
     domain_name = "tanishabucket30.s3.amazonaws.com"
     origin_id = "S3-tanishabucket30"
     custom_origin_config {
            http_port = 80
            https_port = 80
            origin_protocol_policy = "match-viewer"
            origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"] 
        }
    }
       
    enabled = true

    default_cache_behavior {
        allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = "S3-tanishabucket30"

        forwarded_values {
            query_string = false
        
            cookies {
               forward = "none"
            }
        }
        viewer_protocol_policy = "allow-all"
        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400
    }
    
    restrictions {
        geo_restriction {
            
            restriction_type = "none"
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = true
    }
}

resource "aws_volume_attachment" "task1-ebs-att" {
  device_name = "/dev/sdf"
  volume_id   = "${aws_ebs_volume.task1-ebs.id}"
  instance_id = "${aws_instance.task1-ins.id}"
}

resource "aws_instance" "task1-ins" {
  ami               = "ami-0447a12f28fddb066"
  instance_type     = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name          = "task1-hybrid-key1"
  security_groups   = [ "task1-sg" ]
  
  tags = {
    Name = "task1-ins"
  }
}
