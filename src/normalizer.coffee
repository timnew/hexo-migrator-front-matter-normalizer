async = require('async')
colors = require('colors')
pathUtil = require('path')
_ = 
  omit: require('lodash.omit')

extend = hexo.extend
util = hexo.util
file = hexo.file
sourceDir = hexo.source_dir
yfm = util.yfm

STANDARD_METAS = ['layout', 'title', 'date', 'updated', 'comments', 'tags', 'categories', 'permalink', '_content']

colorfulLog = (verb, key, value) ->
  if value?
    console.log "#{verb}\t#{key.cyan}\t\t#{value}"
  else
    console.log "#{verb}\t#{key.cyan}"

parseDateFromFileName = (filename) ->
  result = filename.match /(\d\d\d\d-\d\d-\d\d)-.*/
  new Date(result[1])

tryAddMeta = (content, name, value) ->
  unless content[name]?
    colorfulLog 'Add'.green, name, value
    content[name] = value

tryMapMeta = (content, oldName, newName) ->
  if content[oldName]?
    value = content[oldName]
    colorfulLog 'Map'.yellow, oldName, value
    if content[newName]?
      colorfulLog 'Set'.magenta, newName, content[newName]
    content[newName] = value
    delete content[oldName]

tryCleanMeta = (content) ->
  extraMetas = _.omit content, STANDARD_METAS
  for k, v of extraMetas
    colorfulLog 'Remove'.red, k, v
    delete content[k]

overwriteMeta = (content, name, value) ->
  colorfulLog 'Set'.magenta, name, value
  content[name] = value

extend.migrator.register 'normalize', (args, done) ->
  hexo.file.list sourceDir, null, (err, files) ->
    files = files.filter (f) -> f.match /.*?\.md$/
    colorfulLog 'Found'.yellow, files.length, 'posts'    

    async.each files, (f, callback) ->        
      fileName = sourceDir + f
      text = file.readFileSync(fileName)
      content = yfm.parse(text)        

      console.log 'xxxxxx' if content.layout == true
      
      colorfulLog 'Processing'.white, f        

      tryMapMeta content, 'category', 'categories'

      tryAddMeta content, 'layout', 'post'        
      tryAddMeta content, 'comments', true
      tryAddMeta content, 'tags', []
      tryAddMeta content, 'categories', [hexo.config.default_category]        

      overwriteMeta content, 'date', parseDateFromFileName(f)

      tryCleanMeta content  

      console.log ''

      text = yfm.stringify content
      file.writeFile fileName, text, callback    
        