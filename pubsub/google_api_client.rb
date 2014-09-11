class GoogleApiClient


  def initialize(opts={})
    @authorization = nil
    @api = nil
    #these will be injected into this object as attr_accessor
    @opts          =HashParams.new(opts) do
      #mandatory
      param :application_name, required: true
      param :application_version, required: true

      param :log_level, default: Logger::Severity::WARN
      #optional
      param :cache_timeout_in_seconds, coerse: Integer, :default => 60 * 60
      param :cache_directory, default: '/tmp'
      param :debug, default: false

      #these can be passed in in order to save the extra call to authorize
      param :scope, default: 'https://www.googleapis.com/auth/cloud-platform'
      param :service_email
      param :key_path
      #if these are passed in it will automatically discover the api
      param :api_name
      param :api_version
    end


    @raw_client = Google::APIClient.new(
        application_name:    @opts[:application_name],
        application_version: @opts[:application_version]
    )

    @raw_client.logger.level = Logger::Severity::DEBUG
    #if they passed in authorisation opts then do it
    if @opts[:scope] && @opts[:service_email] && @opts[:key_path]
      authorise @opts[:scope], @opts[:service_email], @opts[:key_path] , true
    end

    #if api is specified then discover it
    if @opts[:api_name] && @opts[:api_version]
      discover(@opts[:api_name] ,  @opts[:api_version])
    end
  end

  def authorised?
    @authorization.nil?
  end

  alias_method :authorized?, :authorised?

  def authorise(scope=@opts[:scope], service_email=@opts[:service_email], key_path=@opts[:key_path], force = false)
    #memoize unless forced
    return @authorization if (@authorization  && !force )
    key = Google::APIClient::PKCS12.load_key(File.open(key_path, mode: 'rb'), 'notasecret')

    asserter       = Google::APIClient::JWTAsserter.new(
        service_email,
        scope,
        key
    )
    @authorization = @raw_client.authorization = asserter.authorize
  end

  alias_method :authorize, :authorise

  def discover(api, version, cache_timeout=nil)
    cache_timeout ||= @opts[:cache_timeout_in_seconds]
    filename      = File.join(@opts[:cache_directory], "discovered_google_api_#{api}_#{version}.json")

    cache_valid     = File.exists?(filename) && (Time.now - File.ctime(filename)) < cache_timeout
    cached_document = File.read(filename) if cache_valid
    #   this will register a previously discovered document with the client
    #    it eliminates a needless http request
    @raw_client.register_discovery_document(api, version, cached_document) if cached_document
    #   #this call will only initiatiate an http response if the discovery document is missing
    @api = @raw_client.discovered_api(api, version)
    #
    #   #if there was no cached document write one.
    File.write(filename, @api.discovery_document.to_json) unless cache_valid

    # return the discovered_api
    @api
  end

  def cached_call(cache_key, cache_timeout=nil)
    cache_timeout ||= @opts[:cache_timeout_in_seconds]
    filename      = File.join(@opts[:cache_directory].to_s, "#{@opts[:application_name].to_s}_#{@opts[:application_version].to_s}_#{cache_key.to_s}.cache.marshal")
    cache_valid   = File.exists?(filename) && (Time.now - File.ctime(filename)) < cache_timeout
    if cache_valid
      Marshal.load(File.read(filename))
    else
      result = yield(self) if block_given?
      File.write(filename, Marshal.dump(result))
      result
    end
  end

  # Generic API call
  def execute(api_method, parameters={}, body_object ={}, opts={})


    method= @api.instance_eval(api_method)

    #project id is not required for all calls to all APIs but it is required for a ton of them
    #this  is a convinient way to put it put it in

    project_id              = parameters.delete(:projectId) ||
        parameters.delete('projectId') ||
        parameters.delete(:project_id) ||
        parameters.delete('project_id') ||
        @opts[:project_id]

    parameters['projectId'] = project_id if project_id

    h               = {:api_method => method, :parameters => parameters}
    h[:body_object] = body_object unless body_object.empty?
    h.merge.opts unless opts.empty?
    raw_execute h
  end
  alias_method :call, :execute

  #delegated methods to @raw_client
  def raw_execute(*params)
    r=@raw_client.execute(*params)
    raise r.error_message if r.error?

    #Not sure if this is a special case or not but better to be more specific
    empty_body_returns=['pubsub.topics.publish', 'pubsub.subscriptions.acknowledge']
    return true if empty_body_returns.include?(r.request.api_method.id) && r.body.empty?

    JSON.parse(r.body)


  end
end
