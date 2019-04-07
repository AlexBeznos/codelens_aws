require 'fileutils'

class RspecTemp
  def initialize(file_name)
    @file_name = file_name
    @dir_name = 'rspec_tests'
    FileUtils.mkdir("/tmp/#{@dir_name}")
    @full_path = File.join('/tmp', @dir_name, @file_name)
    @file = open_file
  end

  def write(line)
    @file || @file = open_file
    @file.write(line)
  end

  def path
    @full_path
  end

  def close
    @file&.close
  end

  def flush
    @file && @file.close
    FileUtils.rm_rf(File.join('/tmp', @dir_name))
  end

  private

  def open_file
    File.new(@full_path, 'w')
  end
end
