module ApiUmbrella
  module AttributifyData
    # Accept a hash of raw, nested data to update this API's attributes with.
    # This accepts data in the same form as `#attributes` outputs (and as the
    # data is stored), but transforms it into the format
    # `accepts_nested_attributes_for` expects.
    #
    # The basic steps this takes on incoming data:
    #
    # - Rename the keys used for relationship data (eg, from "url_matches" to
    #   "url_matches_attributes").
    # - Add "_destroy" attribute items for embedded records that are no longer
    #   present in the input (we assume our input data is a full representation
    #   of how the data should look).
    # - Sort embedded arrays in-place if a "sort_order" key is present.
    #
    # With mongo it's tempting to forgo the whole `accepts_nested_attributes_for`
    # style of doing things and just set all the hash data directly, but that
    # approach currently starts to break down for multi-level nested items (for
    # example, setting rate_limits on the emedded settings object).
    #
    # Note that this is currently shared between the Api model and the ApiUser
    # model. This code is really geared towards the Api model right now, but
    # we're leveraging it in the ApiUser model to handle the similar nested
    # settings and rate limits. If those use cases start to diverge,
    # this should be revisited to make more abstract.
    def assign_nested_attributes(data, options = {})
      data = data.deep_dup

      old_data = self.attributes
      attributify_data!(data, old_data)

      self.assign_attributes(data, options)
    end

    private

    def attributify_data!(data, old_data)
      attributify_settings!(data, old_data)

      %w(servers url_matches sub_settings rewrites).each do |collection_name|
        attributify_embeds_many!(data, collection_name, old_data)
      end
    end

    def attributify_settings!(data, old_data)
      data["settings_attributes"] = data.delete("settings") || {}

      settings_data = data["settings_attributes"]
      old_settings_data = old_data["settings"] if(old_data.present?)

      %w(headers rate_limits).each do |collection_name|
        attributify_embeds_many!(settings_data, collection_name, old_settings_data)
      end
    end

    def attributify_embeds_many!(data, collection_name, old_data)
      attribute_key = "#{collection_name}_attributes"
      data[attribute_key] = data.delete(collection_name) || []

      collection_old_data = []
      if(old_data.present? && old_data[collection_name].present?)
        collection_old_data = old_data[collection_name]
      end

      if(data[attribute_key].any?)
        # The virtual `sort_order` attribute will only be present if the data
        # has been resorted by the user. Otherwise, we can just accept the
        # incoming array order as correct.
        if(data[attribute_key].first["sort_order"].present?)
          data[attribute_key].sort_by! { |d| d["sort_order"] }
        end

        data[attribute_key].each { |d| d.delete("sort_order") }
      end

      # Since the data posted is a full representation of the api, it doesn't
      # contain the special `_destroy` attribute accepts_nested_attributes_for
      # expects for removed items (they'll just be missing). So we need to
      # manually fill in the items that have been destroyed.
      old_ids = collection_old_data.map { |d| d["_id"].to_s }
      new_ids = data[attribute_key].map { |d| d["_id"].to_s }

      deleted_ids = old_ids - new_ids
      deleted_ids.each do |id|
        data[attribute_key] << {
          "_id" => id,
          :_destroy => true,
        }
      end

      # Process all the Settings models stored off of individual SubSettings
      # records.
      if(collection_name == "sub_settings")
        data[attribute_key].each do |sub_attributes|
          sub_old_data = nil
          if(sub_attributes["_id"].present?)
            sub_old_data = collection_old_data.detect do |old|
              old["_id"] == sub_attributes["_id"]
            end
          end

          attributify_settings!(sub_attributes, sub_old_data)
        end
      end
    end
  end
end
