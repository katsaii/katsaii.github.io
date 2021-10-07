
##
# Renders these items inside of a CSS flexbox.
def render_items(items)
    out = "<div class=\"flex\">"
    items.each do |x|
        out << "<div class=\"record centre\"><code>#{x}</code></div>"
    end
    out + "</div>"
end

skills_info = unmarshal_yaml(read("skills/list.yaml"))
vars = binding
page = read("skills/layout.html")
page = template(page, vars)
write("skills.html", page)
