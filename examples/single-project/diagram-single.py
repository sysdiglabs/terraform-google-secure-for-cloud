# diagrams as code vía https://diagrams.mingrammer.com
from diagrams import Cluster, Diagram, Edge
from diagrams.gcp.analytics import PubSub
from diagrams.gcp.compute import Run
from diagrams.gcp.devtools import Code, Build, GCR
from diagrams.gcp.storage import GCS
from diagrams.gcp.security import KMS, Iam
from diagrams.custom import Custom
from diagrams.gcp.network import TrafficDirector

diagram_attr = {
    "pad": "0.25"
}

role_attr = {
    "imagescale": "false",
    "height": "1.5",
    "width": "3",
    "fontsize": "9",
}

color_event = "firebrick"
color_scanning = "dark-green"
color_permission = "red"
color_non_important = "gray"
color_sysdig = "lightblue"

with Diagram("Sysdig Secure for Cloud\n(single project)", graph_attr=diagram_attr, filename="diagram-single", show=True,
             direction="TB"):
    with Cluster("GCP account (sysdig)"):
        sds = Custom("Sysdig Secure", "../../resources/diag-sysdig-icon.png")
        bench = Code("Cloud Bench")

        sds >> Edge(label="schedule on 0 6 * * *") >> bench

    with Cluster("GCP project"):
        with Cluster("Secure for Cloud"):
            ccBenchRole = Iam("Cloud Bench Role")
            ccProjectSink = Custom("\nLog Router\n Sink", "../../resources/sink.png")
            ccPubSub = PubSub("CC PubSub Topic")
            ccEventarc = Code("CloudRun\n Eventarc Trigger")
            ccCloudRun = Run("Cloud Connector")
            bucket = GCS("Bucket\nCC Config")

            bucket << Edge(style="dashed", label="Get CC config file") << ccCloudRun
            ccEventarc >> ccCloudRun
            ccEventarc << ccPubSub
            ccProjectSink >> ccPubSub

            ccCloudRun >> sds
            keys = KMS("Sysdig Keys")
            gcrPubSub = PubSub("GCR PubSub Topic")
            csEventarc = Code("CS Eventarc\nTrigger")
            gcrSubscription = Code("GCR PubSub\nSubscription")
            csCloudBuild = Build("Triggered\n Cloud Builds")
            gcr = GCR("Google \n Cloud Registry")

            gcrSubscription << gcrPubSub
            csEventarc >> ccCloudRun
            ccCloudRun << keys
            csCloudBuild << keys
            gcrSubscription >> ccCloudRun
            ccCloudRun >> csCloudBuild
            gcr >> gcrPubSub
            csCloudBuild >> sds
    ccBenchRole << bench
