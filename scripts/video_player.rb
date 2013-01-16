movies_path = '/art/blue'

def movie_length(movie)
  ml = `/bin/sh ./get_movie_length.sh #{movie} | tail -1`.chomp.to_i
  puts "found length of movie [#{movie}] -> #{ml} seconds"
  ml
end

def random_offset(length, duration)
  rand(length.to_f - duration.to_f)
end

def play_movie(file, length, offset, duration)
  puts "Playing [#{file}], of length [#{length}] for [#{duration}] from offset [#{offset}]"
  system("/bin/sh -x ./play_movie.sh #{file} #{offset} #{duration}") if File.exists?(file)
end

while true do
  files = Dir["#{movies_path}/*.ogv"]
  file = files[rand(files.size)]
  length = movie_length(file)
  target_duration = rand(90) + 5
  offset = random_offset(length, target_duration)
  play_movie(file, length, offset, target_duration)

  exit 0
end
