# frozen_string_literal: true

require 'spec_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1',
        description: 'API documentation for version 1 of the application',
        contact: {
          name: 'API Support',
          email: 'support@example.com'
        },
        license: {
          name: 'MIT',
          url: 'https://opensource.org/licenses/MIT'
        }
      },
      paths: {},
      servers: [
        {
          url: 'http://{defaultHost}',
          description: 'Local development server',
          variables: {
            defaultHost: {
              default: '0.0.0.0:3000'
            }
          }
        }
      ]
    }
  }

  # Specify the format for the output Swagger files (:json or :yaml)
  # Ensure the format matches the file extension in openapi_specs keys
  config.openapi_format = :yaml
end
