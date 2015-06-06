chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'ghe', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()
    require('../src/ghe')(@robot)

  describe 'Get License info', ->
    it 'registers a respond listener', ->
      expect(@robot.respond).to.have.been.calledWith(/ghe info license/)
