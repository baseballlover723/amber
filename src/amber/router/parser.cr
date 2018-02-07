require "./parsers/**"

module Amber::Router
  module Parser
    TYPE_EXT_REGEX = Amber::Support::MimeTypes::TYPE_EXT_REGEX
    URL_ENCODED_FORM = "application/x-www-form-urlencoded"
    MULTIPART_FORM = "multipart/form-data"
    APPLICATION_JSON = "application/json"
    @parse_state = false

    def params
      return @params if @parse_state
      @params.store = query_params
      form_data
      json
      multipart
      @parse_state = true
      @params
    end

    private def form_data
      return unless content_type.try &.starts_with? URL_ENCODED_FORM
      Parsers::FormData.parse(self).each do |k, v|
        @params.store.add(k, v)
      end
    end

    private def multipart
      return unless content_type.try &.starts_with? MULTIPART_FORM
      Parsers::Multipart.parse(@params, self)
    end

    private def json
      return unless content_type.try &.starts_with? APPLICATION_JSON
      Parsers::JSON.parse(@params.store, self)
    end

    private def content_type
      headers["Content-Type"]?
    end
  end
end
