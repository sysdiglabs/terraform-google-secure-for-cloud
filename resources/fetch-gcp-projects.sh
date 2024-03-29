#!/bin/bash

#
# usage
# ./fetch-gcp-projects.sh <ORG-ID>

# will return
# ["A", "B", "C"]
#


#
# Function to list projects under a folder recursively
#
list_projects_recursive() {
  local folder_id="$1"

  # List projects under the current folder
  printf " %s" $(gcloud projects list --filter="parent.id=$folder_id" --format="value(projectId)")

  # List subfolders and call this function recursively
  local subfolders=$(gcloud resource-manager folders list --folder=$folder_id --format="value(name)")
  for subfolder in $subfolders; do
    list_projects_recursive "$subfolder"
  done
}



#
# main flow
#

if [ $# -ne 1 ]; then
  echo "script must be launched with the organization id"
  echo "usage $0 organizationId"
  exit 1
fi


org_id=$1
projectIds=()
projectIds+=$(gcloud projects list --filter="parent.type=organization AND parent.id=$org_id" --format="value(projectId)")

# List top-level folders
folders=$(gcloud resource-manager folders list --organization=$org_id --format="value(name)")

# Iterate through the top-level folders and list projects recursively
for folder in $folders; do
  projectIds+=$(list_projects_recursive "$folder")
done

projectList="["

for value in $projectIds; do
  projectList="$projectList\"$value\", "
done

# Remove the trailing comma and space
projectList="${projectList%, }]"

echo $projectList
