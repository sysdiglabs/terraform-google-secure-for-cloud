# diagrams as code vía https://diagrams.mingrammer.com

from diagrams.aws.general import General
from diagrams import Cluster, Diagram, Edge
from diagrams.gcp.analytics import PubSub
from diagrams.gcp.compute import Run
from diagrams.gcp.devtools import Code, Build, GCR
from diagrams.gcp.storage import GCS
from diagrams.gcp.security import KMS, Iam
from diagrams.gcp.network import TrafficDirector
from diagrams.custom import Custom

diagram_attr = {
    "pad": "0.25",
}

color_event = "firebrick"
color_scanning = "dark-green"
color_permission = "red"
color_non_important = "gray"
color_sysdig = "lightblue"

with Diagram("Sysdig Secure for Cloud\n(organization)", graph_attr=diagram_attr, filename="diagram-org", show=True, direction="TB"):

    public_registries = Custom("Public Registries","../../resources/diag-registry-icon.png")

    with Cluster("GCP account (sysdig)", graph_attr={"bgcolor": "lightblue"}):
        sds = Custom("Sysdig Secure", "../../resources/diag-sysdig-icon.png")
        bench = General("Cloud Bench")
        sds >> Edge(label="schedule on rand rand * * *") >> bench

    with Cluster("GCP organization project", graph_attr={"bgcolor": "pink"}):
        ccProjectSink = Custom("\nLog Router \n Sink", "../../resources/sink.png")
        orgBenchRole = Iam("Cloud Bench Role")

    with Cluster("Secure for Cloud (children project)"):
        ccBenchRole = Iam("Cloud Bench Role")
        ccPubSub = PubSub("CC PubSub Topic")
        ccEventarc = Code("CloudRun\nEventarc Trigger")
        ccCloudRun = Run("Cloud Connector")
        keys = KMS("Sysdig \n Secure Keys")

        ccCloudRun << Edge(style="dashed") << keys
        ccEventarc >> ccCloudRun
        ccEventarc << ccPubSub
        ccProjectSink >> ccPubSub

        gcrPubSub = PubSub("GCR PubSub Topic\n(gcr named)")
        gcrSubscription = Code("GCR PubSub\nSubscription")
        csCloudBuild = Build("Triggered\n Cloud Builds")
        gcr = GCR("Google \n Cloud Registry")

        gcrSubscription >> ccCloudRun
        ccCloudRun >> csCloudBuild
        gcrSubscription << gcrPubSub
        csCloudBuild << Edge(style="dashed") << keys
        gcr >> gcrPubSub

        # scanning
        ccCloudRun >> Edge(color=color_non_important) >> gcr
        ccCloudRun >> Edge(color=color_non_important) >> public_registries

    csCloudBuild >> sds
    ccCloudRun >> sds

    ccBenchRole <<  Edge(color=color_non_important) <<  bench
    orgBenchRole <<  Edge(color=color_non_important) <<  bench
