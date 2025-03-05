# frozen_string_literal: true

module DnsHelper
  include UtilsHelper

  def nslookup_for(domain)
    resolver = Dnsruby::Resolver.new
    response = resolver.query(domain)

    solutions = []
    response.answer.each do |r|
      begin
        case r.type.to_s
        when 'CNAME'
          solutions << {
            ip_addr: r.domainname.to_s,
            type: r.type.to_s,
            resolved_domain: r.cname.to_s
          }
        when 'A'
          solutions << {
            ip_addr: r.address.to_s,
            type: r.type.to_s,
            resolved_domain: r.name.to_s
          }
        end
      rescue Exception => e
        next
      end
    end

    custom_out(success: true, result: solutions)

  rescue StandardError => e
    CustomError.new(msg: 'Cannot resolve domain')
  end
end
