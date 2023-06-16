// https://pfertyk.me/2023/02/creating-aws-lambda-functions-with-terraform/                 // archive part
// https://levelup.gitconnected.com/manage-your-aws-lambda-layers-with-iac-4094e75f5ae8     // version       
resource "aws_lambda_layer_version" "my_custom_layer" {
  filename   = "./terraform/common-lambda-layer/common-lambda-layer.zip"
  layer_name = "common-lambda-layer"
  source_code_hash = filebase64sha256("./terraform/common-lambda-layer/common-lambda-layer.zip")
  compatible_runtimes = ["nodejs14.x", "nodejs12.x"]
}


// first manually create ./terraform/common-lambda-layer/common-lambda-layer.zip locally in your pc
data "archive_file" "layer" {
  type        = "zip"
  source_dir  = "./terraform/common-lambda-layer"
  output_path = "./terraform/common-lambda-layer/common-lambda-layer.zip"
}
