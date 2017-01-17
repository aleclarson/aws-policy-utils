
isType = require "isType"
OneOf = require "OneOf"
Type = require "Type"

# Some values are not included: http://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl
AccessControl = OneOf "private public-read public-read-write"

# "POST policies" are for client-side S3 uploads via `FormData`.
type = Type "PostPolicy"

type.defineOptions
  acl: AccessControl.isRequired
  expires: Number.or(Date).isRequired
  bucket: String.isRequired
  conditions: Array
  key: String
  contentType: String
  contentLength: Number.or Array

type.defineValues (options) ->

  expires: new Date options.expires

  conditions: @_parseConditions options

type.defineMethods

  _parseConditions: (options) ->
    {conditions, bucket, acl, contentType, contentLength} = options
    conditions ?= []
    conditions.push ["starts-with", "$key", options.key or ""]
    conditions.push ["starts-with", "$Content-Type", contentType or ""]
    conditions.push ["starts-with", "$Content-Length", ""]
    if isType contentLength, Array
      conditions.push ["content-length-range", contentLength[0], contentLength[1]]
    else if isType contentLength, Number
      conditions.push ["content-length-range", 1, contentLength]
    conditions.push {bucket}, {acl}
    return conditions

  toJSON: ->
    JSON.stringify {
      expiration: @expires.getTime()
      @conditions
    }

module.exports = type.build()
