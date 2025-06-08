resource "aws_instance" "mega_project" {
  ami = data.aws_ami.ami.image_id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  key_name               = "linuxkey"
  subnet_id = aws_subnet.pub_subnet.id

  root_block_device {
    volume_size = 25
  }

  user_data = templatefile("${path.module}/../Jenkins/tool-install.sh", {})
  tags = {
    Name = "Mega_Project"
    }

}

output "instance_public_ip" {
  value = aws_instance.mega_project.public_ip
}