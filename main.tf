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
data "aws_regions" "currentregions" {}

data "aws_caller_identity" "identity" {}

# Outputs
# Outputs são informações que queremos mostrar ao final da execução do comando terraform apply ou ao executar o comando terraform output
# Uma convenção é criar um arquivo separado chamado "outputs.tf" para armazenar os outputs.
output "regions" {
  value = data.aws_regions.currentregions.names
}

output "myidentity"{
  value = data.aws_caller_identity.identity
}

output "vpc_main_route_table" {
  value = aws_vpc.main_vpc.main_route_table_id
}

# Interpolação
# Usamos interpolação para criar ligar recursos.
# Neste exemplo abaixo, criamos um security group e interpolamos o nome dele para a criação de uma instância.

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
    #ami = var.ami_id
    instance_type = "t2.micro" 
    security_groups = [ aws_security_group.allow_ssh.name ]
}

resource "aws_s3_bucket" "bucket0" {
  bucket = "${data.aws_caller_identity.identity.account_id}-bucket0"
}

# Dependências

resource "aws_s3_bucket" "bucket1" {
  tags = {
    "dependencia" = aws_s3_bucket.bucket2.arn
  }
}

resource "aws_s3_bucket" "bucket2" {
}


# Variáveis
# Diferente de outras linguagens de programação, no HCL usamos variáveis para pegar inputs do usuário 
# Uma convenção é criar um arquivo separado chamado "variable.tf" para armazenar as variáveis utilizadas.
variable "ami_id"{
  type = string
}

# Locals
# locals são como alias. Usamos isso para não precisarmos repetir uma expressão que aparece bastante no nosso código.

locals {
  name = "aprendendohcl"
}

resource "aws_s3_bucket" "bucket3" {
  bucket =  local.name
}
