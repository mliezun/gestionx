const express = require('express');
const { spawnSync } = require('child_process');

const app = express();

app.use(express.json());

app.get('/', function(req, res) {
  res.send('OK');
});

app.post('/', function(req, res) {
  const body = req.body;
  if (!body.cmds) {
    res.send('NOK');
  }
  let result = 'OK';
  for (let i = 0; i < body.cmds.length; i++) {
    const cmd = body.cmds[i];
    const child = spawnSync('sh', ['-c', cmd]);
    console.log('Executing', cmd);
    console.log('stdout ', child.stdout.toString());
    if (child.error) {
      console.log('error', child.error);
      result = 'NOK';
    }
    if (child.stderr.toString()) {
      console.log('stderr ', child.stderr.toString());
      result = 'NOK';
    }
    if (result != 'OK') {
      break;
    }
  }
  res.send(result);
});

app.listen(3000, function() {
  console.log('cmd server, running in port 3000!');
});
