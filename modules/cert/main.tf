resource "null_resource" "script" {
  provisioner "local-exec" {
    command = "bash ${path.module}/script.sh"
  }
}

