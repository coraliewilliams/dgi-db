require 'tempfile'
require 'open-uri'

class TsvUpdater < Updater
  attr_reader :tempfile

  def perform(recurring = true)
    begin
      import
      pre_grouper = PreGrouper.new
      pre_grouper.perform
      grouper = Grouper.new
      grouper.perform(should_group_genes?, should_group_drugs?)
      post_grouper = PostGrouper.new
      post_grouper.perform(should_cleanup_gene_claims?)
    ensure
      reschedule if recurring
    end
  end

  def import
    begin
      create_tempfile
      download_file
      importer.import
    ensure
      remove_download
    end
  end

  def create_tempfile
    @tempfile = Tempfile.new(tempfile_name, temp_path)
  end

  def temp_path
    File.join(Rails.root, 'tmp')
  end

  def tempfile_name
    raise StandardError.new('Must implement #tempfile_name in subclass')
  end

  def download_file
    download_stream = open(latest_url)
    IO.copy_stream(download_stream, tempfile)
  end

  def latest_url
    raise StandardError.new('Must implement #latst_url in subclass')
  end

  def importer
    raise StandardError.new('Must implement #importer in subclass')
  end

  def remove_download
    tempfile.close
    tempfile.unlink
  end

end
