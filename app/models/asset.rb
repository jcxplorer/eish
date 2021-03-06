class Asset < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true
  belongs_to :user
  has_one :article
  has_one :news_article
  has_one :event
  
  has_attached_file :upload, 
    :styles => { :large => "700x500>", :medium => "300x300>", :thumb => "100x100>", :square => "100x100#" },
    :url => "/uploads/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploads/:id/:style/:basename.:extension"
    
  validates_presence_of :description, :unless => Proc.new { |asset| asset.class == Image }
  validates_attachment_presence :upload, :message => "is missing"
    
  def filename
    upload_file_name
  end
  
  def mime_type
    upload_content_type
  end
  
  def size
    upload_file_size
  end
  
  def image?
    return true if upload_content_type =~ /image\/.*/
    return false
  end
  
  def textile_tag(style)
    return "!" + self.upload.url(style) + "(" + self.description + ")!"
  end
  
  def before_save
    self.description.strip!
  end
  
  def self.images(attachable_type, attachable_id)
    find_all_by_attachable_type_and_attachable_id(attachable_type, attachable_id, :conditions => "upload_content_type LIKE 'image/%'")
  end
  
  def self.files(attachable_type, attachable_id)
    find_all_by_attachable_type_and_attachable_id(attachable_type, attachable_id, :conditions => "upload_content_type NOT LIKE 'image/%'")
  end
end
