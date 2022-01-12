$blog_post_layout = read("blog/post.html")
$blog_tldr_layout = read("blog/post-tldr.html")

##
# Renders a markdown page.
def render_blog_page(name)
    page = read("blog/md/#{name}.md")
    markup(page)
end

##
# Displays a date in a human readable format.
def render_date(date)
    day = date["day"]
    postfix = case day
        when 1, 21, 31 then "st"
        when 2, 22 then "nd"
        when 3, 23 then "rd"
        when 1..31 then "th"
        else "ii"
    end
    month = case date["month"]
        when 1 then "Jan"
        when 2 then "Feb"
        when 3 then "Mar"
        when 4 then "Apr"
        when 5 then "May"
        when 6 then "Jun"
        when 7 then "Jul"
        when 8 then "Aug"
        when 9 then "Sep"
        when 10 then "Oct"
        when 11 then "Nov"
        when 12 then "Dec"
        else "Kat"
    end
    year = date["year"]
    "#{day}#{postfix} #{month} #{year}"
end

##
# Displays a date in a monospaced format.
def render_date_mono(date)
    day_number = date["day"]
    day = case day_number
        when 1..9 then "0#{day_number}"
        when 10..31 then "#{day_number}"
        else "dd"
    end
    month_number = date["month"]
    month = case month_number
        when 1..9 then "0#{month_number}"
        when 10..12 then "#{month_number}"
        else "mm"
    end
    year_number = date["year"]
    year = case year_number
        when 1..9 then "000#{year_number}"
        when 10..99 then "00#{year_number}"
        when 100..999 then "0#{year_number}"
        when 1000..9999 then "#{year_number}"
        else "yyyy"
    end
    "#{day}-#{month}-#{year}"
end

posts = unmarshal_yaml(read("blog/posts.yaml"))
posts = posts.sort do |x, y|
    cmp = 0
    if x.key?("date") and y.key?("date")
        xd = x["date"]
        yd = y["date"]
        cmp = xd["year"] <=> yd["year"]
        if cmp == 0
            cmp = xd["month"] <=> yd["month"]
            if cmp == 0
                cmp = xd["day"] <=> yd["day"]
            end
        end
    elsif x.key?("date")
        cmp = -1
    elsif y.key?("date")
        cmp = 1
    end
    -cmp
end
vars = binding
post_page = read("blog/posts.html")
post_page = template(post_page, vars)
write("blog/posts.html", post_page)
posts.each do |info|
    key = info.key?("short-title") ? "short-title" : "title"
    id = convert_id(info[key])
    page = read("blog/md/#{id}.md")
    tldr = read_or_nil("blog/md/tldr/#{id}.md")
    tldr = markup(tldr) if tldr != nil
    content = markup(page)
    index = markup(page, index=true)
    vars = binding
    write("blog/post/#{id}.html", template($blog_post_layout, vars))
    if tldr != nil
        write("blog/tldr/#{id}.html", template($blog_tldr_layout, vars))
    end
end
