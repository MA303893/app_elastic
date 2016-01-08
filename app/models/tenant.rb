require 'elasticsearch'
class Tenant
  attr_accessor :name, :display_name, :id

  def self.all
    @client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]
    result = @client.search index: ELASTICSEARCH_SERVER['admin_index'].to_s, type: 'tenants'
    tenants = Array.new
    result['hits']['hits'].each do |res|
      tenant = Tenant.new
      tenant.name = res['_source']['Tenant']
      tenant.display_name = res['_source']['Name']
      tenant.id = res['_id']
      tenants << tenant
    end
    tenants
  end

  def save(params)
    @client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]
    if @client.indices.exists_type index: ELASTICSEARCH_SERVER['admin_index'], type: 'tenantseq'
      res_id = @client.index(index: ELASTICSEARCH_SERVER['admin_index'] , type: 'tenantseq' , id: 'sequence', body:{ }, refresh: true)['_version']
      result = @client.index  index: ELASTICSEARCH_SERVER['admin_index'] , type: 'tenants' , id: res_id, body: {      Name: params["display_name"], Tenant: params["name"] ,      State: 'created',DateofCreation: Time.now.strftime("%d/%m/%Y").to_s,LastUpdated: Time.now.strftime("%d/%m/%Y").to_s}
      return res_id
    else
      @client.indices.put_mapping index: ELASTICSEARCH_SERVER['admin_index'], type: 'tenantseq', body: {tenantseq: {
                                                                                                          properties:{}
                                                                                                        }
                                                                                                        }, refresh: true
      res_id = @client.index(index: ELASTICSEARCH_SERVER['admin_index'] , type: 'tenantseq' , id: 'sequence', body:{ }, refresh: true)['_version']
      result = @client.index  index: ELASTICSEARCH_SERVER['admin_index'] , type: 'tenants' , id: res_id, body: {      Name: params["display_name"], Tenant: params["name"] ,      State: 'created',DateofCreation: Time.now.strftime("%d/%m/%Y").to_s,LastUpdated: Time.now.strftime("%d/%m/%Y").to_s}
      return res_id
    end
  end

  def update(params)
    @client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]
    
  end

  def self.find(id)
    @client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]
    tenant_result = nil
    begin
      tenant_result = @client.get(index: ELASTICSEARCH_SERVER['admin_index'] , type: 'tenants' , id: id)
    rescue
    end
    if !tenant_result.nil?
      tenant = Tenant.new
      tenant.name = tenant_result['_source']['Tenant']
      tenant.display_name = tenant_result['_source']['Name']
      return tenant
    end
  end


end
