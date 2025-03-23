# frozen_string_literal: true

module Namecheap
  class ConnectorService < ApplicationService
    attr_accessor :result

    def initialize
      @username = NAMECHEAP_USERNAME
      @api_key = NAMECHEAP_API_KEY
      @uri = NAMECHEAP_URI
      @client_ip = NAMECHEAP_ME_CLIENT_IP
      @result = nil
    end

    def list_my_domains
      reset_result
      params = {
        "ApiUser" => @username,
        "ApiKey" => @api_key,
        "UserName" => @username,
        "ClientIp" => @client_ip,
        "Command" => "namecheap.domains.getList"
      }

      response = make_request(params)
      @result = Nokogiri::XML(response)

      domains = @result.remove_namespaces!.xpath("//Domain")
      accumulator = []
      if domains.any?
        domains.each do |domain|
          accumulator << {
            id: domain["ID"],
            name: domain["Name"],
            expires: domain["Expires"],
            created: domain["Created"],
            is_expired: domain["IsExpired"] == "true",
            is_locked: domain["IsLocked"] == "true"
          }
        end
      end

      accumulator
    end

    # Registers a domain with Namecheap
    def purchase_domain(domain_name)
      params = {
        "ApiUser" => @username,
        "ApiKey" => @api_key,
        "UserName" => @username,
        "ClientIp" => @client_ip,
        "Command" => "namecheap.domains.create",
        "DomainName" => domain_name,
        "Years" => 1,
        "RegistrantFirstName" => NAMECHEAP_REGISTER_F_NAME,
        "RegistrantLastName" => NAMECHEAP_REGISTER_L_NAME,
        "RegistrantAddress1" => NAMECHEAP_REGISTER_ADDRESS,
        "RegistrantCity" => NAMECHEAP_REGISTER_CITY,
        "RegistrantStateProvince" => NAMECHEAP_REGISTER_PROVINCE,
        "RegistrantPostalCode" => NAMECHEAP_REGISTER_ZIP,
        "RegistrantCountry" => NAMECHEAP_REGISTER_COUNTRY,
        "RegistrantPhone" => NAMECHEAP_REGISTER_PHONE,
        "RegistrantEmailAddress" => NAMECHEAP_REGISTER_EMAIL,
        "TechFirstName" => NAMECHEAP_REGISTER_F_NAME,
        "TechLastName" => NAMECHEAP_REGISTER_L_NAME,
        "TechAddress1" => NAMECHEAP_REGISTER_ADDRESS,
        "TechCity" => NAMECHEAP_REGISTER_CITY,
        "TechStateProvince" => NAMECHEAP_REGISTER_PROVINCE,
        "TechPostalCode" => NAMECHEAP_REGISTER_ZIP,
        "TechCountry" => NAMECHEAP_REGISTER_COUNTRY,
        "TechPhone" => NAMECHEAP_REGISTER_PHONE,
        "TechEmailAddress" => NAMECHEAP_REGISTER_EMAIL,
        "AdminFirstName" => NAMECHEAP_REGISTER_F_NAME,
        "AdminLastName" => NAMECHEAP_REGISTER_L_NAME,
        "AdminAddress1" => NAMECHEAP_REGISTER_ADDRESS,
        "AdminCity" => NAMECHEAP_REGISTER_CITY,
        "AdminStateProvince" => NAMECHEAP_REGISTER_PROVINCE,
        "AdminPostalCode" => NAMECHEAP_REGISTER_ZIP,
        "AdminCountry" => NAMECHEAP_REGISTER_COUNTRY,
        "AdminPhone" => NAMECHEAP_REGISTER_PHONE,
        "AdminEmailAddress" => NAMECHEAP_REGISTER_EMAIL,
        "AuxBillingFirstName" => NAMECHEAP_REGISTER_F_NAME,
        "AuxBillingLastName" => NAMECHEAP_REGISTER_L_NAME,
        "AuxBillingAddress1" => NAMECHEAP_REGISTER_ADDRESS,
        "AuxBillingCity" => NAMECHEAP_REGISTER_CITY,
        "AuxBillingStateProvince" => NAMECHEAP_REGISTER_PROVINCE,
        "AuxBillingPostalCode" => NAMECHEAP_REGISTER_ZIP,
        "AuxBillingCountry" => NAMECHEAP_REGISTER_COUNTRY,
        "AuxBillingPhone" => NAMECHEAP_REGISTER_PHONE,
        "AuxBillingEmailAddress" => NAMECHEAP_REGISTER_EMAIL
      }
      response = make_request(params)
      @result = Nokogiri::XML(response)
      purchase_result = @result.remove_namespaces!.at_xpath("//DomainCreateResult")
      if purchase_result.nil?
        return { domain_name: domain_name, success: false, error: "Failed to register domain or some more happen, check results" }
      end

      {
        domain_name: domain_name,
        success: purchase_result["Registered"] == "true",
        registration_date: purchase_result["RegisterDate"],
        expiration_date: purchase_result["ExpireDate"]
      }
    end

    def check_domain_availability(domain_name)
      reset_result
      params = {
        "ApiUser" => @username,
        "ApiKey" => @api_key,
        "UserName" => @username,
        "ClientIp" => @client_ip,
        "Command" => "namecheap.domains.check",
        "DomainList" => domain_name
      }

      response = make_request(params)
      @result = Nokogiri::XML(response)
      domain_check = @result.remove_namespaces!.at_xpath("//DomainCheckResult[@Domain='#{domain_name}']")
      if domain_check.blank?
        return { domain_name: domain_name, available: false, message: "Need to check manually the response data)" }
      end

      {
        domain_name: domain_name,
        available: domain_check["Available"] == "true",
        error: domain_check["ErrorNo"] ? "Error #{domain_check['ErrorNo']}: #{domain_check['Description']}" : nil
      }
    end

    # @param domain_name <String> e.g.: my_domain.com or www.domai.com
    # @param heroku_app_uri <String> e.g.: the DNS resolutor given by heroku
    # @note Take into account that heroku will create a cert to link only and explicity to the domain indicated
    #   Any other new subdomain attach means you need to re-add again the process in heroku side
    def setup_domain_with_heroku_app(domain_name, heroku_app_uri)
      reset_result
      sld, tld = split_domain(domain_name)

      params = {
        "ApiUser" => @username,
        "ApiKey" => @api_key,
        "UserName" => @username,
        "ClientIp" => @client_ip,
        "Command" => "namecheap.domains.dns.setHosts",
        "SLD" => sld,
        "TLD" => tld,

        # Primary CNAME for 'www'
        "HostName1" => "www",
        "RecordType1" => "CNAME",
        "Address1" => heroku_app_uri,
        "TTL1" => "300",

        # Redirect root domain to 'www' (if ALIAS isn't available)
        "HostName2" => "@",
        "RecordType2" => "ALIAS",
        "Address2" => domain_name,
        "TTL2" => "300"
      }

      response = make_request(params)
      @result = Nokogiri::XML(response)
      setup_result = @result.remove_namespaces!.at_xpath("//DomainDNSSetHostsResult")

      if setup_result.blank?
        return { success: false, error: "Failed to update DNS or some other error. Check manually" }
      end

      {
        success: setup_result["IsSuccess"] == "true",
        error: nil
      }
    end

    def clean_domain_with_heroku_app(domain_name)
      reset_result
      sld, tld = split_domain(domain_name)

      params = {
        "ApiUser" => @username,
        "ApiKey" => @api_key,
        "UserName" => @username,
        "ClientIp" => @client_ip,
        "Command" => "namecheap.domains.dns.setHosts",
        "SLD" => sld,
        "TLD" => tld
      }

      response = make_request(params)
      @result = Nokogiri::XML(response)
      setup_result = @result.remove_namespaces!.at_xpath("//DomainDNSSetHostsResult")

      if setup_result.blank?
        return { success: false, error: "Failed to update DNS or some other error. Check manually" }
      end

      {
        success: setup_result["IsSuccess"] == "true",
        error: nil
      }
    end

    def test_connection
      reset_result
      params = {
        "ApiUser" => @username,
        "ApiKey" => @api_key,
        "UserName" => @username,
        "ClientIp" => @client_ip,
        "Command" => "namecheap.domains.getList"
      }

      response = make_request(params)
      @result = Nokogiri::XML(response)

      print_generic_output(@result)
    end

    private

    def make_request(params)
      uri = URI(@uri)
      uri.query = URI.encode_www_form(params)
      RestClient.proxy = FIXIE_URL
      response = RestClient.get(uri.to_s)
      response.body
    end

    def reset_result
      @result = nil
    end

    def split_domain(domain)
      parts = domain.split('.')
      sld = parts.first
      tld = parts.drop(1).join('.')
      [sld, tld]
    end
  end
end
