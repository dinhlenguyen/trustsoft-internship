resource "aws_config_config_rule" "required_tags" {
  name = "required-tags-internship-dinh"
  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }

  scope {
    compliance_resource_types = ["AWS::EC2::Instance"]
  }

  input_parameters = jsonencode({
    tag1Key = "Name"
    tag2Key = "Environment"
  })

  description = "Checks whether the required tags are applied to EC2 instances."
}
