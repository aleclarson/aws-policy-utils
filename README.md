
# aws-policy-utils v1.0.0 ![stable](https://img.shields.io/badge/stability-stable-4EBA0F.svg?style=flat)

Inspired by [aws-cloudfront-sign](https://github.com/jasonsims/aws-cloudfront-sign) and [node-s3-policy](https://github.com/tj/node-s3-policy).

```js
const policyUtils = require('aws-policy-utils');

const {policy, signature} = policyUtils.getSignedPolicy({
  policy: {
    type: 'post', // might equal 'canned' when working with CloudFront
    acl: 'public-read', // access control
    bucket: '(BUCKET_ID)', // the required bucket
    contentLength: 1000000, // max content length (in bytes)
  },
  privateKey: '/absolute/path/to/key.pem',
  algorithm: 'HMAC-SHA256',
});
```

### install

```sh
yarn add aleclarson/aws-policy-utils#1.0.0
```
