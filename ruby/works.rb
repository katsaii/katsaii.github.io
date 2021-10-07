vars = binding
page = read("works/layout.html")
page = template(page, vars)
write("works.html", page)
