# frozen_string_literal: true
require 'zip'

namespace :build_admin_bot do
  desc 'Generate a new version to deploy admin bot'
  task :run => :environment do
    include ContentHelper

    ### 1. Export installer
    @release_installer = Rails.root.join('tmp', 'releases', 'bots', 'admin.sh')
    base_installer = Rails.root.join('lib', 'samples', 'bots', 'admin', "installer.sh")

    parameters_to_replace = {
      PACKAGE_URL_TO_FILL: "#{get_admin_installer_source_base}/pet_app_dependency"
    }
    file_content = File.read(base_installer)
    parameters_to_replace.each do |key, val|
      file_content.gsub!(/\b#{key}\b/, '"' + val + '"')
    end

    FileUtils.mkdir_p(File.dirname(@release_installer))
    File.delete(@release_installer) if File.exist?(@release_installer)
    File.write(@release_installer, file_content)

    ### 2. Prepare and export dependency
    base_uninstaller = Rails.root.join('lib', 'samples', 'bots', 'admin', "uninstaller.sh")
    temporal_env = Rails.root.join('tmp', 'releases', 'bots', '.env')

    # Create envar
    facade_new = FacadeNew.only_active
    env_vars = [
      ['REGISTER_URI', Parameter.reg_uri],
      ['REGISTER_POOL', Parameter.reg_pool],
      ['MARKER', facade_new.marker],
      ['CIPHER_KEY', facade_new.crypt_config['key']],
      ['CIPHER_IV', facade_new.crypt_config['iv']]
    ]

    File.delete(temporal_env) if File.exist?(temporal_env)
    File.open(temporal_env, "w") do |file|
      env_vars.each do |key, value|
        file.puts "#{key} = \"#{value}\""
      end
    end

    # Prepare and export zip
    base_package = Rails.root.join('lib', 'samples', 'bots', 'admin', 'dependency.zip')
    @release_package = Rails.root.join('tmp', 'releases', 'bots', 'admin_dependency.zip')
    File.delete(@release_package) if File.exist?(@release_package)

    FileUtils.cp(base_package, @release_package)
    Zip::File.open(@release_package, Zip::File::CREATE) do |zipfile|
      zipfile.add(".env", temporal_env)
      zipfile.add("bin/uninstaller.sh", base_uninstaller)
    end

    uploader = AwsIntegration::FacadeService.new
    uploader.upload_object(@release_installer, Parameter.bucket_facade_admin_bot_installer)
    uploader.upload_object(@release_package, Parameter.bucket_facade_admin_bot_dependency)

    # # Move the folder
    # public = Rails.root.join('public', 'releases', 'bots')
    # FileUtils.mkdir_p(public)
    # FileUtils.cp(@release_installer, public)
    # FileUtils.cp(@release_package, public)

    File.delete(@release_installer)
    File.delete(temporal_env)
    File.delete(@release_package)
  end
end