
ELASTICSEARCH_SERVER = {
  "ip" => "10.220.3.40",
  "port" => "9200",
  "shards" => "2",
  "replicas" => "2",
  "admin_index" => "stupid_admin"
}

LOGSTASH_SERVER = {
  "ip" => "10.220.0.152",
  "server_path_download" => "/app/logstash-1.5.0/conf/logstash.conf",
  "rails_path_download" => "/home/ec2-user/rails/rails/",
  "server_path_upload" => "/app/logstash-1.5.0/conf",
  "rails_path_upload" => "/home/ec2-user/rails/rails/logstash.conf",
  "username" => "root",
  "keys_path" => "/home/ec2-user/rails/rails/VS_Key.pem"
}