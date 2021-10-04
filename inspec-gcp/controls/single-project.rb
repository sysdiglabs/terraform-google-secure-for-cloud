# copyright: 2018, The Authors

title "Single Project Test"

gcp_project_id = input("gcp_project_id")
name_prefix = input("name_prefix")
cc_project_sink_name = name_prefix + "-cloud-connector-project-sink"
cs_project_sink_name = name_prefix + "-cloud-scanning-project-sink"
cc_filter = 'logName=~"^projects/' + gcp_project_id + '/logs/cloudaudit.googleapis.com" AND -resource.type="k8s_cluster"'
cs_filter = 'protoPayload.methodName = "google.cloud.run.v1.Services.CreateService" OR protoPayload.methodName = "google.cloud.run.v1.Services.ReplaceService"'

#controls
control "Cloud Connector PubSub Topic" do
  impact 1.0
  title "Ensure GCP project has at least three required pub/sub topics"

  describe google_pubsub_topics(project: gcp_project_id) do
    it 'should have at least 3 topics' do
      expect(subject.count).to be >= 3
    end

    it 'should have "gcr" topic' do
      expect(subject.names).to include('gcr')
    end

    it 'should have "cloud connector" topic' do
      expect(subject.names).to include("#{name_prefix}-cloud-connector-topic")
    end

    it 'should have "cloud scanning" topic' do
      expect(subject.names).to include("#{name_prefix}-cloud-scanning-topic")
    end

  end
end

control "Cloud Connector project sink" do
  impact 1.5
  title "Ensure there is two Project Sink configured in the project for cloud connector"

  describe google_logging_project_sink(project: gcp_project_id, name: cc_project_sink_name) do
    it 'should exist' do
      expect(subject).to exist
    end
    it "filter should be #{cc_filter}" do
      expect(subject.filter).to cmp cc_filter
    end
  end
end

control "Cloud Scanning project sink" do
  impact 1.5
  title "Ensure there is two Project Sink configured in the project for cloud scanning"
  describe google_logging_project_sink(project: gcp_project_id, name: cs_project_sink_name) do
    it 'should exist' do
      expect(subject).to exist
    end
    it "filter should be #{cs_filter}" do
      expect(subject.filter).to cmp cs_filter
    end
  end
end
