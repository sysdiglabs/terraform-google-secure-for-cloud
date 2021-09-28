# diagrams as code vía https://diagrams.mingrammer.com

from diagrams import Cluster, Diagram
from diagrams.gcp.security import Iam
from diagrams.gcp.analytics import PubSub
from diagrams.gcp.compute import Run
from diagrams.gcp.devtools import Code
from diagrams.gcp.storage import GCS
from diagrams.gcp.security import KMS
from diagrams.custom import Custom

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
             direction="LR"):
    with Cluster("AWS account (sysdig)"):
        sds = Custom("Sysdig Secure", "../../resources/diag-sysdig-icon.png")

    with Cluster("GCP project"):
        with Cluster("Cloud Connector"):
            ccPubSub = PubSub("CC PubSub Topic")
            ccCloudrun = Run("Cloud Connector")
            cceventarc = Code("CC Eventarc\nTrigger")

            bucket = GCS("Bucket")

            bucket << ccCloudrun
            cceventarc >> ccCloudrun
            cceventarc >> ccPubSub

        ccCloudrun >> sds
        with Cluster("Cloud Scanning"):
            keys = KMS("Sysdig Keys")
            csPubSub = PubSub("CS PubSub Topic")
            gcrPubSub = PubSub("GCR PubSub Topic")
            gcrEventarc = Code("GCR Eventarc\nTrigger")

            gcrEventarc >> gcrPubSub

            csCloudrun = Run("Cloud Scanning")
            csEventarc = Code("CS Eventarc\nTrigger")

            csEventarc >> csCloudrun
            csEventarc >> csPubSub
            csCloudrun << keys

            gcrEventarc >> csCloudrun
        csCloudrun >> sds
