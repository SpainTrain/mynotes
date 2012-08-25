#This array maps regexes to their replacement strings
#for the @MyNotes.HtmlToMd function
#ORDER MATTERS, do not change the order
htmltomd_replacements = [
  regex: /(\\|`|\*|_|{|}|\[|\]|\(|\)|#|\+|-|\.|!)/ig
  str: "\\$1"
,
  regex: /(<\/?b>)/ig
  str: "**"
,
  regex: /(<\/?i>)/ig
  str: "*"
,
  regex: /<p>/ig
  str: ""
,
  regex: /<\/p>/ig
  str: "\n\n"
,
  regex: /<a +href=["'](.*)['"] +>(.*)<\/a>/ig
  str: "[$2]($1)"
]

#map for MdHtmlToMnHtml fn
mdhtmltomnhtml_replacements = [
  regex: /(<\/?)strong(>)/
  str: "$1b$2"
,
  regex: /(<\/?)em(>)/
  str: "$1i$2"
]

#private fn to do the replacement work
make_replacements = (str, replacements) ->
  for replacement in replacements
    ret_str = str
    do (replacement) ->
      ret_str = ret_str.replace replacement.regex, replacement.str

#public functions
@MyNotes = {}

#fn to convert mynotes' html to markdown
@MyNotes.HtmlToMd = (html_string) ->
  return make_replacements html_string, htmltomd_replacements

#Function to convert markdown's html to mynote's html
#In particular, emph and strong need to be italic and bold
@MyNotes.MdHtmlToMnHtml = (md_html_string) ->
  return make_replacements md_html_string, mdhtmltomnhtml_replacements
