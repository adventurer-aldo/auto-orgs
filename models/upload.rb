class Upload < ActiveRecord::Base
  include Shrine::Attachment(:file) # :file is the attachment name
end
