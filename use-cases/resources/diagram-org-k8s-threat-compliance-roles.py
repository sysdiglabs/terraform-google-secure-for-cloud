# diagrams as code vía https://diagrams.mingrammer.com
from diagrams import Diagram, Cluster
from diagrams.gcp.security import Iam

diagram_attr = {
    "pad": "0.25",
}

color_event = "firebrick"
color_scanning = "dark-green"
color_permission = "red"
color_non_important = "gray"
color_sysdig = "lightblue"

with Diagram("Roles", graph_attr=diagram_attr, filename="diagram-org-k8s-threat-compliance-roles", show=True, direction="TB"):

    with Cluster("Role", graph_attr={"bgcolor": "lightblue"}):
        serviceAccount = Iam("Service Account")
        sysdigCloudBenchmarkRole = Iam("Sysdig Cloud \n Benchmark Role")
        roleViewer = Iam("roles/viewer")

        serviceAccount << sysdigCloudBenchmarkRole
        serviceAccount << roleViewer
