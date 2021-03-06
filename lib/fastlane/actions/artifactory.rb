module Fastlane
  module Actions
    class ArtifactoryAction < Action
      def self.run(params)
        require 'artifactory'
        file_path = File.absolute_path(params[:file])
        if File.exist? file_path
          client = connect_to_artifactory(params)
          artifact = Artifactory::Resource::Artifact.new
          artifact.client = client
          artifact.local_path = file_path
          artifact.checksums = {
              "sha1" => Digest::SHA1.file(file_path),
              "md5" => Digest::MD5.file(file_path)
          }
          Helper.log.info "Uploading file: #{artifact.local_path} ..."
          upload = artifact.upload(params[:repo], params[:repo_path], params[:properties])
          Helper.log.info "Uploaded Artifact:"
          Helper.log.info "Repo: #{upload.repo}"
          Helper.log.info "URI: #{upload.uri}"
          Helper.log.info "Size: #{upload.size}"
          Helper.log.info "SHA1: #{upload.sha1}"
        else
          Helper.log.info "File not found: '#{file_path}'"
        end
      end

      def self.connect_to_artifactory(params)
        keys = [:endpoint, :username, :password, :ssl_pem_file, :ssl_verify, :proxy_username, :proxy_password, :proxy_address, :proxy_port]
        keys.each do |key|
          config[key] = params[key] if params[key]
        end
        Artifactory::Client.new(config)
      end

      def self.description
        'This action uploads an artifact to artifactory'
      end

      def self.is_supported?(platform)
        true
      end

      def self.author
        ["koglinjg"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :file,
                                       env_name: "FL_ARTIFACTORY_FILE",
                                       description: "File to be uploaded to artifactory",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :repo,
                                       env_name: "FL_ARTIFACTORY_REPO",
                                       description: "Artifactory repo to put the file in",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :repo_path,
                                       env_name: "FL_ARTIFACTORY_REPO_PATH",
                                       description: "Path to deploy within the repo, including filename",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :endpoint,
                                       env_name: "FL_ARTIFACTORY_ENDPOINT",
                                       description: "Artifactory endpoint",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "FL_ARTIFACTORY_USERNAME",
                                       description: "Artifactory username",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "FL_ARTIFACTORY_PASSWORD",
                                       description: "Artifactory password",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :properties,
                                       env_name: "FL_ARTIFACTORY_PROPERTIES",
                                       description: "Artifact properties hash",
                                       is_string: false,
                                       default_value: {},
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :ssl_pem_file,
                                       env_name: "FL_ARTIFACTORY_SSL_PEM_FILE",
                                       description: "Location of pem file to use for ssl verification",
                                       default_value: nil,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :ssl_verify,
                                       env_name: "FL_ARTIFACTORY_SSL_VERIFY",
                                       description: "Verify SSL",
                                       default_value: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :proxy_username,
                                       env_name: "FL_ARTIFACTORY_PROXY_USERNAME",
                                       description: "Proxy username",
                                       default_value: nil,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :proxy_password,
                                       env_name: "FL_ARTIFACTORY_PROXY_PASSWORD",
                                       description: "Proxy password",
                                       default_value: nil,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :proxy_address,
                                       env_name: "FL_ARTIFACTORY_PROXY_ADDRESS",
                                       description: "Proxy address",
                                       default_value: nil,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :proxy_port,
                                       env_name: "FL_ARTIFACTORY_PROXY_PORT",
                                       description: "Proxy port",
                                       default_value: nil,
                                       optional: true)
        ]
      end
    end
  end
end
