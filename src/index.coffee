
assertTypes = require "assertTypes"
assertType = require "assertType"
crypto = require "crypto"
Shape = require "Shape"
fs = require "fs"

policyTypes =
  canned: require "./CannedPolicy"
  post: require "./PostPolicy"

optionTypes =
  policy: Shape {type: String}
  privateKey: String
  algorithm: String.Maybe

exports.getSignedPolicy = (options) ->
  assertTypes options, optionTypes
  {policy, privateKey, algorithm} = options

  unless policyType = policyTypes[policy.type]
    throw Error "Invalid policy type: '#{policy.type}'"

  policy.expires ?= Math.round Date.now() + (30 * 6e4) # <= 30 minutes
  policy = policyType(policy).toJSON()

  policy: encodePolicy policy
  signature: createPolicySignature policy, privateKey, algorithm

#
# Internal helpers
#

resolvePrivateKey = (key) ->

  if key[0] is "."
    throw Error "'options.privateKey' must be an absolute path!"

  if key[0] is "/"
    key = fs.readFileSync key, {encoding: "utf8"}

  lineBreakRegex = /\r|\n/
  unless lineBreakRegex.test key
    throw Error "Invalid private key (must include line breaks)!"

  return key

createPolicySignature = (policy, privateKey, algorithm = "HMAC-SHA256") ->
  assertType policy, String
  assertType privateKey, String
  assertType algorithm, String

  if algorithm.startsWith "RSA-"
    sign = crypto.createSign algorithm
    sign.update policy
    signature = sign.sign privateKey, "base64"

  else if algorithm.startsWith "HMAC-"
    sign = crypto.createHmac algorithm.slice(5), privateKey
    sign.update encodePolicy policy
    signature = sign.digest "base64"

  else
    throw Error "Unsupported encryption: '#{@encryption}'"

  normalizeBase64 signature

encodePolicy = (policy) ->
  assertType policy, String
  normalizeBase64 Buffer(policy).toString "base64"

normalizeBase64 = (str) ->
  str.replace /\+/g, "-"
     .replace /=/g, "_"
     .replace /\//g, "~"
