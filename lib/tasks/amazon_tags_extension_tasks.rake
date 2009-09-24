namespace :radiant do
  namespace :extensions do
    namespace :amazon_tags do
      
      desc "Runs the migration of the Amazon Tags extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          AmazonTagsExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          AmazonTagsExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Amazon Tags to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from AmazonTagsExtension"
        Dir[AmazonTagsExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(AmazonTagsExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory, :verbose => false
          cp file, RAILS_ROOT + path, :verbose => false
        end
      end  
    end
  end
end
