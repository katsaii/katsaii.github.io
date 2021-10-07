
##
# Renders these items inside of a CSS flex box.
def render_items(items)
    out = "<div class=\"flex\">"
    items.each do |x|
        name = x["name"]
        url = $urls[name.downcase]
        username = x["user"]
        content = if url == nil
            username
        else
            "<a href=\"#{url}\" target=\"_blank\">#{username}</a>"
        end
        out << "\n<div class=\"contact centre\"><b>#{name}</b><br>#{content}</div>"
    end
    out + "\n</div>"
end

contact_info = unmarshal_yaml(read("contact/list.yaml"))
vars = binding
page = read("contact/layout.html")
page = template(page, vars)
write("contact.html", page)
