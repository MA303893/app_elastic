class Blueprint
  attr_accessor :name, :display_name, :id, :created_at, :updated_at, :tenant, :subscription_id, :subscription
  @@client = Elasticsearch::Client.new host: [ { host: ELASTICSEARCH_SERVER['ip'].to_s , port: ELASTICSEARCH_SERVER['port'].to_s } ]

  def self.all
    result = @@client.search index: ELASTICSEARCH_SERVER['admin_index'].to_s, type: 'blueprints', body:{size: 99999999}
    blueprints = Array.new
    result['hits']['hits'].each do |res|
      blueprint = Blueprint.new
      blueprint.name = res['_source']['Blueprint']
      blueprint.display_name = res['_source']['Name']
      blueprint.id = res['_id']
      blueprint.tenant = res['_source']['Tenant']
      blueprint.created_at = res['_source']['DateofCreation']
      blueprint.updated_at = res['_source']['LastUpdated']
      blueprint.subscription_id = res['_source']['Subscription_id']
      blueprint.subscription = res['_source']['Subscription']

      blueprints << blueprint
    end
    blueprints
  end

  def save(params)
    subscription = Subscription.find(params["subscription_id"])
    if @@client.indices.exists_type index: ELASTICSEARCH_SERVER['admin_index'], type: 'blueprintseq'
      res_id = @@client.index(index: ELASTICSEARCH_SERVER['admin_index'] , type: 'blueprintseq' , id: 'sequence', body:{ }, refresh: true)['_version']
      result = @@client.index  index: ELASTICSEARCH_SERVER['admin_index'] , type: 'blueprints' , id: res_id, body: {
        Name: params["display_name"], Tenant: subscription.tenant.name , Subscription_id: params['subscription_id'],
        Subscription: subscription.name, Provider: 'aws', Blueprint: params['name'],
        State: 'created',DateofCreation: Time.now.strftime("%d/%m/%Y").to_s,LastUpdated: Time.now.strftime("%d/%m/%Y").to_s
      }
      return res_id
    else
      @@client.indices.put_mapping index: ELASTICSEARCH_SERVER['admin_index'], type: 'blueprintseq', body: {
        blueprintseq: {
          properties:{}
        }
      }
      res_id = @@client.index(index: ELASTICSEARCH_SERVER['admin_index'] , type: 'blueprintseq' , id: 'sequence', body:{ }, refresh: true)['_version']
      result = @@client.index  index: ELASTICSEARCH_SERVER['admin_index'] , type: 'blueprints' , id: res_id, body: {
        Name: params["display_name"], Tenant: subscription.tenant.name , Subscription_id: params['subscription_id'],
        Subscription: subscription.name, Provider: 'aws', Blueprint: params['name'],
        State: 'created',DateofCreation: Time.now.strftime("%d/%m/%Y").to_s,LastUpdated: Time.now.strftime("%d/%m/%Y").to_s
      }
      return res_id
    end
  end
  def self.find(id)
    blueprint_result = nil
    begin
      blueprint_result = @@client.get(index: ELASTICSEARCH_SERVER['admin_index'] , type: 'blueprints' , id: id)
    rescue
    end
    if !blueprint_result.nil?
      blueprint = Blueprint.new
      blueprint.name = blueprint_result['_source']['Blueprint']
      blueprint.display_name = blueprint_result['_source']['Name']
      blueprint.id = blueprint_result['_id']
      blueprint.created_at = blueprint_result['_source']['DateofCreation']
      blueprint.updated_at = blueprint_result['_source']['LastUpdated']
      blueprint.subscription_id = blueprint_result['_source']['Subscription_id']
      blueprint.tenant = blueprint_result['_source']['Tenant']
      blueprint.subscription = blueprint_result['_source']['Subscription']
      return blueprint
    end
  end

  def update(params,id)
    result =  @@client.update index: ELASTICSEARCH_SERVER['admin_index'], type: 'blueprints', id: id, body:{
      doc:{
        Name: params["display_name"], Blueprint: params["name"], LastUpdated: Time.now.strftime("%d/%m/%Y").to_s
      }
    }, refresh: true
    Blueprint.find(result['_id'])
  end

  def destroy
  	@@client.delete index: ELASTICSEARCH_SERVER['admin_index'], type: 'blueprints', id: self.id
  end

end
