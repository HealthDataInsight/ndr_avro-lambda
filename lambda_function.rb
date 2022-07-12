require 'rubygems'
require 'bundler/setup'

# require 'aws-sdk-lambda'
require 'json'
require 'logger'
require 'ndr_avro'
require 'open-uri'
require_relative 'safe_dir'

# $client = Aws::Lambda::Client.new()
# $client.get_account_settings()

# require 'aws-xray-sdk/lambda'

# Configure SafePath
SafePath.configure!(File.join('.', 'filesystem_paths.yml'))

# Main class containing the entry point class method LambdaFunction.process
class LambdaFunction
  VERSION = '0.1.0'.freeze

  def self.process(event:, context:)
    logger = Logger.new($stdout)
    # logger.info('## ENVIRONMENT VARIABLES')
    # vars = Hash.new
    # ENV.each do |variable|
    #   vars[variable[0]] = variable[1]
    # end
    # logger.info(vars.to_json)
    logger.info('## EVENT')
    logger.info(event.to_json)
    # logger.info('## CONTEXT')
    # logger.info(context)

    # Set object details
    t0 = Time.current

    s3_event_hash = event['Records'].first['s3']
    input_bucket = s3_event_hash['bucket']['name']
    # input_bucket = s3_event_hash['bucket']['arn']
    object_key = s3_event_hash['object']['key']

    output_bucket = ENV['OUTPUT_BUCKET_NAME']
    mappings = URI.parse(ENV['MAPPING_URL']).read
    # logger.info('## MAPPING_URL')
    # logger.info(ENV['MAPPING_URL'])
    # logger.info('## MAPPINGS')
    # logger.info(mappings)

    SafeDir.mktmpdir do |safe_dir|
      s3_wrapper = NdrAvro::S3Wrapper.new(safe_dir: safe_dir)

      # Create a temporary copy of the mappings
      table_mappings = s3_wrapper.materialise_mappings(mappings)

      # Create a temporary copy of the S3 file
      safe_input_path = s3_wrapper.get_object(input_bucket, object_key)

      t1 = Time.current

      # Generate the avro file(s)
      generator = NdrAvro::Generator.new(safe_input_path, table_mappings, safe_dir)
      generator.process

      t2 = Time.current

      results = []

      # Put the output files in the output S3 bucket
      generator.output_files.each do |output_file_hash|
        object_hash = s3_wrapper.put_object(output_bucket, output_file_hash[:path])
        results << object_hash.merge(total_rows: output_file_hash[:total_rows])

        object_hash = s3_wrapper.put_object(output_bucket, output_file_hash[:schema])
        results << object_hash
      end

      t3 = Time.current

      logger.info(results)

      # return {
      #   results: results,
      #   timings: {
      #     s3_get: t1 - t0,
      #     generator: t2 - t1,
      #     s3_put: t3 - t2,
      #     total: t3 - t0
      #   },
      #   versions: {
      #     lambda_function: LambdaFunction::VERSION,
      #     ndr_import: NdrImport::VERSION,
      #     ndr_avro: NdrAvro::VERSION,
      #     ruby: RUBY_VERSION
      #   }
      # }
    rescue StandardError => e
      logger.info('## ERROR')
      logger.info(e.class)
      logger.info(e.message)
      logger.info(e.backtrace)

    #   return {
    #     error: {
    #       class: e.class,
    #       message: e.message,
    #       backtrace: e.backtrace
    #     }
    #   }
    end
    # $client.get_account_settings().account_usage.to_h
  end
end
