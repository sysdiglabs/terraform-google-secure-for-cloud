# diagrams as code vía https://diagrams.mingrammer.com
from diagrams.aws.general import General
from diagrams import Cluster, Diagram, Edge
from diagrams.gcp.analytics import PubSub
from diagrams.gcp.security import Iam
from diagrams.gcp.compute import GKE
from diagrams.custom import Custom

diagram_attr = {
    "pad": "0.25",
}

color_event = "firebrick"
color_scanning = "dark-green"
color_permission = "red"
color_non_important = "gray"
color_sysdig = "lightblue"

with Diagram("Sysdig Secure for Cloud\n(organization)", graph_attr=diagram_attr, filename="diagram-k8s-only", show=True, direction="TB"):

    with Cluster("GCP account (sysdig)", graph_attr={"bgcolor": "lightblue"}):
        sds = Custom("Sysdig Secure", "../resources/diag-sysdig-icon.png")
        bench = General("Cloud Bench")
        sds >> Edge(label="schedule on rand rand * * *") >> bench

    with Cluster("GCP organization", graph_attr={"bgcolor": "pink"}):
        ccProjectSink = Custom("\nLog Router \n Sink", "../resources/sink.png")

        with Cluster("Secure for Cloud (children project)"):
            ccBenchRole = Iam("Cloud Bench Role")
            ccPubSub = PubSub("CC PubSub Topic")
            ccOnK8s = GKE("CC on k8s")

            ccProjectSink >> ccPubSub
            ccOnK8s >> ccPubSub

            ccOnK8s >> sds

            ccBenchRole <<  Edge(color=color_non_important) <<  bench

        with Cluster("Rest of the projects"):
            ccBenchRoleOnEachProject = Iam("Cloud Bench Role")
            bench >> ccBenchRoleOnEachProject
