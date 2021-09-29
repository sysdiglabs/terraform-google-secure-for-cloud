# diagrams as code vía https://diagrams.mingrammer.com

from diagrams import Cluster, Diagram, Edge
from diagrams.gcp.analytics import PubSub
from diagrams.gcp.compute import Run
from diagrams.gcp.devtools import Code, Build, GCR
from diagrams.gcp.storage import GCS
from diagrams.gcp.security import KMS
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

with Diagram("Sysdig Secure for Cloud\n(organization)", graph_attr=diagram_attr, filename="diagram-org", show=True,
             direction="LR"):
    with Cluster("GCP account (sysdig)", graph_attr={"bgcolor": "lightblue"}):
        sds = Custom("Sysdig Secure", "../../resources/diag-sysdig-icon.png")
    with Cluster("GCP organization project", graph_attr={"bgcolor": "pink"}):
        ccProjectSink = Custom("\nCC Project\n Sink", "../../resources/sink.png")
        csProjectSink = Custom("\nCS Project\n Sink", "../../resources/sink.png")

    with Cluster("Cloud Connector (children project)"):
        ccPubSub = PubSub("CC PubSub Topic")
        ccEventarc = Code("CC Eventarc\nTrigger")
        ccCloudRun = Run("Cloud Connector")
        bucket = GCS("Bucket\nCC Config")

        bucket << Edge(style="dashed") << ccCloudRun
        ccEventarc >> ccCloudRun
        ccEventarc << ccPubSub
        ccProjectSink >> ccPubSub

    ccCloudRun >> sds
    with Cluster("Cloud Scanning (children project)"):
        keys = KMS("Sysdig \n Secure Keys")
        csPubSub = PubSub("CS PubSub Topic")
        gcrPubSub = PubSub("GCR PubSub Topic")
        csEventarc = Code("CS Eventarc\nTrigger")
        gcrEventarc = Code("GCR Eventarc\nTrigger")
        csCloudrun = Run("Cloud Scanning")
        csCloudBuild = Build("Triggered\n Cloud Builds")
        gcr = GCR("Google \n Cloud Registry")

        gcrEventarc << gcrPubSub
        csEventarc >> csCloudrun
        csEventarc << csPubSub
        csCloudrun << Edge(style="dashed") << keys
        csCloudBuild << Edge(style="dashed") << keys
        gcrEventarc >> csCloudrun
        csProjectSink >> csPubSub
        csCloudrun >> csCloudBuild
        gcr >> gcrPubSub
    csCloudBuild >> sds
