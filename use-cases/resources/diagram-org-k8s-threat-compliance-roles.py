# diagrams as code vía https://diagrams.mingrammer.com
from diagrams import Diagram, Cluster
from diagrams.gcp.security import Iam
from diagrams.custom import Custom

diagram_attr = {
    "pad": "0.25",
}

color_event = "firebrick"
color_scanning = "dark-green"
color_permission = "red"
color_non_important = "gray"
color_sysdig = "lightblue"

with Diagram("Role", graph_attr=diagram_attr, filename="diagram-org-k8s-threat-compliance-roles", show=True, direction="TB"):

    with Cluster("", graph_attr={"bgcolor": "lightblue"}):
        serviceAccount = Iam("Service Account")
        sysdigCloudBenchmarkRole = Iam("Sysdig Cloud \n Benchmark Role \n [storage.buckets.getIamPolicy, \n bigquery.tables.list]")
        roleViewer = Iam("roles/viewer")

        serviceAccount << sysdigCloudBenchmarkRole
        serviceAccount << roleViewer
