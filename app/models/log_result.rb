class LogResult
  attr_reader :raw_result

  def initialize(search, raw_result)
    @search = search
    @raw_result = raw_result
  end

  def total
    raw_result.total
  end

  def documents
    raw_result.documents
  end

  def facets
    raw_result.raw_plain["facets"]
  end

  def interval_hits
    if(!@interval_hits && facets["interval_hits"])
      @interval_hits = {}

      # Default all interval points to 0 (so in case any are missing from the
      # real data).
      time = @search.start_time
      case @search.interval
      when "minute"
        time = time.change(:sec => 0)
      else
        time = time.send(:"beginning_of_#{@search.interval}")
      end

      while(time <= @search.end_time)
        @interval_hits[time.to_i * 1000] ||= 0
        time += 1.send(:"#{@search.interval}")
      end

      # Overwrite the default 0 values with the real values.
      facets["interval_hits"]["entries"].each do |entry|
        @interval_hits[entry["time"]] = entry["count"]
      end
    end

    @interval_hits
  end

  def map_breadcrumbs
    if(!@map_breadcrumbs && @search.region)
      @map_breadcrumbs = []

      case(@search.region)
      when /^([A-Z]{2})$/
        country = Regexp.last_match[1]

        @map_breadcrumbs = [
          { :region => "world", :name => "World" },
          { :name => Country[country].name },
        ]
      when /^(US)-([A-Z]{2})$/
        country = Regexp.last_match[1]
        state = Regexp.last_match[2]

        @map_breadcrumbs = [
          { :region => "world", :name => "World" },
          { :region => country, :name => Country[country].name },
          { :name => Country[country].states[state]["name"] },
        ]
      end
    end

    @map_breadcrumbs
  end

  def cities
    unless @cities
      @cities = {}

      @regions = facets["regions"]["terms"]
      if(@search.query[:facets][:regions][:terms][:field] == "request_ip_city")
        @city_names = @regions.map { |term| term["term"] }
        @cities = {}

        if @city_names.any?
          query = {
            :filter => {
              :and => [],
            },
          }

          query[:filter][:and] << {
            :term => { :country => @search.country },
          }

          if @search.state
            query[:filter][:and] << {
              :term => { :region => @search.state },
            }
          end

          query[:filter][:and] << {
            :terms => { :city => @city_names },
          }

          @search.server.index("api-umbrella").search({ :size => 500 }, query).documents.each do |result|
            @cities[result["city"]] = result["location"]
          end
        end
      end
    end

    @cities
  end
end
