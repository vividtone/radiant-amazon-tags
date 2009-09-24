require 'amazon/ecs'

module AmazonTags
  include Radiant::Taggable

  class TagError < StandardError; end;

  tag "amazon" do |tag|
    if tag.double? then
      if tag.attr['asin'] then
        aws_response = find_amazon_items(tag)
        tag.locals.items = aws_response.items
        tag.locals.item = aws_response.items.first
      end
      tag.expand
    else
      raise TagError, "amazon tag must be double tag"
    end
  end

  desc %{
    Search Amazon items by ASIN(Amazon Standard Identification Number) or keywords and cycles through each of the found items.

    "asin" and "keywords" attributes are cannot be used at the same time.

    *Usage:*

    <pre><code><r:amazon:each [asin="ASIN"] [keywords="keyword1 keyword2 ..."] [search_index="All|Books|Music|..."]
      ...
    </r:amazon:each>
    </code></pre>
  }
  tag "amazon:each" do |tag|
    if tag.double? then
      aws_response = find_amazon_items(tag)
      items = aws_response.items
      tag.locals.items = items
      return items.inject("") do |v, item|
        tag.locals.item = item
        v << tag.expand
      end
    else
      raise TagError, "amazon:each tag must be double tag"
    end
  end

  desc %{
    Search Amazon items by ASIN(Amazon Standard Identification Number) or keywords and returns the first item in the search result. Takes the same options as @<r:amazon:each>@.

    *Usage:*

    <pre><code><r:amazon:first [asin="ASIN"] [keywords="keyword1 keyword2 ..."] [search_index="All|Books|Music|..."]
      ...
    </r:amazon:first>
    </code></pre>
  }
  tag "amazon:first" do |tag|
    if tag.double? then
      aws_response = find_amazon_items(tag)
      tag.locals.items = aws_response.items
      tag.locals.item = aws_response.items.first
      tag.expand
    else
      raise TagError, "amazon:first tag must be double tag"
    end
  end

  desc %{
    Renders the title of the item. 
  }
  tag "amazon:item_title" do |tag|
    item = tag.locals.item
    item ? item.get("itemattributes/title").to_s : ""
  end

  desc %{
    Renders the artist of the item. Valid for "Music" items.
  }
  tag "amazon:artist" do |tag|
    item = tag.locals.item
    item ? item.get("itemattributes/artist").to_s : ""
  end


  desc %{
    Renders the total number of items.
  }
  tag "amazon:count" do |tag|
    items = tag.locals.items
    items ? items.count.to_s : ""
  end

  desc %{
    Renders the URL for detail page.
  }
  tag "amazon:detail_page_url" do |tag|
    item = tag.locals.item
    item ? item.get("detailpageurl").to_s : ""
  end

  desc %{
    Renders the lowest new price for the item.
  }
  tag "amazon:lowest_new_price" do |tag|
    item = tag.locals.item
    item ? item.get("offersummary/lowestnewprice/formattedprice").to_s : ""
  end

  desc %{
    Renders the lowest used price for the item.
  }
  tag "amazon:lowest_used_price" do |tag|
    item = tag.locals.item
    item ? item.get("offersummary/lowestusedprice/formattedprice").to_s : ""
  end

  desc %{
    Renders the image URL for the item. Default size for image is "medium".

    *Usage:*

    <pre><code><r:amazon:image_url [size="small|medium|large"] /></code></pre>
  }
  tag "amazon:image_url" do |tag|
    get_image_url(tag)
  end

  desc %{
    Renders the inline image tag with a link to the item.

    *Usage:*

    <pre><code><r:amazon:image [size="small|medium|large"] /></code></pre>
  }
  tag "amazon:image" do |tag|
    item = tag.locals.item
    return if item == nil
    image_url = get_image_url(tag)
    link = item.get("detailpageurl")
    return "<a href=\"#{link}\"><img src=\"#{image_url}\"></a>"
  end

  desc %{
    Renders the title of the item with a link to detail page.

    *Usage:*

    <pre><code><r:amazon:item_link /></code></pre>
  }
  tag "amazon:item_link" do |tag|
    item = tag.locals.item
    return "" if item == nil
    title = item.get("itemattributes/title")
    link = item.get("detailpageurl")
    return "<a href=\"#{link}\">#{title}</a>"
  end

  private

  def find_amazon_items(tag)
      Amazon::Ecs.configure do |options|
        options[:aWS_access_key_id] = Radiant::Config["amazon_tags.aws_access_key_id"]
        options[:aWS_secret_key] = Radiant::Config["amazon_tags.aws_secret_key"] 
        options[:associate_tag] = Radiant::Config["amazon_tags.associate_tag"]
        options[:country] = Radiant::Config["amazon_tags.country"]
      end

      if asin = tag.attr['asin'] then
        return Amazon::Ecs.item_lookup(asin,
                                       {:Condition => "All",
                                        :ResponseGroup => "Medium"})
      elsif keywords = tag.attr['keywords'] then
        search_index = tag.attr['search_index'] || 'Books'
        return Amazon::Ecs.item_search(keywords,
                                       {:Condition => "All",
                                        :search_index => search_index,
                                        :ResponseGroup => "Medium"})
      else
        raise TagError, 'Either asin or keywords attribute is required'
      end
  end

  def get_image_url(tag)
    item = tag.locals.item
    size = tag.attr['size'] || 'medium'
    if size =~ /^(small|medium|large)$/ then
      return item ? item.get("#{size}image/url").to_s : ""
    else
      raise TagError, 'value of size attribute must be "small", "medium" or "large"'
    end
  end
end
