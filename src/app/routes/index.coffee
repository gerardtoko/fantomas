express = require 'express'
router = express.Router()

router.get '/', (req, res) ->
  res.json({ title: 'Fantomas' });

module.exports = router;
