class Shrine
  module Storage
    class B2Native
      def initialize(bucket_id:, auth_token:, api_url:, bucket_name:, region:)
        @bucket_id    = bucket_id
        @bucket_name  = bucket_name
        @region       = region
        @auth_token   = auth_token
        @api_url      = api_url
        @upload_url   = nil
        @upload_auth  = nil
      end

      def upload(io, id, shrine_metadata: {}, **upload_options)
        ensure_upload_url!

        io.rewind if io.respond_to?(:rewind)
        data = io.read
        sha1 = OpenSSL::Digest::SHA1.hexdigest(data)

        uri = URI(@upload_url)
        req = Net::HTTP::Post.new(uri)
        req["Authorization"]       = @upload_auth
        req["X-Bz-File-Name"]      = URI.encode_www_form_component(id)
        req["Content-Type"]        = "application/octet-stream"
        req["Content-Length"]      = data.bytesize.to_s
        req["X-Bz-Content-Sha1"]   = sha1
        req.body = data

        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.request(req)
        end

        if [401, 403].include?(res.code.to_i) || res.code.to_i >= 500
          @upload_url = @upload_auth = nil
          return upload(StringIO.new(data), id, shrine_metadata: shrine_metadata, **upload_options)
        end

        unless res.is_a?(Net::HTTPSuccess)
          raise Shrine::Error, "upload failed (#{res.code}): #{res.body}"
        end

        JSON.parse(res.body)["fileId"]
      end

      def url(id, **options)
        "https://#{@bucket_name}.s3.#{@region}.backblazeb2.com/#{id}"
      end

      def exists?(id)
        !!fetch_file_id(id)
      end

      def open(id, **options)
        URI.open(url(id), **options)
      end

      def delete(id)
        file_id = fetch_file_id(id)
        return unless file_id

        uri = URI("#{@api_url}/b2api/v2/b2_delete_file_version")
        req = Net::HTTP::Post.new(uri)
        req["Authorization"] = @auth_token
        req.body = { fileId: file_id, fileName: id }.to_json

        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
        raise Shrine::Error, "delete failed: #{res.body}" unless res.is_a?(Net::HTTPSuccess)
        true
      end

      private

      def ensure_upload_url!
        return if @upload_url && @upload_auth

        uri = URI("#{@api_url}/b2api/v3/b2_get_upload_url")
        req = Net::HTTP::Post.new(uri)
        req["Authorization"] = @auth_token
        req.body = { bucketId: @bucket_id }.to_json

        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.request(req)
        end

        unless res.is_a?(Net::HTTPSuccess)
          raise Shrine::Error, "Failed to get upload URL: #{res.body}"
        end

        data = JSON.parse(res.body)
        @upload_url  = data["uploadUrl"]
        @upload_auth = data["authorizationToken"]
      end

      def fetch_file_id(id)
        uri = URI("#{@api_url}/b2api/v2/b2_list_file_names")
        req = Net::HTTP::Post.new(uri)
        req["Authorization"] = @auth_token
        req.body = {
          bucketId: @bucket_id,
          startFileName: id,
          maxFileCount: 100
        }.to_json

        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
        return nil unless res.is_a?(Net::HTTPSuccess)

        files = JSON.parse(res.body)["files"] || []
        file = files.find { |f| f["fileName"] == id }
        file && file["fileId"]
      end
    end
  end
end