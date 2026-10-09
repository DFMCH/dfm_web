require "active_support/concern"
require "nokogiri"
require "uri"

module DfmWeb
  module AutoAssets
    extend ActiveSupport::Concern

    included do
      class_attribute :dfm_web_auto_include_assets, default: true
      after_action :include_dfm_web_assets
    end

    private

    def include_dfm_web_assets
      return unless Rails.application.config.dfm_web.auto_include_assets && dfm_web_auto_include_assets
      return if request.head? || response.committed? || response.headers["Content-Disposition"]
      return unless response.successful? && response.media_type == "text/html"
      return if defined?(ActionController::Live) && is_a?(ActionController::Live)

      parts = response_body
      return unless parts.is_a?(String) || (parts.is_a?(Array) && parts.all? { |part| part.is_a?(String) })

      body = Array(parts).join
      return unless body.match?(/\A\s*<!doctype\s+html\b[^>]*>\s*<html\b[^>]*>\s*<head\b/i)

      document = parse_dfm_web_document(body)
      return unless document && document.errors.empty?

      head = document.at_css("html > head")
      return unless head

      tags = Nokogiri::HTML5.fragment(view_context.dfm_web_asset_tags).element_children
      changed = false
      tags.each do |tag|
        attribute = tag.name == "link" ? "href" : "src"
        selector = tag.name == "link" ? "link[rel~='stylesheet']" : "script[src]"
        next if document.css(selector).any? { |existing| same_dfm_web_asset?(existing, tag, attribute) }

        anchor = tag.name == "link" ? head.at_css("link[rel~='stylesheet'], style") : nil
        if anchor
          anchor.add_previous_sibling(tag)
        else
          head.add_child(tag)
        end
        changed = true
      end
      return unless changed

      self.response_body = document.to_html
      %w[Content-Length ETag Last-Modified].each { |header| response.headers.delete(header) }
    end

    def parse_dfm_web_document(body)
      Nokogiri::HTML5.parse(body, nil, response.charset || "UTF-8")
    rescue ArgumentError, Nokogiri::XML::SyntaxError => error
      Rails.logger.warn("DFM asset inclusion skipped: #{error.message}")
      nil
    end

    def same_dfm_web_asset?(existing, tag, attribute)
      existing["data-dfm-web"] == tag["data-dfm-web"] ||
        dfm_web_asset_url_path(existing[attribute]) == dfm_web_asset_url_path(tag[attribute])
    end

    def dfm_web_asset_url_path(value)
      URI.parse(value.to_s).path
    rescue URI::InvalidURIError
      value
    end
  end
end