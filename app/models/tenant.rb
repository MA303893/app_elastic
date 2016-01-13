require 'elasticsearch'

class Tenant

  attr_accessor :name, :display_name, :id, :created_at, :updated_at


  def self.all
    @client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]
    result = @client.search index: ELASTICSEARCH_SERVER['admin_index'].to_s, type: 'tenants', body:{size: 99999999}
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

  def update(params,id)
    @client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]
    result =  @client.update index: ELASTICSEARCH_SERVER['admin_index'], type: 'tenants', id: id, body:{
      doc:{
        Name: params["display_name"], Tenant: params["name"], LastUpdated: Time.now.strftime("%d/%m/%Y").to_s
      }
    }, refresh: true
    Tenant.find(result['_id'])

  end

  def destroy
    @client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]
    @client.delete index: ELASTICSEARCH_SERVER['admin_index'], type: 'tenants', id: self.id
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
      tenant.id = tenant_result['_id']
      tenant.created_at = tenant_result['_source']['DateofCreation']
      tenant.updated_at = tenant_result['_source']['LastUpdated']
      return tenant
    end
  end

  def subscriptions
    @client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]
    subscription_result = @client.search index: ELASTICSEARCH_SERVER['admin_index'].to_s, type: 'subscriptions', body:{
      size: 99999999,
      query:{
        filtered:{
          query:{
            match:{
              Tenant_id:{
                query: @id, type: "phrase"
              }
            }
          }
        }
      }
    }
    subscriptions = Array.new
    subscription_result['hits']['hits'].each do |res|
      subscription =  Subscription.new
      subscription.name = res['_source']['Subscription']
      subscription.display_name = res['_source']['Name']
      subscription.id = res['_id']
      subscription.budget = res['_source']['Budget']
      subscription.tenant_id = res['_source']['Tenant_id']
      subscription.created_at = res['_source']['DateofCreation']
      subscription.updated_at = res['_source']['LastUpdated']
      subscriptions << subscription
    end
    subscriptions
  end


end
