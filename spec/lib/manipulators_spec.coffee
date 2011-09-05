require '../helpers/spec_helper.coffee'
fs = require 'fs'
nap = require '../../src/nap.coffee'
_ = require 'underscore'

# Local fixtures
assets1 = 
  js:
    preManipulate:
      'development': [nap.compileCoffeescript]
  
    foo: [
      'spec/fixtures/coffeescripts/**/*.coffee'
    ]
    
  css:
    preManipulate:
      'development': [nap.compileStylus]
  
    foo: [
      'spec/fixtures/stylus/**/*.styl'
    ]

describe 'nap.compileCoffeescript', ->

  runAsync()

  it 'compiles coffeescript to js', ->
    expect(nap.compileCoffeescript("foo = 'bar'", 'foo.coffee').indexOf("var foo") isnt -1).toBeTruthy()
    done()
    
  it 'doesnt try to compile js', ->
    expect(nap.compileCoffeescript("var foo = 'bar';", 'foo.js')).toEqual "var foo = 'bar';"
    done()
    
  it 'when run through package compiles coffeescript files to js', ->
    process.env.NODE_ENV = 'development'
    nap.package assets1, 'spec/fixtures/assets'
    contents = fs.readFileSync('spec/fixtures/assets/foo.js').toString()
    expect(contents.indexOf("foo = 'foo';\n}).call(this);") isnt -1).toBeTruthy()
    expect(contents.indexOf("foo1 = 'foo1';\n}).call(this);") isnt -1).toBeTruthy()
    done()
    
describe 'nap.compileStylus', ->
  
  runAsync()
  
  it 'compiles stylus to css', ->
    expect(nap.compileStylus("foo\n  background red", 'foo.styl').indexOf('background: #f00;') isnt -1).toBeTruthy()
    done()
    
  it 'doesnt try to compile non stylus', ->
    expect(nap.compileStylus(".foo { background red; }", 'foo.css')).toEqual ".foo { background red; }"
    done()
  
  it 'when run through package compiles stylus files to css', ->
    process.env.NODE_ENV = 'development'
    nap.package assets1, 'spec/fixtures/assets'
    contents = fs.readFileSync('spec/fixtures/assets/foo.css').toString()
    expect(contents.indexOf("background: #f00;") isnt -1).toBeTruthy()
    expect(contents.indexOf("background: #00f;") isnt -1).toBeTruthy()
    done()
    
describe 'nap.packageJSTs', ->
  
  runAsync()
  
  it 'packs files into JST[path/to/file] = JSTCompile(fileContents)', ->
    expect(nap.packageJST('h1 Hello World', 'path/to/index.jade')).toEqual(
      'window.JST["path/to/index"] = JSTCompile("h1 Hello World");'
    )
    done()
    
  it 'packs templates in relative dirs to the templates folder', ->
    expect(nap.packageJST('h1 Hello World', 'path/to/templates/foo/index.jade')).toEqual(
      'window.JST["foo/index"] = JSTCompile("h1 Hello World");'
    )
    done()

  it "escapes newline characters", ->
    str = "h1 Hello World\nh2 Can I haz cheezeburger?\n"
    expect(nap.packageJST(str, 'path/to/templates/foo/index.jade')).toEqual(
      'window.JST["foo/index"] = JSTCompile(\"h1 Hello World\\nh2 Can I haz cheezeburger?\\n\");'
    )
    done()

  it "escapes double quotes characters", ->
    str = 'h1 "Hello World"'
    expect(nap.packageJST(str, 'path/to/templates/foo/index.jade')).toEqual(
      'window.JST["foo/index"] = JSTCompile(\"h1 \\\"Hello World\\\"\");'
    )
    done()
    
describe 'nap.ugilfyJS', ->
  
  runAsync()
  
  it 'compresses js using UgilfyJS', ->
    expect(nap.ugilfyJS('foo["bar"]')).toEqual('foo.bar')
    done()
    
describe 'nap.yuiCssMin', ->
  
  runAsync()
  
  it 'compresses css using YUI compressor', ->
    expect(nap.yuiCssMin('body {   \n\n background: red;\n\n   }')).toEqual 'body{background:red}'
    done()