data "google_projects" "all_active_projects" {
  filter = "parent.id:${var.org_id} -lifecycleState:DELETE_REQUESTED"
}

resource "null_resource" "provisioner" {
  count = length(data.google_projects.all_active_projects.projects)

  triggers = {
    project_id = data.google_projects.all_active_projects.projects[count.index].project_id
  }

  provisioner "local-exec" {
    command    = "gcloud pubsub topics create gcr --project=${self.triggers.project_id}"
    on_failure = continue
  }

  provisioner "local-exec" {
    command    = "gcloud pubsub topics delete gcr --project=${self.triggers.project_id}"
    on_failure = continue
    when       = destroy
  }
}
