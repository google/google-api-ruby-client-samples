#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'google/api_client'
require 'json'
require 'yaml'
require 'hash_params'
require 'pry'
require 'base64'

require_relative 'google_api_client'


class PubSubTopic
  def initialize(client, topic_name)
    @client    = client
    @topic_name=topic_name
  end

  def subscription_list
  end

  def list
    r= @client.execute('topics.list', {'query' => "cloud.googleapis.com/project in (/projects/#{@project_id})"})
    r['topic'].map { |t| t['name'].split('/')[-1] }
  end

  def find_or_create(topic_name)
    topics = topic_list
    create_topic(topic_name) unless topics.include?(topic_name)
  end
end

class PubSub

  def initialize(client, project_id)
    @client     =client
    @project_id = project_id
    @client.discover('pubsub', 'v1beta1')
  end

  def topic_list
    r= @client.execute('topics.list', {'query' => "cloud.googleapis.com/project in (/projects/#{@project_id})"})
    r['topic'].map { |t| t['name'].split('/')[-1] }
  end

  def subscription_list(topic_name = nil)
    s= if topic_name
         "pubsub.googleapis.com/topic in (/topics/#{@project_id}/#{topic_name})"
       else
         "cloud.googleapis.com/project in (/projects/#{@project_id})"
       end

    r = @client.execute('subscriptions.list', {"query" => s})
    r['subscription'].map { |t| t['name'].split('/')[-1] }
  end

  def find_or_create_topic(topic_name)
    topics = topic_list
    create_topic(topic_name) unless topics.include?(topic_name)
  end

  def create_topic(topic_name)
    @client.execute 'topics.create', {}, topic_resource(topic_name)
  end

  def get_topic(topic_name)
    @client.execute('topics.get', {"topic" => topic_path(topic_name)})
  end

  def get_subscription(subscription_name)
    @client.execute('subscriptions.get', {"subscription" => subscription_path(subscription_name)})
  end


  def publish(topic_name, data, labels=nil)
    #Message payloads should be Base64-encoded, and can be a maximum of 7 MB before encoding.
    #  (The client libraries provide methods for Base64-encoding data.)


    h                     = {
        "topic"   => topic_path(topic_name),
        "message" => {
            "data" => Base64.encode64(data)
        }
    }
    h["message"]["label"] = Array(labels) if labels
    @client.execute('topics.publish', {}, h)

  end

  def create_subscription(topic_name, subscription_name, ack_deadline_in_seconds, push_endpoint=nil)
    body               = {
        "name"               => subscription_path(subscription_name),
        "topic"              => topic_path(topic_name),

        "ackDeadlineSeconds" => ack_deadline_in_seconds
    }
    body["pushConfig"] = {"pushEndpoint" => push_endpoint} if push_endpoint

    @client.execute('subscriptions.create', {}, body)
  end

  def find_or_create_subscription(topic_name, subscription_name, ack_deadline_in_seconds, push_endpoint=nil)
    subs=subscription_list(topic_name)
    create_subscription(topic_name, subscription_name, 600) unless subs.include?(subscription_name)
  end

  def pull_from_subscription(subscription_name, return_immediately = true)
    #returns an array with key and data
    body = {"subscription" => subscription_path(subscription_name), "returnImmediately" => return_immediately}
    r    = @client.execute('subscriptions.pull', {}, body)
    [r['ackId'], Base64.decode64(r['pubsubEvent']['message']['data'])]

  end

  def acknowledge(subscription_name, ack_id)
    #this API takes an array in the ackid but the documentation says it's a single id
    body= {
        "subscription" => subscription_path(subscription_name),
        "ackId"        => Array(ack_id)
    }
    @client.execute('subscriptions.acknowledge', {}, body)
  end

  private
  def topic_path(topic_name)
    "/topics/#{@project_id}/#{topic_name}"
  end

  def subscription_path(subscription_name)
    "/subscriptions/#{@project_id}/#{subscription_name}"
  end

  def topic_resource(topic_name)
    {"name" => topic_path}
  end

end


if __FILE__ == $0
  config = YAML::load_file(File.join(__dir__, 'pubsub.local.yml'))
  client = GoogleApiClient.new(config)
  @pubsub=PubSub.new(client, config['project_id'])


  topic_name        = 'test-topic'
  subscription_name = 'test-subscription'

  @pubsub.find_or_create_topic(topic_name)
  @pubsub.find_or_create_subscription(topic_name, subscription_name, 600)


  response = @pubsub.publish('test-topic', "This is a message posted to test_topic")

  10.times do
    ack_id, data = @pubsub.pull_from_subscription('test-subscription')
    ack          = @pubsub.acknowledge(subscription_name, ack_id)
  end

end

