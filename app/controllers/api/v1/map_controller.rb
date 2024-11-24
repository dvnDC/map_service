class Api::V1::MapController < ApplicationController
  include WashOut::SOAP

  # Set the namespace to match the Android client
  soap_service namespace: "http://your.namespace.com/"

  soap_action "getMapFragment",
              args: {
                leftTopX: :integer,
                leftTopY: :integer,
                rightBottomX: :integer,
                rightBottomY: :integer
              },
              return: { image: :string }

  def getMapFragment
    leftTopX = params[:leftTopX].to_i
    leftTopY = params[:leftTopY].to_i
    rightBottomX = params[:rightBottomX].to_i
    rightBottomY = params[:rightBottomY].to_i

    map = MiniMagick::Image.open(Rails.root.join('app/assets/images/gdansk.png'))
    width = rightBottomX - leftTopX
    height = rightBottomY - leftTopY

    cropped_map = map.crop("#{width}x#{height}+#{leftTopX}+#{leftTopY}")
    image_data = Base64.encode64(cropped_map.to_blob)

    render soap: { image: image_data }
  rescue => e
    render soap: { error: e.message }
  end
end