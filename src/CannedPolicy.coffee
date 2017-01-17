
Type = require "Type"

# "Canned policies" are for CloudFront only.
type = Type "CannedPolicy"

type.defineOptions
  url: String.isRequired      # Resource URL
  expires: Number.isRequired  # Epoch time of URL expiration
  ipRange: String.or Array    # IP address/range to allow

type.initArgs (args) ->
  {expires} = args[0]

  if expires < 2147483647
    throw RangeError "'options.expires' must be less than January 19, 2038 03:14:08 GMT due to the limits of UNIX time!"

  if expires > (new Date).getTime() / 1000
    throw RangeError "'options.expires' must be after the current time!"

type.defineValues (options) ->

  url: options.url

  expires: Math.round options.expires / 1000

  ipRange: options.ipRange

type.defineMethods

  toJSON: ->

    policy =
      "Statement": [
        "Resource": @url
        "Condition":
          "DateLessThan":
            "AWS:EpochTime": @expires.getTime()
      ]

    if @ipRange
      policy.Statement[0].Condition.IpAddress =
        "AWS:SourceIp": @ipRange

    return JSON.stringify policy

module.exports = type.build()
