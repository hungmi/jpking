class BasicUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick
  #require 'fog/aws'

  # Choose what kind of storage to use for this uploader:
  # if Rails.env.production?
    storage :fog
  # else
  #   storage :file
  # end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.token}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [20000, 500]
  #
  # def scale(width, height)
  #   process :resize_to_fill => [800, 800]
  # end
  
  process :optimize
  # Create different versions of your uploaded files:
  # version :large do
  #   process :resize_to_fit => [1280, 720]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    "original.#{file.extension}" if original_filename
  end

  def optimize
    manipulate! do |img|
      img.combine_options do |c|
        c.quality "80"
        c.depth "8"
        c.interlace "plane"
      end
      img
    end
  end

end
