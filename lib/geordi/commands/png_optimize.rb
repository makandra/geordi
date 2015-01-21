desc 'png-optimize', 'Optimize .png files'
long_desc <<-LONGDESC
- Removes color profiles: cHRM, sRGB, gAMA, ICC, etc.
- Eliminates unused colors and reduces bit-depth (if possible)
- May reduce PNG file size lossless

Batch-optimize all `*.png` files in a directory:

    geordi png-optimize directory

Batch-optimize the current directory:

    geordi png-optimize .

Optimize a single file:

    geordi png-optimize input.png
LONGDESC

def png_optimize(*args)
  require 'fileutils'

  announce 'Optimizing .png files'

  if `which pngcrush`.strip.empty?
    fail 'You have to install pngcrush first (sudo apt-get install pngcrush)'
  end

  po = PngOptimizer.new
  path = args[0]
  if File.directory?(path)
    po.batch_optimize_inplace(path)
  elsif File.file?(path)
    po.optimize_inplace(path)
  else
    fail 'Neither directory nor file: ' + path
  end

  success 'PNG optimization completed.'
end

class PngOptimizer

  def ends_with?(string, suffix)
    string[-suffix.length, suffix.length] == suffix
  end

  def optimization_default_args
    args = ""
    args << "-rem alla " # remove everything except transparency
    args << "-rem text " # remove text chunks
    args << "-reduce " # eliminate unused colors and reduce bit-depth (if possible)
    args
  end

  def optimize_file(input_file, output_file)
    system "pngcrush #{optimization_default_args} '#{input_file}' '#{output_file}'"
  end

  def unused_tempfile_path(original)
    dirname = File.dirname(original)
    basename = File.basename(original)
    count = 0
    begin
      tmp_name = "#{dirname}/#{basename}_temp_#{count += 1}.png"
    end while File.exists?(tmp_name)
    tmp_name
  end

  def optimize_inplace(input_file)
    temp_file = unused_tempfile_path(input_file)
    result = optimize_file(input_file, temp_file)
    if result
      FileUtils.rm(input_file)
      FileUtils.mv("#{temp_file}", "#{input_file}")
    else
      fail 'Error:' + $?
    end
  end

  def batch_optimize_inplace(path)
    # Dir[".png"] works case sensitive, so to catch all funky .png extensions we have to go the following way:
    png_relative_paths = []
    Dir["#{path}/*.*"].each do |file_name|
      png_relative_paths << file_name if ends_with?(File.basename(file_name.downcase), ".png")
    end
    png_relative_paths.each do |png_relative_path|
      optimize_inplace(png_relative_path)
    end
  end

end
