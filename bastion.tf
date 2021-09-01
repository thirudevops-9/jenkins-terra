resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description      = "ssh from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.envname}-bastion-sg"
  }
}

  



#key_pair
resource "aws_key_pair" "dev" {
  key_name   = "dev"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJBrJKs1teA9+OJ57jt5wlev0wgnspDQQAD1SDqOztJuyLOFxbCjJVAeEPJ5EGSomW98D9kA6zlCh2CKc+u8Lt5AxMmy8fub7Z/7+Teg46gznR5/T5w+Sr4l+IA+J9HeUX0wxsyq5RHiS8FUfebfvJnOBh5f0BDf1jL62Cpv5JZuWV04m2/PEaNSmboAHgxNpIXcd06NQDWaRc2v5Rbn7tQFrpwnRS8ecFXAqwxA6SFvjhetlqwTR64UMbrhZxZR+syOVcKPDgNctpIUoaIPTWGz0gRJrNrZUWayt0xjxIDk6GCrdpGQDlKkxf0406KoHX8PYaehQMhpdmTVAn0cul prasad@prasad-HP-ProBook-450-G2"
  }
#user_data
data "template_file" "bastion" {
  template = "${file("rds.sh")}"

}

#ec2
resource "aws_instance" "bastion" {
  ami           = var.ami
  instance_type = var.type
  key_name = aws_key_pair.dev.id
  subnet_id = aws_subnet.public[0].id
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
  user_data = data.template_file.bastion.rendered
  tags = {
    Name = "${var.envname}-bastion"
  }
}
