require 'json'
require_relative 'lambda_function'

event = JSON.parse(File.open('test/resources/s3_event.json', 'r').read)

ENV['OUTPUT_BUCKET_ARN'] = 'arn:aws:s3:::ruby-etl-lambda-outbox'
ENV['MAPPING_URL'] = 'https://raw.githubusercontent.com/timgentry/dids-on-fhir/main/avro_mapping.yml'

puts LambdaFunction.process(event: event, context: nil)
