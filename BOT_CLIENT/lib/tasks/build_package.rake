# frozen_string_literal: true

require 'zip'
require 'fileutils'

namespace :build_package do
  desc 'Build an default App package'
  task :run => :environment do
    zip_output = Rails.root.join('tmp', 'pakage', 'dependency.zip')
    exclude_paths = [
      'log', 'tmp', 'vendor', 'node_modules',
      '.git', '.github', '.idea', 'public', 'storage', 'spec',
      '.env', '.gitignore', '.gitattributes', 'README.md', 'test',
      'settings.json', 'lib'
    ]

    files = Dir.glob("**/*", File::FNM_DOTMATCH).reject do |f|
      f.start_with?(*exclude_paths) || File.directory?(f)
    end

    puts "Packaging ZIP to: #{zip_output}..."

    FileUtils.mkdir_p(zip_output.dirname.to_s)
    File.delete(zip_output) if File.exist?(zip_output)
    Zip::File.open(zip_output.to_s, Zip::File::CREATE) do |zipfile|
      files.each do |file|
        zipfile.add(file, file)
      end
    end

    puts "Packaging done"
  end
end
