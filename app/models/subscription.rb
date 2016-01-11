class Subscription

  attr_accessor :name, :display_name, :id, :created_at, :updated_at, :tenant_id, :budget
  cattr_accessor :client 
  @@client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]

   def self.all(tenant_id)
  	result = @@client.search index: ELASTICSEARCH_SERVER['admin_index'].to_s, type: 'subscriptions', body:{size: 99999999}
    subscriptions = Array.new
    result['hits']['hits'].each do |res|
      subscription = Subscription.new
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

  def save(params)
    if @@client.indices.exists_type index: ELASTICSEARCH_SERVER['admin_index'], type: 'subscriptionseq'
      res_id = @@client.index(index: ELASTICSEARCH_SERVER['admin_index'] , type: 'subscriptionseq' , id: 'sequence', body:{ }, refresh: true)['_version']
      result = @@client.index  index: ELASTICSEARCH_SERVER['admin_index'] , type: 'subscriptions' , id: res_id, body: {      Name: params["display_name"], Tenant: params["name"] ,      State: 'created',DateofCreation: Time.now.strftime("%d/%m/%Y").to_s,LastUpdated: Time.now.strftime("%d/%m/%Y").to_s}
      return res_id
    else
      @@client.indices.put_mapping index: ELASTICSEARCH_SERVER['admin_index'], type: 'subscriptionseq', body: {tenantseq: {
                                                                                                          properties:{}
                                                                                                        }
                                                                                                        }, refresh: true
      res_id = @@client.index(index: ELASTICSEARCH_SERVER['admin_index'] , type: 'subscriptionseq' , id: 'sequence', body:{ }, refresh: true)['_version']
      result = @@client.index  index: ELASTICSEARCH_SERVER['admin_index'] , type: 'subscriptions' , id: res_id, body: {      Name: params["display_name"], Tenant: params["name"] ,      State: 'created',DateofCreation: Time.now.strftime("%d/%m/%Y").to_s,LastUpdated: Time.now.strftime("%d/%m/%Y").to_s}
      return res_id
    end
  end

  def tenant
  	@tenant = Tenant.new
  	#find tenant with subscriptions's tenant_id
  	tenant_result = @@client.get(index: ELASTICSEARCH_SERVER['admin_index'] , type: 'tenants' , id: @tenant_id)
  	@tenant.name = tenant_result['_source']['Tenant']
  	@tenant.display_name = tenant_result['_source']['Name']
  	@tenant.id = @tenant_id
  	@tenant.created_at = tenant_result['_source']["DateofCreation"]
  	@tenant.updated_at = tenant_result['_source']['LastUpdated']
  	@tenant
  end


end
