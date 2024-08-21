# frozen_string_literal: true

module Api
  module V1
    class GeolocationsController < ApplicationController
      def create
        response = GeolocationService.new(geolocation_params[:ip_address_or_url]).call
        if response&.success?
          render json: { result: response.object }, status: 201
        else
          render json: { error: response.error }, status: 422
        end
      end

      def show
        response = GeolocationService.new(geolocation_params[:ip_address_or_url], find_in_db: true).call

        if response&.success?
          render json: { result: response.object }, status: 200
        elsif response&.error
          render json: { error: response.error }, status: 400
        else
          render json: { error: 'Geolocation not found' }, status: 404
        end
      end

      def destroy
        response = GeolocationService.new(geolocation_params[:ip_address_or_url], find_in_db: true).call
        if response&.success?
          response.object.destroy
          render json: { result: "Ip address was successfully destroyed #{response.object.ip_address}" }, status: 200
        else
          render json: { error: 'Geolocation not found' }, status: 404
        end
      end

      private

      def geolocation_params
        params.permit(:ip_address_or_url)
      end
    end
  end
end
