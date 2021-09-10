# copyright: 2018, The Authors

title "Organization Test}"

gcp_project_id = input("gcp_project_id")
name_prefix = input("name_prefix")
org_id = input("org_id")

cc_project_sink_name = name_prefix + "-cloud-connector-project-sink"
cc_filter = 'logName=~"/logs/cloudaudit.googleapis.com%2Factivity$" AND -resource.type="k8s_cluster"'

#controls
control "PubSub Topic" do
  impact 1.0
  title "Ensure GCP project has at least one required pub/sub topics"

  describe google_pubsub_topics(project: gcp_project_id) do
    it 'should have at least 1 topics' do
      expect(subject.count).to be >= 1
    end

    it 'should have "cloud connector" topic' do
      expect(subject.names).to include("#{name_prefix}-cloud-connector-topic")
    end

  end
end

control "Organization Sink" do
  impact 1.5
  title "Ensure there is a Organization Sink configured in the project"

  describe google_logging_organization_log_sink(organization: org_id, name: cc_project_sink_name) do
    it 'should exist' do
      expect(subject).to exist
    end
    it "filter should be #{cc_filter}" do
      expect(subject.filter).to cmp cc_filter
    end
    it "include_children should be true" do
      expect(subject.include_children).to be true
    end
  end
end
