
##
# Renders these items inside of a CSS flexbox.
def render_items(items)
    out = "<div class=\"flex\">"
    items.each do |x|
        out << "<div class=\"centre\"><div class=\"work\">"
        out << "<div style=\"--img : url('/image/avatar/7.png'); --angle : 10deg;\"></div>"
        out << "</div></div>"
    end
    out + "\n</div>"
end

works_info = unmarshal_yaml(read("works/list.yaml"))
vars = binding
page = read("works/layout.html")
page = template(page, vars)
write("works.html", page)
