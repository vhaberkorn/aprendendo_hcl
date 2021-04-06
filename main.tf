# O propósito principal da Hashicorp Configuration Language (HCL) é declarar recursos que representam objetos de infraestrutura.

# O código é armazenado em arquivos com a extensão .tf (exemplo: main.tf)

# Depois da versão 0.12, precisamos inicializar todo arquivo .tf com o bloco abaixo, modificando o provider de acordo
terraform {
  required_providers{
      aws = {}
  }
}

# Nesse bloco, estamos definindo o provider. O provider é um plugin que nos abilita interagir com sistemas remotos. Os providers podem ser encontrados aqui: https://registry.terraform.io/browse/providers
provider "aws" {
  region = "us-east-1"
}

# Nesse bloco estamos criando nosso primeiro recurso.
resource "aws_vpc" "main_vpc" {
    cidr_block = "10.0.0.0/16"  
}

# Data sources são informações que o provider fornece para nós.
data "aws_regions" "current" {
  
}

# Outputs são informações que queremos mostrar ao final da execução do comando terraform apply ou ao executar o comando terraform output

output "regions" {
  value = data.aws_regions.current.names
}

# Interpolação
# Usamos interpolação para criar ligar recursos.
# Neste exemplo abaixo, criamos uma instância dentro da vpc criada anteriormente

resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
  description = "Allow SSH inbound"
  
  ingress{
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress{
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "instancia" {
    ami = "ami-0742b4e673072066f"
    instance_type = "t2.micro"
    security_groups = [ aws_security_group.allow_ssh.name ]

}

