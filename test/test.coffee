selenium = require('selenium-standalone')
webdriver = require('webdriverio')
assert = require('assert')
nodeStatic = require('node-static')
http = require('http')
should = require('chai').should()

currentPort = 9000
port = currentPort + Math.floor(Math.random() * (1000-1+1)+1)

sleep = (seconds)->
  e = new Date().getTime() + (seconds * 1000)
  while (new Date().getTime() <= e)
    1

run = (seleniumParams) ->
  staticServer = null
  server = null
  client = null

  before (done)->
    @timeout 0

    staticServer = new nodeStatic.Server('./test')
    server = http.createServer((req, res)->
      req.addListener('end', ()->
        staticServer.serve(req, res)
      ).resume()
    ).listen(port)

    selenium.start (err, child)->
      throw err if err
      selenium.proc = child
      client = webdriver.remote(seleniumParams).init ()->
        done()

  after (done) ->
    client.end ->
      server.close()
      selenium.proc.kill()
      done()

  describe 'Cuckoo Tests for ['+ seleniumParams.desiredCapabilities.browserName + ']', () ->
    describe 'Globally Target Events', ->
      it 'Capture Global Clicks', (done) ->
        client.url("http://localhost:#{port}/test.html", ->
        ).click('#somelink', ->
        ).getText('#result', (err, res) ->
          res.should.equal 'clicked: somelink'
        ).call done

    describe 'Globally Target Events', ->
      it 'Capture Global Clicks', (done) ->
        client.url("http://localhost:#{port}/test.html", ->
        ).click('#somelink', ->
        ).getText('#result', (err, res) ->
          res.should.equal 'clicked: somelink'
        ).call done

if Boolean(process.env.CI) and Boolean(process.env.TRAVIS)
  browsers = [
    'firefox'
    'chrome'
    'iphone'
  ]
  browsers.forEach (browser) ->
    run
      desiredCapabilities:
        browserName: browser
        name: process.env.TRAVIS_COMMIT
        tags: [
          process.env.TRAVIS_PULL_REQUEST
          process.env.TRAVIS_BRANCH
          process.env.TRAVIS_BUILD_NUMBER
        ]
        'tunnel-identifier': process.env.TRAVIS_JOB_NUMBER
      host: 'ondemand.saucelabs.com'
      port: 80
      user: process.env.SAUCE_USERNAME
      key: process.env.SAUCE_ACCESS_KEY
      logLevel: 'silent'
    return
else
  run
    desiredCapabilities:
      browserName: 'phantomjs'
      'phantomjs.binary.path': './node_modules/phantomjs/bin/phantomjs'
