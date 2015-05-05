require 'net/http'
require 'httparty'

base_urls = ["https://www.healthcare.gov", "https://www.cuidadodesalud.gov"]
index_url = base_urls.first + "/api/index.json"

# FIXME: set to the base url for the DG Search API server.
dg_search_base_url = ""
# FIXME: The first should be the url to your English site in DG Search, the second to your Spanish.
dg_search_urls = [dg_search_base_url + "/api/v1/documents", dg_search_base_url + "/api/v1/documents"]
dg_search_username = ""
dg_search_password = ""

index_response = HTTParty.get(index_url)
parsed_index = JSON.parse(index_response.body)
parsed_index.each do |page|
  0.upto(1) do |index|
    page_response = HTTParty.get(base_urls[index] + page['url'] + ".json")
    if page_response.code == 200
      parsed_page = JSON.parse(page_response.body)
      options = {
        body: {
          document_id: parsed_page['id'],
          title: parsed_page['title'],
          path: base_urls[index] + parsed_page['url'],
          description: parsed_page['excerpt'],
          created: parsed_page['date'],
          content: parsed_page['content'],
          promote: false,
          language: parsed_page['lang']
        },
        basic_auth: {
          username: dg_search_username,
          password: dg_search_password
        }
      }
      post_response = HTTParty.post(dg_search_urls[index], options)
      puts post_response.code
      puts post_response.body
    end
  end
end