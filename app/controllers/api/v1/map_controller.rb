class Api::V1::MapController < ApplicationController
  require 'mini_magick'

  def cutout
    x1, y1, x2, y2 = params[:x1].to_i, params[:y1].to_i, params[:x2].to_i, params[:y2].to_i
    map = MiniMagick::Image.open(Rails.root.join('app/assets/images/gdansk.png'))
    cropped_map = map.crop("#{x2 - x1}x#{y2 - y1}+#{x1}+#{y1}")
    file_name = "cut_#{x1}_#{y1}_#{x2}_#{y2}.png"

    output_path = Rails.root.join('app', 'assets', 'images', 'cuts', file_name)
    cropped_map.write(output_path)

    render json: { image: Base64.encode64(cropped_map.to_blob) }
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
