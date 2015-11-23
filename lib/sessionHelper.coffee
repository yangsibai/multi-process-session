crypto = require 'crypto'
uuid = require("node-uuid")

genSID = (secret)->
    unless secret
        throw new Error('need secret')
    hmac = crypto.createHmac('sha1', secret)
    id = uuid.v4()
    hmac.update new Buffer(id, 'utf8')
    return hmac.digest('hex')

exports.genSID = genSID
