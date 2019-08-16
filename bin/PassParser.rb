class PassParser
  TOKEN = "IT"
  @@tags = ["-", "|"]
  @@arrows = [">", "^", "<", "v"]
  attr_reader :secret

  # init
  def initialize(secret)
    @secret = secret.strip
  end

  # check is 8*8 + 6*6
  def check?
    if @secret.length != 199
      puts "!199"
      puts @secret.length
      # return false
    end
    #
    extract_secret
    #
    if @datas.length != 6 || @arrows.length != 8
      puts "===== " + @datas.length.to_s + " " + @arrows.length.to_s
      puts "!6 !8"
      return false
    end
    #
    @arrows.each_index do |index|
      if @arrows[index].length != 8
        puts "!8"
        return false
      end
    end

    #
    @datas.each_index do |index|
      if @datas[index].length != 6
        puts "!6"
        return false
      end
    end

    parse_arrow
  end

  def password
    return nil unless check?
    unless @pass
      @pass = find_pass + TOKEN
    end
    @pass
  end

  private
  def find_pass
    result = []
    case @flag
    when '|'
      (0..5).each do |i|
        result << @datas[i][@number]
      end
    when '-'
      (0..5).each do |i|
        result << @datas[@number][i]
      end
    end
    result.reverse! if @revert
    return result.join
  end

  def parse_arrow
    puts "start parse arrow"

    @arrows.each_index do |i|
      puts "i : " + i.to_s
      @arrows[i].each_index do |j|
        puts "j : " + j.to_s
        if @@arrows.include? @arrows[i][j]
          puts "find arrow !"

          @arrow = @arrows[i][j]
          @arrow_position = {row: i,
                             column: j}
          @revert = false
          case @arrow
          when ">" then
            if @@tags.include? @arrows[i][j+1]
              @flag = @arrows[i][j + 1]
              @number = @arrows[i + 1][j + 1].to_i
              @revert = true
            else
              @flag = @arrows[i + 1][j + 1]
              @number = @arrows[i][j + 1].to_i
            end
          when "^" then
            if @@tags.include? @arrows[i-1][j]
              @flag = @arrows[i - 1][j]
              @number = @arrows[i - 1][j + 1].to_i
              @revert = true
            else
              @flag = @arrows[i - 1][j + 1]
              @number = @arrows[i - 1][j].to_i
            end
          when "<" then
            if @@tags.include? @arrows[i][j - 1]
              @flag = @arrows[i][j - 1]
              @number = @arrows[i + 1][j - 1].to_i
              @revert = true
            else
              @flag = @arrows[i + 1][j - 1]
              @number = @arrows[i][j - 1].to_i
            end
          when "v" then
            if @@tags.include? @arrows[i + 1][j]
              @flag = @arrows[i + 1][j]
              @number = @arrows[i + 1][j + 1].to_i
              @revert = true
            else
              @flag = @arrows[i + 1][j + 1]
              @number = @arrows[i + 1][j].to_i
            end
          end
          if (@@tags.include? @flag) && (@number >= 0 && @number < 6)
            return true
          end
        end
      end
    end

    puts "find failed!"
    return false
  end

  def extract_secret
    i = 0
    @arrows = [] # save 8 * 8
    @datas = [] # save 6 * 6
    user_inputs = @secret.strip.split("\n")
    user_inputs.each do |line|
      puts "start lines :  " + line
      line_array = line.split ' '
      puts "arrays : " + line_array.to_s
      if i >= 0 && i < 8
        @arrows << line_array
      end
      if i >= 8 && i < 14
        @datas << line_array
      end
      i += 1
    end

    puts "arrays : " + @arrows.to_s
    puts "datas : " + @datas.to_s
  end
end

if __FILE__ == $0
  $/ = "\n\n"
  user_input = STDIN.gets
  puts user_input

  passParser = PassParser.new(user_input)
  puts "result : " +  passParser.password
end
