lineNumber = 0

headers = (line) ->
  line = line.replace /^#+(.*)$/, '<h3>$1</h3>'

emphasis = (line) ->
  line = line.replace /\*\*(\S.*?\S)\*\*/g, '<b>$1</b>'
  line = line.replace /\_\_(\S.*?\S)\_\_/g, '<b>$1</b>'
  line = line.replace /\*(\S.*?\S)\*/g, '<i>$1</i>'
  line = line.replace /\_(\S.*?\S)\_/g, '<i>$1</i>'
  line = line.replace /\*\*(\S)\*\*/g, '<b>$1</b>'
  line = line.replace /\_\_(\S)\_\_/g, '<b>$1</b>'
  line = line.replace /\*(\S)\*/g, '<i>$1</i>'
  line = line.replace /\_(\S)\_/g, '<i>$1</i>'

lists = (line) ->
  lineNumber++
  line = line.replace /^ *[*-] *(\[[ x]\])(.*)$/, "<li><span class=task line=#{lineNumber}>$1</span>$2</li>"
  line = line.replace /^ *[*-](.*)$/, '<li>$1</li>'

escape = (line) ->
  line
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')

expand = (text) ->
  lineNumber = -1
  (emphasis headers lists escape line for line in text.split /\n/).join "\n"

emit = ($item, item) ->
  $item.append """
    <p>
      #{wiki.resolveLinks item.text, expand}
    </p>
  """

toggle = (item, lineNumber) ->
  lines = item.text.split /\n/
  lines[lineNumber] = lines[lineNumber].replace /\[[ x]\]/, (box) ->
    if box == '[x]' then '[ ]' else '[x]'
  item.text = lines.join "\n"

bind = ($item, item) ->
  $item.dblclick -> wiki.textEditor $item, item
  $item.find('.task').click (e) ->
    toggle item, $(e.target).attr('line')
    $item.empty()
    emit($item, item)
    bind($item, item)
    wiki.pageHandler.put $item.parents('.page:first'),
      type: 'edit',
      id: item.id,
      item: item


window.plugins.markdown = {emit, bind} if window?
module.exports = {expand} if module?
