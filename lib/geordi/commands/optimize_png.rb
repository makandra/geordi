require 'fileutils'

desc 'optimize_png', 'Optimize .png files'
long_desc <<-LONGDESC
- Removes color profiles: cHRM, sRGB, gAMA, ICC, etc.
- Eliminates unused colors and reduce bit-depth (if possible)
- May reduce PNG file size lossless

Batch-optimize all *.png in a directory:
  optimize_png directory

Batch-optimize the current directory:
  optimize_png .

Optimize single file:
  optimize_png input.png


# More info about pngcrush #

pngcrush -rem allb -reduce -brute original.png optimized.png
pngcrush -d target-dir/ *.png

-rem allb — remove all extraneous data (Except transparency and gamma; to remove everything except transparency, try -rem alla)
-reduce — eliminate unused colors and reduce bit-depth (If possible)

-brute — attempt all optimization methods (Requires MUCH MORE processing time and may not improve optimization by much)

original.png — the name of the original (unoptimized) PNG file
optimized.png — the name of the new, optimized PNG file
-d target-dir/  — bulk convert into this directory "target-dir"

-rem cHRM -rem sRGB -rem gAMA -rem ICC — remove color profiles by name (shortcut -rem alla)

An article explaining why removing gamma correction
http://hsivonen.iki.fi/png-gamma/
LONGDESC
def optimize_png(*args)
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
