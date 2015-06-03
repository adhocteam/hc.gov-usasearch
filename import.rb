require 'net/http'
require 'httparty'

base_urls = ["https://www.healthcare.gov", "https://www.cuidadodesalud.gov"]
index_url = base_urls.first + "/api/index.json"

# FIXME: set to the base url for the DG Search i14y API server.
dg_search_base_url = "https://i14y.usa.gov"

# First set of credentials is for your English site, second set is for your Spanish site.
# FIXME: Get site_handle from https://search.usa.gov/sites/[YOUR_SITE_ID]/setting/edit, 'Site Handle'
# FIXME: Get secret_token from: https://search.usa.gov/sites/[YOUR_SITE_ID]/i14y_api_instructions, 'Secret Token'
dg_search_credentials = [
  {site_handle: "ENGLISH_HANDLE", secret_token: "ENGLISH_SECRET_TOKEN"},
  {site_handle: "SPANISH_HANDLE", secret_token: "SPANISH_SECRET_TOKEN"}
]

index_response = HTTParty.get(index_url)
parsed_index = JSON.parse(index_response.body)
parsed_index.each do |page|
  0.upto(1) do |index|
    if page && page['url']
      puts "Fetching #{base_urls[index]}#{page['url']}.json"
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
            username: dg_search_credentials[index][:site_handle],
            password: dg_search_credentials[index][:secret_token]
          }
        }
        post_response = HTTParty.post(dg_search_base_url + "/api/v1/documents", options)
        puts post_response.code
        puts post_response.body
      end
    else
      puts "Problem: #{page}"
    end
  end
end