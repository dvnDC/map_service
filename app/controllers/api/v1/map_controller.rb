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

  def wsdl
    render xml: build_wsdl
  end

  private

  def build_wsdl
    <<~WSDL
      <?xml version="1.0" encoding="UTF-8"?>
      <definitions xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                   xmlns:tns="http://your.namespace.com/soap"
                   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                   xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">
        <message name="getMapFragmentRequest">
          <part name="leftTopX" type="xsd:int"/>
          <part name="leftTopY" type="xsd:int"/>
          <part name="rightBottomX" type="xsd:int"/>
          <part name="rightBottomY" type="xsd:int"/>
        </message>
        <message name="getMapFragmentResponse">
          <part name="image" type="xsd:string"/>
        </message>
        <portType name="MapServicePortType">
          <operation name="getMapFragment">
            <input message="tns:getMapFragmentRequest"/>
            <output message="tns:getMapFragmentResponse"/>
          </operation>
        </portType>
        <binding name="MapServiceBinding" type="tns:MapServicePortType">
          <soapenv:binding style="rpc" transport="http://schemas.xmlsoap.org/soap/http"/>
          <operation name="getMapFragment">
            <soapenv:operation soapAction="urn:getMapFragment"/>
            <input>
              <soapenv:body use="encoded" namespace="http://your.namespace.com/soap"/>
            </input>
            <output>
              <soapenv:body use="encoded" namespace="http://your.namespace.com/soap"/>
            </output>
          </operation>
        </binding>
        <service name="MapService">
          <port name="MapServicePort" binding="tns:MapServiceBinding">
            <soapenv:address location="http://localhost:3000/api/v1/map/cutout"/>
          </port>
        </service>
      </definitions>
    WSDL
  end
end
