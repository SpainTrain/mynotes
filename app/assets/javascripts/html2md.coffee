#These fns use a special dialect of MD that preserves new lines

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
  str: "_"
,
  regex: /<a +href="(.*?)" *>(.*?)<\/a>/ig
  str: "[$2]($1)"
,
  regex: /<div><br\/?><\/div>/ig
  str: "\n\n"
,
  regex: /<br\/?>/ig
  str: "\n"
,
  regex: /^<div>(.*?)<\/div>$/ig
  str: "$1"
,
  regex: /^<div>(.*?)<\/div>/ig
  str: "$1\n"
,
  regex: /<div>(.*?)<\/div>/ig
  str: "\n$1"
]

#Markdown libraries don't handle situations like <b>txt</b><b><i>txt</i></b><i>txt</i> correctly
#map for mynotes markdown to markdown
mnmdtomd_replacements = [
  regex: /\n\n/igm
  str: "<div><br/></div>"
,
  regex: /\n(.+?)($|<div>)/igm
  str: "<div>$1</div>$2"
,
  regex: /\n/igm
  str: "<br/>"
,
  regex: /([^\\]|^)\*\*(.*?)\*\*/ig
  str: "$1<b>$2</b>"
,
  regex: /([^\\]|^)\_(.*?)\_/ig
  str: "$1<i>$2</i>"
,
  regex: /\[(.*?)\]\((.*?)\)/ig
  str: '<a href="$2">$1</a>'
,
  regex: /\\(\\|`|\*|_|{|}|\[|\]|\(|\)|#|\+|-|\.|!)/ig
  str: "$1"
]

#map for MdHtmlToMnHtml fn
mdhtmltomnhtml_replacements = [
  regex: /(<\/?)strong(>)/ig
  str: "$1b$2"
,
  regex: /(<\/?)em(>)/ig
  str: "$1i$2"
,
  regex: /(<\/?)p(>)/ig
  str: "$1div$2"
,
  regex: /^\n/igm
  str: "<div><br></div>"
,
  regex: /\n/igm
  str: "<br/>"
]

converter = new Markdown.Converter()

#private fn to do the replacement work
make_replacements = (str, replacements) ->
  ret_str = str
  for replacement in replacements
    do (replacement) ->
      ret_str = ret_str.replace replacement.regex, replacement.str
  return ret_str

#public functions
@MyNotes = {}

#fn to convert mynotes' html to markdown
@MyNotes.HtmlToMd = (html_string) ->
  return make_replacements html_string, htmltomd_replacements

#Function to convert markdown's html to mynote's html
#In particular, emph and strong need to be italic and bold
@MyNotes.MdToHtml = (md_string) ->
  ret_str = make_replacements md_string, mnmdtomd_replacements
#  ret_str = converter.makeHtml ret_str
#  ret_str = make_replacements ret_str, mdhtmltomnhtml_replacements
  return ret_str
