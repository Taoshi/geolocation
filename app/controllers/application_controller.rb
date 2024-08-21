# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  # before_action :authenticate_user!

  rescue_from ::ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :invalid_params
  rescue_from RuntimeError, with: :error_occurred
  rescue_from NoMethodError, with: :error_occurred

  private

  def authenticate_user!
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV['API_USERNAME'] && password == ENV['API_PASSWORD']
    end
  end

  def invalid_params(exception)
    render json: { error: exception.message,
                   backtrace: exception.backtrace }.to_json, status: 400
  end

  def record_not_found(exception)
    render json: { error: exception.message }.to_json, status: 404
  end

  def error_occurred(exception)
    render json: { error: exception.message,
                   backtrace: exception.backtrace }.to_json, status: 500
  end
end
